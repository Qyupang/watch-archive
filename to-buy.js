/* Watch Archive To Buy / market tracking */
(function(){
'use strict';
const css=[
'.archive-subtabs{display:flex;gap:8px;margin:-4px 0 18px;padding:4px;background:var(--soft);border-radius:13px}',
'.archive-subtab{flex:1;border:0;border-radius:10px;padding:10px;background:transparent;color:var(--muted);font-size:13px;font-weight:650}',
'.archive-subtab.active{background:var(--paper);color:var(--ink)}',
'.overlay .status{grid-template-columns:repeat(3,minmax(0,1fr))}.overlay .status button{padding:11px 5px;font-size:12px}',
'.to-buy-badge{display:inline-flex;width:max-content;margin-bottom:7px;padding:4px 7px;border:1px solid var(--line);border-radius:999px;color:var(--muted);font-size:9px;letter-spacing:.12em;font-weight:750}',
'.market-section{margin:26px 0;padding:18px;border:1px solid var(--line);border-radius:16px;background:var(--paper)}',
'.market-section-title{font:24px Georgia,serif;margin:4px 0 15px}',
'.market-metrics{display:grid;grid-template-columns:1fr 1fr;gap:9px;margin:14px 0}',
'.market-metric{padding:12px;border-radius:11px;background:var(--soft)}.market-metric span{display:block;color:var(--muted);font-size:10px;margin-bottom:6px}.market-metric strong{font-size:16px;font-variant-numeric:tabular-nums}',
'.market-chart{width:100%;height:auto;display:block;margin:8px 0 4px}.market-section #marketChart{margin-bottom:28px}.market-section #marketChart>div{margin-top:8px!important}.market-chart-empty{padding:18px 10px;text-align:center;color:var(--muted);font-size:12px;background:var(--soft);border-radius:10px}',
'.market-section #marketList{margin-top:12px}.market-record{display:grid;grid-template-columns:minmax(0,1fr) auto;column-gap:16px;row-gap:12px;align-items:center;padding:20px 0;border-top:1px solid var(--line)}.market-record-price{font-size:17px;font-weight:750}.market-record-meta{font-size:12px;color:var(--muted);margin-top:8px;line-height:1.7;overflow-wrap:anywhere}.market-status{font-size:11px;padding:5px 9px;border-radius:999px;background:var(--soft);color:var(--muted)}',
'.market-record-actions{display:flex;gap:9px;align-items:center}.market-record-actions button,.market-target-row button{border:1px solid var(--line);border-radius:9px;padding:10px 13px;background:transparent;color:var(--muted);font-size:12px}',
'.market-form{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px;margin-top:17px;padding-top:16px;border-top:1px solid var(--line);min-width:0;box-sizing:border-box}.market-form .full{grid-column:1/-1}.market-form label{display:block;font-size:11px;color:var(--muted);margin-bottom:6px}',
'.market-form>div{min-width:0}.market-form input,.market-form select,.market-form textarea,.market-target-input{display:block;box-sizing:border-box;width:100%;max-width:100%;min-width:0;border:1px solid var(--line);border-radius:10px;padding:11px;background:var(--bg);color:var(--ink);font:inherit;font-size:13px}.market-form input[type=date]{-webkit-appearance:none;appearance:none;min-height:44px}.market-form textarea{min-height:66px;resize:vertical}.market-form .action{box-sizing:border-box;width:100%;max-width:100%}',
'.market-target-row{display:flex;align-items:center;gap:8px;margin:14px 0}.market-target-row label{font-size:11px;color:var(--muted);white-space:nowrap}.market-target-row input{flex:1;min-width:0}',
'.market-complete-button{width:100%;margin-top:15px;padding:13px;border:0;border-radius:11px;background:var(--ink);color:var(--bg);font-weight:700}',
'.market-modal{position:fixed;inset:0;z-index:10020;background:#0008;display:flex;align-items:flex-end;justify-content:center;padding:16px}.market-modal-card{width:min(100%,480px);padding:20px;border-radius:20px;background:var(--paper);color:var(--ink)}.market-modal-card h2{font:25px Georgia,serif;margin:0 0 8px}.market-modal-card p{font-size:12px;color:var(--muted);line-height:1.6}.market-modal-card label{display:block;font-size:11px;color:var(--muted);margin:12px 0 6px}.market-modal-card input{width:100%;padding:12px;border:1px solid var(--line);border-radius:10px;background:var(--bg);color:var(--ink);font:inherit}.market-modal-actions{display:flex;gap:8px;margin-top:18px}.market-modal-actions button{flex:1;padding:12px;border-radius:10px;border:1px solid var(--line);background:transparent;color:var(--ink)}.market-modal-actions .primary{background:var(--ink);color:var(--bg)}',
'@media(max-width:380px){.market-form{grid-template-columns:1fr}.market-form .full{grid-column:auto}.market-record{grid-template-columns:1fr}}'
].join('');
const st=document.createElement('style');st.textContent=css;document.head.appendChild(st);
const oldHome=window.renderHome,oldResults=window.updateHomeResults,oldSwitch=window.switchCollection,oldCard=window.card,oldEditor=window.renderEditor,oldDetail=window.renderDetail;
const won=n=>Number(n||0).toLocaleString('ko-KR')+'원',today=()=>{const d=new Date();return d.getFullYear()+'-'+String(d.getMonth()+1).padStart(2,'0')+'-'+String(d.getDate()).padStart(2,'0')};
const escM=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
let rows=[],watchId=null,editingId=null;
function subtabs(){
 const tabs=document.querySelector('#app .tabs');if(!tabs||filter==='owned')return;
 let el=document.getElementById('archiveSubtabs');
 if(!el){el=document.createElement('div');el.id='archiveSubtabs';el.className='archive-subtabs';tabs.insertAdjacentElement('afterend',el)}
 const count=watches.filter(w=>w.status==='to_buy').length;
 el.innerHTML='<button class="archive-subtab '+(filter==='archive'?'active':'')+'" onclick="switchCollection(\'archive\')">Archive</button><button class="archive-subtab '+(filter==='to_buy'?'active':'')+'" onclick="switchCollection(\'to_buy\')">Watchlist'+(count?' · '+count:'')+'</button>';
}
window.renderHome=function(){oldHome();subtabs()};
window.switchCollection=function(next){if(next!=='to_buy')return oldSwitch(next);if(filter==='to_buy')return;filter='to_buy';query='';brandFilter='';sortMenuOpen=false;renderHome();window.scrollTo(0,0)};
window.updateHomeResults=function(){oldResults();if(filter==='to_buy'){const h=document.querySelector('#homeResults .head h2');if(h)h.textContent='Watchlist';const e=document.querySelector('#homeResults .empty');if(e)e.textContent='관심 시계를 추가해 보세요.'}};
window.card=function(w){const html=oldCard(w);return w.status==='to_buy'?html.replace('<div class="cardbody">','<div class="cardbody"><span class="to-buy-badge">WATCHLIST</span>'):html};
window.renderEditor=function(){
 oldEditor();const root=document.querySelector('.overlay .status');
 if(root&&!root.querySelector('[data-status="to_buy"]')){
  root.querySelectorAll('button').forEach(b=>b.dataset.status=b.textContent.trim()==='My Watch'?'owned':'archive');
  const b=document.createElement('button');b.type='button';b.dataset.status='to_buy';b.className=editStatus==='to_buy'?'active':'';b.textContent='Watchlist';b.onclick=()=>setStatus('to_buy');root.appendChild(b);
 }
 if(editStatus==='to_buy'){const h=document.querySelector('.new-watch-heading h1');if(h)h.textContent='Add to Watchlist';const p=document.querySelector('.new-watch-heading p');if(p)p.textContent='관심 있는 시계를 목록에 기록해 보세요.'}
};
window.renderDetail=function(){
 oldDetail();const w=watches.find(x=>x.id===detail);if(!w||w.status!=='to_buy')return;
 const actions=document.querySelector('#app .detail .actions');if(!actions||document.getElementById('marketSection'))return;
 actions.insertAdjacentHTML('beforebegin',sectionHtml(w));loadHistory(w.id);
};
function sectionHtml(w){
 return '<section class="market-section" id="marketSection"><div class="eyebrow">SECONDHAND MARKET</div><div class="market-section-title">Market Watch</div>'+
 '<div class="market-metrics"><div class="market-metric"><span>최근 등록 호가</span><strong id="marketListing">—</strong></div><div class="market-metric"><span>최근 실거래가</span><strong id="marketSold">—</strong></div></div>'+
 '<div class="eyebrow">COMPLETED TRANSACTIONS</div><div id="marketChart" class="market-chart-empty">실거래 기록을 추가하면 가격 흐름을 확인할 수 있어요.</div>'+
 '<div class="eyebrow">MARKET HISTORY</div><div id="marketList"><div class="market-chart-empty">거래 기록을 불러오는 중입니다.</div></div>'+
 '<form class="market-form" id="marketForm" onsubmit="saveMarketEntry(event,\''+w.id+'\')"><div class="full"><strong id="marketFormTitle">거래 기록 추가</strong></div>'+
 '<div><label>확인 날짜</label><input id="marketDate" type="date" value="'+today()+'" required></div><div><label>가격 (원)</label><input id="marketPrice" type="text" inputmode="numeric" autocomplete="off" placeholder="8,500,000" oninput="formatPurchasePriceInput(this)" required></div>'+
 '<div><label>거래 상태</label><select id="marketStatus"><option value="listed">판매 중 · 호가</option><option value="sold">판매 완료 · 실거래</option><option value="withdrawn">판매 종료</option></select></div>'+
 '<div><label>거래 플랫폼</label><input id="marketPlatform" placeholder="번개장터, 중고나라 등"></div>'+
 '<div><label>시계 상태</label><select id="marketCondition"><option value="">선택 안 함</option><option>미사용</option><option>민트급</option><option>양호</option><option>사용감 있음</option><option>부품용</option></select></div>'+
 '<div><label>구성품</label><select id="marketAccessories"><option value="">선택 안 함</option><option>풀세트</option><option>시계 단품</option><option>박스 포함</option><option>보증서 포함</option><option>기타</option></select></div>'+
 '<div class="full"><label>매물 URL (선택)</label><input id="marketUrl" type="url" placeholder="https://"></div><div class="full"><label>메모 (선택)</label><textarea id="marketNote" placeholder="상태, 판매자 설명, 협상 내용 등을 기록해 보세요."></textarea></div>'+
 '<div class="full"><button class="action primary" id="marketSave" type="submit">거래 기록 저장</button><button class="action" id="marketCancel" type="button" hidden onclick="resetMarketForm()" style="width:100%;margin-top:7px">수정 취소</button></div></form>'+
 '<button class="market-complete-button" onclick="openPurchaseComplete(\''+w.id+'\')">구매 완료 · My Watches로 이동</button></section>';
}
async function loadHistory(id){
 watchId=id;const {data,error}=await supabaseClient.from('watch_market_history').select('*').eq('watch_id',id).eq('user_id',currentUser.id).order('observed_date',{ascending:false}).order('created_at',{ascending:false});
 if(error){console.error(error);const el=document.getElementById('marketList');if(el)el.textContent='거래 기록을 불러오지 못했습니다.';return}
 rows=data||[];renderHistory(id);
}
function renderChart(){
 const el=document.getElementById('marketChart');if(!el)return;
 const sold=rows.filter(r=>r.status==='sold').slice().sort((a,b)=>a.observed_date.localeCompare(b.observed_date));
 if(sold.length<2){el.className='market-chart-empty';el.textContent=sold.length?'실거래 기록이 2건 이상 쌓이면 가격 추이를 표시합니다.':'실거래 기록을 추가하면 가격 흐름을 확인할 수 있어요.';return}
 const v=sold.map(r=>Number(r.price)),min=Math.min(...v),max=Math.max(...v),span=Math.max(1,max-min);
 const pts=v.map((n,i)=>(12+i*296/(v.length-1)).toFixed(1)+','+(98-(n-min)/span*76).toFixed(1));
 el.className='';el.innerHTML='<svg class="market-chart" viewBox="0 0 320 122" role="img" aria-label="실거래 가격 추이"><line x1="10" y1="98" x2="310" y2="98" stroke="var(--line)"/><polyline points="'+pts.join(' ')+'" fill="none" stroke="var(--ink)" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>'+pts.map(p=>{const a=p.split(',');return '<circle cx="'+a[0]+'" cy="'+a[1]+'" r="3.5" fill="var(--paper)" stroke="var(--ink)" stroke-width="2"/>'}).join('')+'<text x="12" y="116" fill="var(--muted)" font-size="9">'+escM(sold[0].observed_date.slice(0,7))+'</text><text x="308" y="116" text-anchor="end" fill="var(--muted)" font-size="9">'+escM(sold[sold.length-1].observed_date.slice(0,7))+'</text></svg><div style="display:flex;justify-content:space-between;color:var(--muted);font-size:10px"><span>최저 '+won(min)+'</span><span>최고 '+won(max)+'</span></div>';
}
function renderHistory(id){
 const el=document.getElementById('marketList');if(!el||watchId!==id)return;
 const listing=rows.find(r=>r.status==='listed'),sold=rows.find(r=>r.status==='sold');
 const l=document.getElementById('marketListing'),s=document.getElementById('marketSold');if(l)l.textContent=listing?won(listing.price):'—';if(s)s.textContent=sold?won(sold.price):'—';
 renderChart();
 el.innerHTML=rows.length?rows.map(r=>'<div class="market-record"><div><div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap"><strong class="market-record-price">'+won(r.price)+'</strong><span class="market-status">'+(r.status==='sold'?'실거래':r.status==='listed'?'판매 중':'판매 종료')+'</span></div><div class="market-record-meta">'+escM(r.observed_date)+' · '+escM(r.platform||'플랫폼 미기재')+(r.condition?' · '+escM(r.condition):'')+(r.accessories?' · '+escM(r.accessories):'')+(r.note?'<br>'+escM(r.note):'')+(r.source_url?'<br><a href="'+escM(r.source_url)+'" target="_blank" rel="noopener noreferrer">매물 링크 열기 ↗</a>':'')+'</div></div><div class="market-record-actions"><button onclick="editMarketEntry(\''+r.id+'\')">수정</button><button onclick="deleteMarketEntry(\''+r.id+'\',\''+id+'\')">삭제</button></div></div>').join(''):'<div class="market-chart-empty">아직 등록된 거래 기록이 없습니다.</div>';
}
window.saveMarketEntry=async function(e,id){
 e.preventDefault();const price=Number(String(document.getElementById('marketPrice')?.value||'').replace(/[^0-9]/g,'')),date=document.getElementById('marketDate')?.value;
 if(!price||!date)return toast('날짜와 가격을 입력해 주세요.');
 const rawUrl=document.getElementById('marketUrl').value.trim();if(rawUrl&&!/^https?:\/\//i.test(rawUrl))return toast('매물 URL은 http 또는 https 주소를 입력해 주세요.');const payload={user_id:currentUser.id,watch_id:id,observed_date:date,price,status:document.getElementById('marketStatus').value,platform:document.getElementById('marketPlatform').value.trim()||null,condition:document.getElementById('marketCondition').value||null,accessories:document.getElementById('marketAccessories').value||null,source_url:rawUrl||null,note:document.getElementById('marketNote').value.trim()||null,updated_at:new Date().toISOString()};
 const b=document.getElementById('marketSave');if(b){b.disabled=true;b.textContent='저장 중…'}
 const res=editingId?await supabaseClient.from('watch_market_history').update(payload).eq('id',editingId).eq('user_id',currentUser.id):await supabaseClient.from('watch_market_history').insert(payload);
 if(res.error){console.error(res.error);toast('거래 기록 저장에 실패했습니다.');if(b){b.disabled=false;b.textContent='다시 시도'}return}
 resetMarketForm();await loadHistory(id);toast('거래 기록을 저장했습니다.');
};
window.editMarketEntry=function(id){
 const r=rows.find(x=>x.id===id);if(!r)return;editingId=id;
 document.getElementById('marketDate').value=r.observed_date;document.getElementById('marketPrice').value=Number(r.price).toLocaleString('ko-KR');document.getElementById('marketStatus').value=r.status;document.getElementById('marketPlatform').value=r.platform||'';document.getElementById('marketCondition').value=r.condition||'';document.getElementById('marketAccessories').value=r.accessories||'';document.getElementById('marketUrl').value=r.source_url||'';document.getElementById('marketNote').value=r.note||'';
 document.getElementById('marketFormTitle').textContent='거래 기록 수정';document.getElementById('marketSave').textContent='수정 내용 저장';document.getElementById('marketCancel').hidden=false;document.getElementById('marketForm').scrollIntoView({behavior:'smooth',block:'center'});
};
window.resetMarketForm=function(){
 editingId=null;const f=document.getElementById('marketForm');if(f)f.reset();const d=document.getElementById('marketDate');if(d)d.value=today();
 const h=document.getElementById('marketFormTitle');if(h)h.textContent='거래 기록 추가';const b=document.getElementById('marketSave');if(b){b.disabled=false;b.textContent='거래 기록 저장'}const c=document.getElementById('marketCancel');if(c)c.hidden=true;
};
window.deleteMarketEntry=async function(id,wid){
 if(!confirm('이 거래 기록을 삭제할까요?'))return;const {error}=await supabaseClient.from('watch_market_history').delete().eq('id',id).eq('user_id',currentUser.id);
 if(error)return toast('거래 기록 삭제에 실패했습니다.');await loadHistory(wid);toast('거래 기록을 삭제했습니다.');
};
window.openPurchaseComplete=function(id){
 if(document.getElementById('marketPurchaseModal'))return;
 document.body.insertAdjacentHTML('beforeend','<div class="market-modal" id="marketPurchaseModal" role="dialog" aria-modal="true"><div class="market-modal-card"><h2>구매 완료</h2><p>기존 시계 정보와 사진을 유지한 채 My Watches로 이동합니다.</p><label>실제 구매 가격 (원)</label><input id="marketPurchasePrice" inputmode="numeric" placeholder="예: 7,500,000"><label>구매일</label><input id="marketPurchaseDate" type="date" value="'+today()+'"><div class="market-modal-actions"><button onclick="closePurchaseComplete()">취소</button><button class="primary" onclick="confirmPurchaseComplete(\''+id+'\')">My Watches로 이동</button></div></div></div>');
};
window.closePurchaseComplete=function(){document.getElementById('marketPurchaseModal')?.remove()};
window.confirmPurchaseComplete=async function(id){
 const price=Number(String(document.getElementById('marketPurchasePrice')?.value||'').replace(/[^0-9]/g,'')),date=document.getElementById('marketPurchaseDate')?.value||today();if(!price)return toast('실제 구매 가격을 입력해 주세요.');
 const b=document.querySelector('#marketPurchaseModal .primary');if(b){b.disabled=true;b.textContent='이동 중…'}
 const {error}=await supabaseClient.from('watches').update({status:'owned',purchase_price:price,purchase_source:'domestic',customs_duty:0,purchase_date:date,possession_status:'held',target_price:null}).eq('id',id).eq('user_id',currentUser.id).eq('status','to_buy');
 if(error){console.error(error);toast('My Watches 이동에 실패했습니다.');if(b){b.disabled=false;b.textContent='다시 시도'}return}
 closePurchaseComplete();detail=null;filter='owned';possessionFilter='all';await load();renderHome();toast('My Watches에 추가했습니다.');
};
})();