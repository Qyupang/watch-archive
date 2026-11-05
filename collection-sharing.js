/* Watch Archive collection sharing add-on */
(function () {
  'use strict';
  const bucket = 'collection-shares';
  const sharePage = new URL('share.html', location.href);
  const escShare = value => String(value ?? '').replace(/[&<>"']/g, ch => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[ch]));
  const publicPath = url => {
    const marker = '/storage/v1/object/public/' + bucket + '/';
    const at = String(url || '').indexOf(marker);
    return at < 0 ? null : decodeURIComponent(url.slice(at + marker.length).split('?')[0]);
  };
  const shareUrl = token => { const u = new URL(sharePage.href); u.searchParams.set('token', token); return u.toString(); };

  function injectShareButton() {
    const stage = document.querySelector('.box-detail-stage');
    if (!stage || stage.querySelector('[data-collection-share-button]')) return;
    const manage = [...stage.querySelectorAll('.box-section-head')].find(el => el.querySelector('h2')?.textContent.trim() === 'Manage');
    const actions = manage?.nextElementSibling;
    if (!actions) return;
    const button = document.createElement('button');
    button.type = 'button'; button.className = 'box-action primary';
    button.dataset.collectionShareButton = 'true'; button.textContent = '컬렉션 공유하기';
    button.addEventListener('click', () => openCollectionShareModal(activeBoxId));
    actions.prepend(button);
  }
  const originalRender = renderCollectionBoxDetail;
  renderCollectionBoxDetail = function () { originalRender(); injectShareButton(); };

  async function getExisting(boxId) {
    const {data,error} = await supabaseClient.from('collection_shares').select('*')
      .eq('box_id',boxId).eq('user_id',currentUser.id).maybeSingle();
    if(error) throw error; return data;
  }
  function makeModal(content) {
    document.getElementById('collectionShareOverlay')?.remove();
    const overlay = document.createElement('div'); overlay.className='overlay'; overlay.id='collectionShareOverlay';
    overlay.innerHTML='<section class="sheet wa-share-sheet" role="dialog" aria-modal="true" aria-labelledby="waShareTitle"><div class="sheettop"><div><div class="eyebrow">WATCH ARCHIVE / SHARE</div><h2 class="title" id="waShareTitle">Share Collection</h2></div><button type="button" class="close" id="waShareClose" aria-label="닫기">×</button></div><div id="waShareContent">'+content+'</div></section>';
    document.body.appendChild(overlay);
    overlay.addEventListener('click',e=>{if(e.target===overlay)overlay.remove()});
    overlay.querySelector('#waShareClose').addEventListener('click',()=>overlay.remove());
    return overlay;
  }
  async function openCollectionShareModal(boxId) {
    if(!currentUser)return toast('로그인 후 이용해줘');
    const box=collectionBoxes.find(x=>x.id===boxId); if(!box)return;
    const overlay=makeModal('<div class="wa-share-loading">공유 설정을 불러오고 있어요…</div>');
    try {
      const existing=await getExisting(boxId);
      const rows=boxItems(boxId).map(item=>({item,watch:boxWatch(item.watch_id)})).filter(x=>x.watch);
      const active=existing?.is_active===true, link=existing?shareUrl(existing.token):'';
      const choices=rows.map(({item,watch})=>{
        const photo=cover(watch);
        return '<label class="wa-share-watch"><input type="checkbox" name="waShareWatch" value="'+escShare(item.id)+'" checked><span class="wa-share-watch-thumb">'+(photo?'<img src="'+escShare(photo)+'" alt="">':'')+'</span><span><strong>'+escShare((watch.brand||'')+' '+(watch.model||''))+'</strong><small>'+escShare(watch.reference||'')+'</small></span></label>';
      }).join('');
      overlay.dataset.boxId=boxId;
      overlay.querySelector('#waShareContent').innerHTML=
        '<p class="wa-share-intro">선택한 시계만 공개돼요. 구매 가격, 관세, 평가 금액, 구매 사유와 개인 기록은 공유하지 않습니다.</p>'+
        '<div class="field"><label for="waShareTitleInput">COLLECTION TITLE</label><input id="waShareTitleInput" maxlength="80" value="'+escShare(existing?.title||box.name)+'"></div>'+
        '<div class="field"><label for="waShareDescriptionInput">COLLECTOR’S NOTE</label><textarea id="waShareDescriptionInput" rows="3" maxlength="500">'+escShare(existing?.description??box.description??'')+'</textarea></div>'+
        '<div class="wa-share-section-head"><strong>공개할 시계</strong><span>'+rows.length+' PIECES</span></div><div class="wa-share-watch-list">'+(choices||'<div class="wa-share-empty">이 컬렉션에 등록된 시계가 없습니다.</div>')+'</div>'+
        '<div class="wa-share-privacy"><span>↗</span><span><strong>링크를 가진 사람만 열람</strong><small>검색 결과나 공개 목록에는 노출되지 않습니다.</small></span></div>'+
        (active?'<div class="wa-share-existing"><span class="wa-share-status">SHARING ACTIVE</span><input id="waShareLink" readonly value="'+escShare(link)+'"><div class="wa-share-actions"><button class="box-action" id="waCopyLink">링크 복사</button><button class="box-action primary" id="waDownloadCard">이미지 카드 저장</button></div><button class="wa-share-disable" id="waDisableShare">공유 중단</button></div>':'')+
        '<button class="action primary wa-share-save" id="waCreateShare" '+(rows.length?'':'disabled')+'>'+(active?'변경사항 저장':'공유 링크 만들기')+'</button>';
      overlay.querySelector('#waCreateShare').addEventListener('click',()=>saveCollectionShare(boxId));
      overlay.querySelector('#waCopyLink')?.addEventListener('click',()=>copyShareLink(link));
      overlay.querySelector('#waDownloadCard')?.addEventListener('click',()=>downloadCollectionCard(existing));
      overlay.querySelector('#waDisableShare')?.addEventListener('click',()=>disableCollectionShare(boxId));
    } catch(error) {
      console.error('Load share settings failed',error);
      overlay.querySelector('#waShareContent').textContent='공유 설정을 불러오지 못했어요: '+(error.message||error);
    }
  }
  async function copyShareLink(link) {
    try { await navigator.clipboard.writeText(link); toast('공유 링크를 복사했어요'); }
    catch (_) { const input=document.getElementById('waShareLink'); if(input){input.select();document.execCommand('copy');toast('공유 링크를 복사했어요')} }
  }
  async function uploadPublicCopy(sourcePath,token,label) {
    if(!sourcePath)return '';
    const {data:blob,error:downloadError}=await supabaseClient.storage.from('watch-photos').download(sourcePath);
    if(downloadError)throw downloadError;
    const mime=blob.type||'image/jpeg',ext=mime.includes('png')?'png':mime.includes('webp')?'webp':'jpg';
    const path=currentUser.id+'/'+token+'/'+label+'-'+crypto.randomUUID()+'.'+ext;
    const {error}=await supabaseClient.storage.from(bucket).upload(path,blob,{contentType:mime,cacheControl:'31536000',upsert:false});
    if(error)throw error;
    return supabaseClient.storage.from(bucket).getPublicUrl(path).data.publicUrl;
  }
  async function saveCollectionShare(boxId) {
    const overlay=document.getElementById('collectionShareOverlay'),box=collectionBoxes.find(x=>x.id===boxId);
    if(!overlay||!box)return;
    const button=overlay.querySelector('#waCreateShare');
    const title=overlay.querySelector('#waShareTitleInput')?.value.trim();
    const description=overlay.querySelector('#waShareDescriptionInput')?.value.trim()||'';
    const ids=[...overlay.querySelectorAll('input[name="waShareWatch"]:checked')].map(x=>x.value);
    if(!title)return toast('컬렉션 이름을 입력해줘');
    if(!ids.length)return toast('공개할 시계를 한 개 이상 선택해줘');
    button.disabled=true;button.textContent='공유 페이지를 준비하고 있어요…';
    try {
      const old=await getExisting(boxId),token=old?.token||crypto.randomUUID();
      const oldUrls=[old?.cover_image_url,...(old?.watch_items||[]).map(x=>x.image_url)].filter(Boolean);
      const selected=boxItems(boxId).filter(item=>ids.includes(item.id)).map(item=>({item,watch:boxWatch(item.watch_id)})).filter(x=>x.watch);
      const publicWatches=[];
      for(let i=0;i<selected.length;i++){
        const {item,watch}=selected[i],photo=(watch.photos||[]).find(p=>p.cover)||(watch.photos||[])[0];
        const imageUrl=photo?.path?await uploadPublicCopy(photo.path,token,'watch-'+String(i+1).padStart(2,'0')):'';
        publicWatches.push({brand:String(watch.brand||''),model:String(watch.model||''),reference:String(watch.reference||''),size:String(watch.size||''),movement:String(watch.movement||''),role_note:String(item.role_note||''),image_url:imageUrl});
      }
      let coverUrl='';
      if(box.cover_image_path)coverUrl=await uploadPublicCopy(box.cover_image_path,token,'cover');
      else {
        const coverIndex=Math.max(0,selected.findIndex(x=>x.watch.id===box.cover_watch_id));
        coverUrl=publicWatches[coverIndex]?.image_url||publicWatches[0]?.image_url||'';
      }
      const payload={user_id:currentUser.id,box_id:boxId,token,title:title.slice(0,80),description:description.slice(0,500),cover_image_url:coverUrl,watch_items:publicWatches,is_active:true,updated_at:new Date().toISOString()};
      let result;
      if(old?.id)result=await supabaseClient.from('collection_shares').update(payload).eq('id',old.id).eq('user_id',currentUser.id).select().single();
      else result=await supabaseClient.from('collection_shares').insert(payload).select().single();
      if(result.error)throw result.error;
      oldUrls.forEach(url=>{const path=publicPath(url);if(path)supabaseClient.storage.from(bucket).remove([path]).then(({error})=>{if(error)console.warn('Share image cleanup failed',error)})});
      const link=shareUrl(token);
      overlay.querySelector('#waShareContent').innerHTML='<div class="wa-share-success"><span class="wa-share-status">SHARING ACTIVE</span><h3>컬렉션이 준비됐어요.</h3><p>아래 링크를 가진 사람만 컬렉션을 볼 수 있어요.</p><input id="waShareLink" readonly value="'+escShare(link)+'"><div class="wa-share-actions"><button class="box-action" id="waCopyLink">링크 복사</button><button class="box-action primary" id="waDownloadCard">이미지 카드 저장</button></div><button class="wa-share-disable" id="waDisableShare">공유 중단</button></div>';
      overlay.querySelector('#waCopyLink').addEventListener('click',()=>copyShareLink(link));
      overlay.querySelector('#waDownloadCard').addEventListener('click',()=>downloadCollectionCard(result.data));
      overlay.querySelector('#waDisableShare').addEventListener('click',()=>disableCollectionShare(boxId));
      toast('컬렉션 공유 링크를 만들었어요');
    } catch(error) {
      console.error('Create share failed',error);toast('공유 페이지 생성 실패: '+(error.message||error));
      button.disabled=false;button.textContent='다시 시도';
    }
  }
  async function disableCollectionShare(boxId) {
    if(!confirm('이 컬렉션의 공유를 중단할까요? 기존 링크와 공유 이미지가 더 이상 열리지 않도록 처리합니다.'))return;
    const {data:share,error:readError}=await supabaseClient.from('collection_shares').select('cover_image_url,watch_items').eq('box_id',boxId).eq('user_id',currentUser.id).maybeSingle();
    if(readError)return toast('공유 정보를 확인하지 못했어요: '+readError.message);
    const {error}=await supabaseClient.from('collection_shares').update({is_active:false,updated_at:new Date().toISOString()}).eq('box_id',boxId).eq('user_id',currentUser.id);
    if(error)return toast('공유 중단에 실패했어요: '+error.message);
    const urls=[share?.cover_image_url,...(share?.watch_items||[]).map(item=>item.image_url)].filter(Boolean);
    const paths=[...new Set(urls.map(publicPath).filter(Boolean))];
    if(paths.length){const {error:removeError}=await supabaseClient.storage.from(bucket).remove(paths);if(removeError)console.warn('Disabled share images cleanup failed',removeError)}
    toast('컬렉션 공유를 중단했어요');openCollectionShareModal(boxId);
  }
  function loadCanvasImage(url) {
    return new Promise(resolve=>{if(!url)return resolve(null);const image=new Image();image.crossOrigin='anonymous';image.onload=()=>resolve(image);image.onerror=()=>resolve(null);image.src=url});
  }
  async function downloadCollectionCard(share) {
    const items=Array.isArray(share?.watch_items)?share.watch_items:[];
    if(!items.length)return toast('이미지 카드에 넣을 시계가 없어요');
    const width=1080,margin=76,gap=28,tileW=(width-margin*2-gap)/2,rows=Math.ceil(items.length/2),height=320+410+210+rows*370+110;
    const canvas=document.createElement('canvas');canvas.width=width;canvas.height=height;const ctx=canvas.getContext('2d');
    ctx.fillStyle='#f5f3ee';ctx.fillRect(0,0,width,height);ctx.fillStyle='#171717';ctx.font='600 24px Arial';ctx.fillText('WATCH ARCHIVE',margin,78);
    ctx.strokeStyle='#cfc9bd';ctx.lineWidth=2;ctx.beginPath();ctx.moveTo(margin,112);ctx.lineTo(width-margin,112);ctx.stroke();
    const hero=await loadCanvasImage(share.cover_image_url);
    if(hero){const scale=Math.max((width-margin*2)/hero.width,410/hero.height),sw=(width-margin*2)/scale,sh=410/scale;ctx.save();ctx.beginPath();ctx.rect(margin,150,width-margin*2,410);ctx.clip();ctx.drawImage(hero,(hero.width-sw)/2,(hero.height-sh)/2,sw,sh,margin,150,width-margin*2,410);ctx.restore()}else{ctx.fillStyle='#e7e2d8';ctx.fillRect(margin,150,width-margin*2,410)}
    ctx.fillStyle='#171717';ctx.font='52px Georgia';ctx.fillText(String(share.title||'My Collection').slice(0,28),margin,635);
    ctx.fillStyle='#77736b';ctx.font='22px Arial';if(share.description)ctx.fillText(String(share.description).slice(0,110),margin,680,width-margin*2);
    ctx.font='18px Arial';ctx.fillText(String(items.length).padStart(2,'0')+' TIMEPIECES',margin,735);
    for(let i=0;i<items.length;i++){const w=items[i],x=margin+(i%2)*(tileW+gap),y=780+Math.floor(i/2)*370,img=await loadCanvasImage(w.image_url);ctx.fillStyle='#e7e2d8';ctx.fillRect(x,y,tileW,250);if(img){const scale=Math.max(tileW/img.width,250/img.height),sw=tileW/scale,sh=250/scale;ctx.save();ctx.beginPath();ctx.rect(x,y,tileW,250);ctx.clip();ctx.drawImage(img,(img.width-sw)/2,(img.height-sh)/2,sw,sh,x,y,tileW,250);ctx.restore()}ctx.fillStyle='#77736b';ctx.font='17px Arial';ctx.fillText(String(w.brand||'').toUpperCase().slice(0,30),x,y+285);ctx.fillStyle='#171717';ctx.font='29px Georgia';ctx.fillText(String(w.model||'').slice(0,26),x,y+325,tileW);ctx.fillStyle='#77736b';ctx.font='17px Arial';ctx.fillText([w.reference,w.size].filter(Boolean).join(' · ').slice(0,40),x,y+355,tileW)}
    ctx.strokeStyle='#cfc9bd';ctx.beginPath();ctx.moveTo(margin,height-70);ctx.lineTo(width-margin,height-70);ctx.stroke();ctx.fillStyle='#77736b';ctx.font='16px Arial';ctx.fillText('A PERSONAL ARCHIVE OF TIMEPIECES',margin,height-35);
    canvas.toBlob(blob=>{if(!blob)return toast('이미지 카드를 만들지 못했어요');const url=URL.createObjectURL(blob),a=document.createElement('a');a.href=url;a.download='watch-archive-collection.png';a.click();setTimeout(()=>URL.revokeObjectURL(url),1500)},'image/png');
  }
  window.openCollectionShareModal=openCollectionShareModal;
  window.downloadCollectionCard=downloadCollectionCard;
  if(activeBoxId)injectShareButton();
})();