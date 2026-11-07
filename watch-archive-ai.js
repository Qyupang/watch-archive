/* Watch Archive AI v1 — local-first, read-only collection assistant. */
(function () {
  'use strict';

  const CHAT_KEY_PREFIX = 'watchArchiveAiChats_v1:';
  const WEAR_CACHE_PREFIX = 'watchArchiveAiWear_v1:';
  const HISTORY_CACHE_PREFIX = 'watchArchiveAiHistory_v1:';
  const BOX_CACHE_PREFIX = 'watchArchiveAiBoxes_v1:';
  const AI_ENDPOINT = SUPABASE_URL + '/functions/v1/watch-archive-ai';
  const MAX_MESSAGES = 80;

  const styles = `
  .wa-ai-intro{padding:20px;border:1px solid var(--line);background:var(--paper);margin-bottom:14px}
  .wa-ai-kicker{font-size:9px;letter-spacing:.2em;color:var(--muted);font-weight:700}
  .wa-ai-title{font:32px Georgia,serif;letter-spacing:-.04em;margin:8px 0}
  .wa-ai-copy{font-size:12px;line-height:1.7;color:var(--muted)}
  .wa-ai-mode{display:flex;gap:6px;overflow:auto;margin:14px 0}
  .wa-ai-mode button{flex:none;border:1px solid var(--line);border-radius:99px;background:transparent;color:var(--muted);padding:8px 12px;font-size:11px}
  .wa-ai-mode button.active{background:var(--ink);color:var(--bg);border-color:var(--ink)}
  .wa-ai-suggestions{display:flex;gap:7px;overflow:auto;padding:2px 0 12px}
  .wa-ai-suggestions button{flex:none;max-width:85%;border:1px solid var(--line);background:var(--paper);color:var(--ink);padding:10px 12px;border-radius:12px;font-size:11px;text-align:left}
  .wa-ai-chat{display:flex;flex-direction:column;gap:12px;min-height:220px;padding:14px 0 18px}
  .wa-ai-message{max-width:92%;padding:13px 14px;border:1px solid var(--line);background:var(--paper);font-size:13px;line-height:1.75;white-space:pre-wrap;overflow-wrap:anywhere}
  .wa-ai-message.user{align-self:flex-end;background:var(--ink);color:var(--bg);border-color:var(--ink)}
  .wa-ai-message.assistant{align-self:flex-start}
  .wa-ai-message .wa-ai-message-meta{display:block;margin-top:8px;font-size:9px;letter-spacing:.08em;opacity:.58}
  .wa-ai-composer{position:sticky;bottom:calc(78px + env(safe-area-inset-bottom,0px));z-index:4;padding:10px;border:1px solid var(--line);background:var(--paper);box-shadow:0 8px 28px #0000000d}
  .wa-ai-composer textarea{display:block;width:100%;min-height:58px;max-height:140px;resize:vertical;border:0;outline:0;background:transparent;color:var(--ink);font:inherit;font-size:13px;line-height:1.6;padding:5px}
  .wa-ai-composer-row{display:flex;justify-content:space-between;align-items:center;gap:10px;border-top:1px solid var(--line);padding-top:9px}
  .wa-ai-send{border:1px solid var(--ink);background:var(--ink);color:var(--bg);padding:10px 17px;font-size:12px;font-weight:650}
  .wa-ai-send:disabled{opacity:.45}
  .wa-ai-footnote{font-size:10px;color:var(--muted);line-height:1.6;margin:10px 0 20px}
  .wa-ai-error{border:1px solid #b56b54;color:var(--ink);padding:12px;font-size:11px;line-height:1.6;margin:10px 0}
  .wa-ai-clear{border:0;background:transparent;color:var(--muted);font-size:10px;text-decoration:underline;text-underline-offset:3px}
  `;
  const style = document.createElement('style');
  style.id = 'watchArchiveAiStyles';
  style.textContent = styles;
  document.head.appendChild(style);

  let dataMode = 'auto';
  let sending = false;

  const escapeHtml = value => String(value ?? '').replace(/[&<>"']/g, ch => ({
    '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'
  }[ch]));
  const cacheKey = prefix => prefix + String(currentUser?.id || 'guest');
  const readJson = key => { try { return JSON.parse(localStorage.getItem(key) || 'null'); } catch (_) { return null; } };
  const writeJson = (key, value) => { try { localStorage.setItem(key, JSON.stringify(value)); } catch (error) { console.warn('Watch Archive AI local cache unavailable', error); } };

  function getChat() {
    const rows = readJson(cacheKey(CHAT_KEY_PREFIX));
    return Array.isArray(rows) ? rows.slice(-MAX_MESSAGES) : [];
  }
  function saveChat(rows) { writeJson(cacheKey(CHAT_KEY_PREFIX), rows.slice(-MAX_MESSAGES)); }

  function localWatches() {
    return (Array.isArray(watches) ? watches : []).map(w => ({
      id:w.id, brand:w.brand, model:w.model, reference:w.reference, size:w.size,
      movement:w.movement, status:w.status, possession_status:w.possession_status,
      purchase_date:w.purchase_date, purchase_price:w.purchase_price,
      purchase_source:w.purchase_source, customs_duty:w.customs_duty,
      current_value:w.current_value, valuation_date:w.valuation_date,
      sale_date:w.sale_date, sale_price:w.sale_price, overhaul_date:w.overhaul_date,
      repair_history:w.repair_history, tags:w.tags, note:w.note,
      purchase_reason:w.purchase_reason
    }));
  }

  async function readCloudRows(table, columns, orderColumn, limit=1000) {
    if (!currentUser) throw new Error('로그인이 필요해요.');
    let query = supabaseClient.from(table).select(columns).eq('user_id', currentUser.id).limit(limit);
    if (orderColumn) query = query.order(orderColumn, { ascending:false });
    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  }

  async function getWearRows(mode) {
    const key = cacheKey(WEAR_CACHE_PREFIX);
    if (mode !== 'local' && navigator.onLine) {
      try {
        const rows = await readCloudRows('wear_logs','id,watch_id,wear_date,created_at','wear_date');
        writeJson(key, rows);
        if (typeof wearLogs !== 'undefined') wearLogs = rows;
        return { rows, source:'cloud' };
      } catch (error) { if (mode==='cloud') throw error; console.warn('AI wear cloud query failed; using local cache', error); }
    }
    if (mode==='cloud') throw new Error('클라우드 착용 기록을 불러오지 못했어요.');
    const cached = readJson(key);
    if (Array.isArray(cached)) return { rows:cached, source:'device' };
    if (typeof wearLogs !== 'undefined' && Array.isArray(wearLogs) && wearLogs.length) return { rows:wearLogs, source:'device' };
    return { rows:[], source:'device' };
  }

  async function getHistoryRows(mode) {
    const key = cacheKey(HISTORY_CACHE_PREFIX);
    if (mode !== 'local' && navigator.onLine) {
      try {
        const rows = await readCloudRows('watch_history','id,watch_id,event_type,event_date,cost,previous_value,new_value,note,created_at','event_date');
        writeJson(key, rows);
        return { rows, source:'cloud' };
      } catch (error) { if (mode==='cloud') throw error; console.warn('AI history cloud query failed; using local cache', error); }
    }
    if (mode==='cloud') throw new Error('클라우드 시계 이력을 불러오지 못했어요.');
    const cached = readJson(key);
    if (Array.isArray(cached)) return { rows:cached, source:'device' };
    const mapped = [];
    if (typeof watchHistoryCache !== 'undefined' && watchHistoryCache instanceof Map) {
      watchHistoryCache.forEach((items, watchId) => (items || []).forEach(item => mapped.push(item)));
    }
    return { rows:mapped, source:'device' };
  }

  async function getBoxes(mode) {
    const key = cacheKey(BOX_CACHE_PREFIX);
    if (mode !== 'local' && navigator.onLine) {
      try {
        const [boxes, items] = await Promise.all([
          readCloudRows('collection_boxes','id,name,description,cover_watch_id,created_at','created_at'),
          readCloudRows('collection_box_items','id,box_id,watch_id,role_note,sort_order,created_at','created_at')
        ]);
        const result = { boxes, items };
        writeJson(key, result);
        return { ...result, source:'cloud' };
      } catch (error) { if (mode==='cloud') throw error; console.warn('AI collection cloud query failed; using local cache', error); }
    }
    if (mode==='cloud') throw new Error('클라우드 컬렉션을 불러오지 못했어요.');
    const cached = readJson(key) || {};
    return { boxes:Array.isArray(cached.boxes)?cached.boxes:[], items:Array.isArray(cached.items)?cached.items:[], source:'device' };
  }

  function makeSummary(watchRows, wearRows) {
    const held = watchRows.filter(w => w.status === 'owned' && w.possession_status !== 'sold');
    const sold = watchRows.filter(w => w.status === 'owned' && w.possession_status === 'sold');
    const brandsByCount = {};
    held.forEach(w => { const name=w.brand||'브랜드 미등록'; brandsByCount[name]=(brandsByCount[name]||0)+1; });
    const totalCost = held.reduce((sum,w)=>sum+(Number(w.purchase_price)||0)+(Number(w.customs_duty)||0),0);
    const knownValue = held.filter(w=>w.current_value!==null&&w.current_value!==undefined&&w.current_value!=='');
    const totalValue = knownValue.reduce((sum,w)=>sum+(Number(w.current_value)||0),0);
    const pnlRows = held.filter(w=>w.current_value!=null&&w.purchase_price!=null&&Number(w.purchase_price)>0);
    const wearCounts = {};
    wearRows.forEach(row=>{ wearCounts[row.watch_id]=(wearCounts[row.watch_id]||0)+1; });
    return {
      total_registered:watchRows.length, currently_held:held.length, sold:sold.length,
      brand_distribution:brandsByCount, acquisition_cost_krw:totalCost,
      current_valuation_krw:totalValue, valuation_coverage:knownValue.length,
      unrealized_profit_krw:pnlRows.reduce((sum,w)=>sum+Number(w.current_value)-Number(w.purchase_price),0),
      wear_log_days:wearRows.length,
      most_worn_watches:Object.entries(wearCounts).sort((a,b)=>b[1]-a[1]).slice(0,8).map(([id,count])=>{
        const w=watchRows.find(item=>item.id===id); return {watch:w?((w.brand||'')+' '+(w.model||'')):id, count};
      })
    };
  }

  async function buildContext(question, mode) {
    if (mode==='cloud' && !navigator.onLine) throw new Error('클라우드 최신 데이터는 인터넷 연결이 필요해요.');
    const watchRows = mode === 'local' || !navigator.onLine
      ? localWatches()
      : await (async()=>{ try {
          const rows = await readCloudRows('watches','id,brand,model,reference,size,movement,status,possession_status,purchase_date,purchase_price,purchase_source,customs_duty,current_value,valuation_date,sale_date,sale_price,overhaul_date,repair_history,tags,note,purchase_reason','created_at');
          return rows;
        } catch (error) { if (mode==='cloud') throw error; console.warn('AI watches cloud query failed; using local state', error); return localWatches(); } })();

    const q = String(question).toLowerCase();
    const needsWear = /착용|wear|빈도|미착용|cost per wear|자주/.test(q);
    const needsHistory = /이력|히스토리|오버홀|수리|정비|스트랩|타임라인|timeline/.test(q);
    const needsBoxes = /보관함|컬렉션|박스|collection box/.test(q);
    const [wear, history, boxes] = await Promise.all([
      needsWear ? getWearRows(mode) : Promise.resolve({rows:[],source:mode==='local'?'device':'not_loaded'}),
      needsHistory ? getHistoryRows(mode) : Promise.resolve({rows:[],source:mode==='local'?'device':'not_loaded'}),
      needsBoxes ? getBoxes(mode) : Promise.resolve({boxes:[],items:[],source:mode==='local'?'device':'not_loaded'})
    ]);
    const sourceSet = new Set([mode==='local'?'device':'cloud', wear.source, history.source, boxes.source].filter(x=>x==='cloud'||x==='device'));
    return {
      data_source: sourceSet.size>1?'mixed':(sourceSet.has('cloud')?'cloud':'device'),
      generated_at: new Date().toISOString(),
      collection_summary: makeSummary(watchRows, wear.rows),
      watches: watchRows,
      ...(needsWear ? { wear_logs:wear.rows.slice(0,500) } : {}),
      ...(needsHistory ? { watch_history:history.rows.slice(0,300) } : {}),
      ...(needsBoxes ? { collections:boxes.boxes, collection_items:boxes.items } : {})
    };
  }

  function renderMessages() {
    const root = document.getElementById('waAiChat');
    if (!root) return;
    const rows = getChat();
    root.innerHTML = rows.length ? rows.map(row =>
      '<article class="wa-ai-message '+(row.role==='user'?'user':'assistant')+'">'+escapeHtml(row.text)+'<span class="wa-ai-message-meta">'+(row.role==='user'?'YOU':'WATCH ARCHIVE AI')+' · '+escapeHtml(new Date(row.at||Date.now()).toLocaleString('ko-KR',{month:'numeric',day:'numeric',hour:'2-digit',minute:'2-digit'}))+'</span></article>'
    ).join('') : '<div class="empty">아직 대화가 없어요.<br>아래 질문 예시를 눌러 첫 대화를 시작해보세요.</div>';
    root.scrollTop = root.scrollHeight;
  }

  function setMode(next) {
    dataMode = ['auto','local','cloud'].includes(next) ? next : 'auto';
    document.querySelectorAll('[data-wa-ai-mode]').forEach(button => button.classList.toggle('active', button.dataset.waAiMode === dataMode));
  }

  function addMessage(role, text) {
    const rows = getChat();
    rows.push({ role, text:String(text), at:Date.now() });
    saveChat(rows);
    renderMessages();
  }

  async function ask(question) {
    const text = String(question || '').trim();
    if (!text || sending) return;
    if (!currentUser) return toast('로그인 후 AI를 사용할 수 있어요.');
    const consentKey='watchArchiveAiOpenAiConsent_v1:'+currentUser.id;
    if(localStorage.getItem(consentKey)!=='accepted'){
      const accepted=confirm('질문에 답하기 위해 선택된 시계 정보와 관련 기록이 Watch Archive 서버를 거쳐 OpenAI API로 전달됩니다. 사진 원본과 로그인 정보는 전송하지 않습니다. 계속할까요?');
      if(!accepted)return;
      localStorage.setItem(consentKey,'accepted');
    }
    sending = true;
    const send = document.getElementById('waAiSend');
    if (send) { send.disabled=true; send.textContent='생각 중…'; }
    addMessage('user', text);
    const placeholder = { role:'assistant', text:'컬렉션 데이터를 확인하고 있어요…', at:Date.now() };
    const before = getChat(); before.push(placeholder); saveChat(before); renderMessages();
    try {
      const mode = dataMode === 'cloud' && !navigator.onLine ? 'local' : dataMode;
      const context = await buildContext(text, mode);
      const { data } = await supabaseClient.auth.getSession();
      const token = data?.session?.access_token;
      if (!token) throw new Error('로그인 세션이 만료됐어요. 다시 로그인해주세요.');
      const response = await fetch(AI_ENDPOINT, {
        method:'POST',
        headers:{
          'Authorization':'Bearer '+token,
          'apikey':SUPABASE_KEY,
          'Content-Type':'application/json'
        },
        body:JSON.stringify({ question:text, context })
      });
      const result = await response.json().catch(()=>({}));
      if (!response.ok) {
        if (result.error === 'openai_api_key_not_configured') throw new Error('OpenAI API 키가 아직 서버에 설정되지 않았어요. Supabase Edge Function Secrets에 OPENAI_API_KEY를 등록해야 해요.');
        if (response.status===401) throw new Error('인증이 만료됐어요. 다시 로그인해주세요.');
        throw new Error(result.error==='ai_provider_error'?'AI 응답 서비스에 문제가 생겼어요. 잠시 후 다시 시도해주세요.':(result.error||'AI 요청에 실패했어요.'));
      }
      const rows = getChat();
      const last = rows[rows.length-1];
      if (last?.role==='assistant' && last.text===placeholder.text) rows.pop();
      rows.push({role:'assistant',text:result.answer||'답변을 받지 못했어요.',at:Date.now()});
      saveChat(rows); renderMessages();
    } catch (error) {
      const rows = getChat();
      const last = rows[rows.length-1];
      if (last?.role==='assistant' && last.text===placeholder.text) rows.pop();
      rows.push({role:'assistant',text:'요청을 처리하지 못했어요. '+(error?.message||String(error)),at:Date.now()});
      saveChat(rows); renderMessages();
    } finally {
      sending=false;
      if (send) { send.disabled=false; send.textContent='질문하기'; }
    }
  }

  window.watchArchiveAiAsk = ask;
  window.watchArchiveAiSetMode = setMode;
  window.watchArchiveAiClear = function () {
    if (!confirm('이 기기에 저장된 Watch Archive AI 대화 기록을 삭제할까요?')) return;
    saveChat([]); renderMessages(); toast('이 기기의 AI 대화 기록을 삭제했어요.');
  };

  window.watchArchiveAiPage = function () {
    if (!currentUser) return toast('로그인 후 AI를 사용할 수 있어요.');
    $('#app').innerHTML =
      '<main class="app"><div class="top"><div><div class="eyebrow">WATCH ARCHIVE / INTELLIGENCE</div><div class="brand">Archive AI</div></div><button class="icon" type="button" onclick="morePage()" aria-label="More로 돌아가기">←</button></div>'+
      '<section class="wa-ai-intro"><div class="wa-ai-kicker">YOUR PERSONAL COLLECTOR ASSISTANT</div><h1 class="wa-ai-title">A deeper view<br>of your collection.</h1><p class="wa-ai-copy">내 시계와 착용 기록을 바탕으로 컬렉션을 분석해요. AI는 데이터를 조회하고 설명만 하며, 시계 정보는 변경하지 않아요.</p></section>'+
      '<div class="wa-ai-mode" role="group" aria-label="데이터 연결 방식"><button type="button" data-wa-ai-mode="auto" class="active" onclick="watchArchiveAiSetMode(\'auto\')">자동</button><button type="button" data-wa-ai-mode="local" onclick="watchArchiveAiSetMode(\'local\')">기기 데이터</button><button type="button" data-wa-ai-mode="cloud" onclick="watchArchiveAiSetMode(\'cloud\')">클라우드 최신 데이터</button></div>'+
      '<div class="wa-ai-suggestions"><button type="button" onclick="watchArchiveAiAsk(\'내 컬렉션의 브랜드와 무브먼트 구성을 분석해줘.\')">내 컬렉션 구성 분석</button><button type="button" onclick="watchArchiveAiAsk(\'최근 착용 기록을 바탕으로 가장 자주 착용한 시계와 미착용 시계를 알려줘.\')">착용 패턴 분석</button><button type="button" onclick="watchArchiveAiAsk(\'구매가와 현재 평가액을 비교해서 내 컬렉션의 평가손익을 정리해줘.\')">컬렉션 가치 분석</button></div>'+
      '<div id="waAiChat" class="wa-ai-chat" aria-live="polite"></div>'+
      '<form class="wa-ai-composer" onsubmit="event.preventDefault();watchArchiveAiSubmit()"><textarea id="waAiQuestion" maxlength="2000" placeholder="내 컬렉션에 대해 무엇이든 물어보세요." aria-label="AI 질문"></textarea><div class="wa-ai-composer-row"><button type="button" class="wa-ai-clear" onclick="watchArchiveAiClear()">대화 기록 지우기</button><button id="waAiSend" class="wa-ai-send" type="submit">질문하기</button></div></form>'+
      '<p class="wa-ai-footnote">대화 기록은 이 기기의 브라우저에만 저장돼요. AI 답변을 생성할 때 선택한 범위의 시계 데이터가 Watch Archive 서버를 거쳐 OpenAI API로 전달됩니다. 사진 원본과 로그인 비밀번호는 전달하지 않아요.</p></main>'+nav('more');
    window.watchArchiveAiSubmit = function () {
      const input=document.getElementById('waAiQuestion');
      const value=input?.value||'';
      if(input)input.value='';
      ask(value);
    };
    setMode(dataMode);
    renderMessages();
  };
})();