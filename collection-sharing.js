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
  async function syncBoxCoverToShare(share,box) {
    if(!box?.cover_image_path)return share;
    const source=share.cover_source||'box';
    if(source!=='box'||share.cover_source_path===box.cover_image_path)return share;
    const nextUrl=await uploadPublicCopy(box.cover_image_path,share.token,'cover');
    const {data,error}=await supabaseClient.from('collection_shares').update({cover_image_url:nextUrl,cover_source:'box',cover_source_path:box.cover_image_path,updated_at:new Date().toISOString()}).eq('id',share.id).eq('user_id',currentUser.id).select().single();
    if(error)throw error;
    const oldPath=publicPath(share.cover_image_url);
    if(oldPath)supabaseClient.storage.from(bucket).remove([oldPath]).then(({error:removeError})=>{if(removeError)console.warn('Old shared cover cleanup failed',removeError)});
    return data;
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
  async function openCollectionShareModal(boxId,forceEditor=false) {
    if(!currentUser)return toast('로그인 후 이용해줘');
    const box=collectionBoxes.find(x=>x.id===boxId); if(!box)return;
    const overlay=makeModal('<div class="wa-share-loading">공유 설정을 불러오고 있어요…</div>');
    try {
      const existing=await getExisting(boxId);
      if(existing?.is_active&&!forceEditor){const refreshed=await syncBoxCoverToShare(existing,box);openCollectionSharePreview(refreshed,boxId);return}
      const rows=boxItems(boxId).map(item=>({item,watch:boxWatch(item.watch_id)})).filter(x=>x.watch);
      const choices=rows.map(({item,watch})=>{
        const photo=cover(watch);
        return '<label class="wa-share-watch"><input type="checkbox" name="waShareWatch" value="'+escShare(item.id)+'" checked><span class="wa-share-watch-thumb">'+(photo?'<img src="'+escShare(photo)+'" alt="">':'')+'</span><span><strong>'+escShare((watch.brand||'')+' '+(watch.model||''))+'</strong><small>'+escShare(watch.reference||'')+'</small></span></label>';
      }).join('');
      overlay.querySelector('#waShareContent').innerHTML=
        '<p class="wa-share-intro">공유할 시계를 선택해줘. 구매 가격, 관세, 평가 금액, 구매 사유와 개인 기록은 공개하지 않아.</p>'+
        '<div class="field"><label for="waShareTitleInput">COLLECTION TITLE</label><input id="waShareTitleInput" maxlength="80" value="'+escShare(existing?.title||box.name)+'"></div>'+
        '<div class="field"><label for="waShareDescriptionInput">COLLECTOR’S NOTE</label><textarea id="waShareDescriptionInput" rows="3" maxlength="500">'+escShare(existing?.description??box.description??'')+'</textarea></div>'+
        '<div class="wa-share-section-head"><strong>공개할 시계</strong><span>'+rows.length+' PIECES</span></div><div class="wa-share-watch-list">'+(choices||'<div class="wa-share-empty">이 컬렉션에 등록된 시계가 없습니다.</div>')+'</div>'+
        '<div class="wa-share-section-head"><strong>대표 사진</strong><span>HERO IMAGE</span></div>'+
        '<div class="wa-share-cover-options">'+(existing?.cover_image_url?'<label><input type="radio" name="waShareCover" value="keep" checked><span class="wa-share-cover-thumb"><img src="'+escShare(existing.cover_image_url)+'" alt=""></span><span>현재 대표 사진 유지</span></label>':'')+'<label><input type="radio" name="waShareCover" value="auto" '+(existing?.cover_image_url?'':'checked')+'><span>컬렉션 기본 사진 사용</span></label>'+
        rows.map(({item,watch})=>{const p=(watch.photos||[]).find(x=>x.cover)||(watch.photos||[])[0];return p?.path?'<label><input type="radio" name="waShareCover" value="'+escShare(item.id)+'"><span class="wa-share-cover-thumb"><img src="'+escShare(cover(watch)||'')+'" alt=""></span><span>'+escShare((watch.brand||'')+' '+(watch.model||''))+'</span></label>':''}).join('')+
        '<label class="wa-share-upload-cover"><span>＋</span><span>별도 대표 사진 업로드</span><input type="file" id="waShareCoverUpload" accept="image/jpeg,image/png,image/webp"></label></div>'+
        '<div class="wa-share-privacy"><span>↗</span><span><strong>링크를 가진 사람만 열람</strong><small>공개 목록이나 검색 결과에는 노출되지 않아.</small></span></div>'+
        '<button class="action primary wa-share-save" id="waCreateShare" '+(rows.length?'':'disabled')+'>'+(existing?'공유 설정 업데이트':'공유 링크 만들기')+'</button>';
      overlay.querySelector('#waCreateShare').addEventListener('click',()=>saveCollectionShare(boxId));
    } catch(error) {
      console.error('Load share settings failed',error);
      overlay.querySelector('#waShareContent').textContent='공유 설정을 불러오지 못했어요: '+(error.message||error);
    }
  }

  function openCollectionSharePreview(share,boxId) {
    const overlay=makeModal('<div class="wa-share-loading">이미지 미리보기를 준비하고 있어요…</div>');
    overlay.classList.add('wa-share-preview-overlay');
    const options={template:'editorial',nickname:true,details:true,note:true,count:true};
    const previewMarkup=
      '<div class="wa-preview-user"><span class="wa-preview-avatar">Q</span><span><strong>WATCH ARCHIVE</strong><small>COLLECTION PREVIEW</small></span><button type="button" class="wa-preview-edit" id="waEditShare">편집</button></div>'+
      '<div class="wa-preview-stage"><img id="waPreviewImage" alt="컬렉션 이미지 카드 미리보기"><div class="wa-preview-loading">카드를 렌더링하고 있어요…</div></div>'+
      '<div class="wa-preview-dots" aria-label="템플릿 선택"><button class="is-active" data-template="editorial">01</button><button data-template="gallery">02</button><button data-template="story">03</button></div>'+
      '<div class="wa-preview-label">SELECT INFORMATION</div>'+
      '<div class="wa-preview-toggles">'+
      '<label><input type="checkbox" data-option="nickname" checked> 컬렉터 이름</label>'+
      ''+
      '<label><input type="checkbox" data-option="note" checked> 컬렉션 소개</label>'+
      '<label><input type="checkbox" data-option="count" checked> 시계 개수</label></div>'+
      '<div class="wa-preview-actions">'+
      '<button type="button" id="waSaveImage"><span>↓</span><strong>Save</strong></button>'+
      '<button type="button" id="waCopyImage"><span>▧</span><strong>Copy</strong></button>'+
      '<button type="button" id="waCopyShareLink"><span>↗</span><strong>Link</strong></button>'+
      '<button type="button" id="waNativeShare"><span>⌯</span><strong>Share</strong></button></div>'+
      '<button type="button" class="wa-preview-disable" id="waDisableShare">컬렉션 공유 중단</button>';
    overlay.querySelector('#waShareContent').innerHTML=previewMarkup;
    let currentBlob=null,currentUrl=null;
    const image=overlay.querySelector('#waPreviewImage');
    const render=async()=>{
      overlay.querySelectorAll('[data-template]').forEach(b=>b.classList.toggle('is-active',b.dataset.template===options.template));
      const blob=await renderCollectionCardBlob(share,options);
      currentBlob=blob;
      if(currentUrl)URL.revokeObjectURL(currentUrl);
      currentUrl=URL.createObjectURL(blob);image.src=currentUrl;
      overlay.querySelector('.wa-preview-loading').style.display='none';
    };
    overlay.querySelectorAll('[data-template]').forEach(button=>button.addEventListener('click',()=>{options.template=button.dataset.template;render()}));
    overlay.querySelectorAll('[data-option]').forEach(input=>input.addEventListener('change',()=>{options[input.dataset.option]=input.checked;render()}));
    overlay.querySelector('#waSaveImage').addEventListener('click',async()=>{
      if(!currentBlob)return;
      const url=URL.createObjectURL(currentBlob),a=document.createElement('a');
      a.href=url;a.download='watch-archive-'+options.template+'.png';a.click();setTimeout(()=>URL.revokeObjectURL(url),1500);
    });
    overlay.querySelector('#waCopyImage').addEventListener('click',async()=>{
      if(!currentBlob)return;
      try{await navigator.clipboard.write([new ClipboardItem({'image/png':currentBlob})]);toast('이미지 카드를 복사했어요')}
      catch(error){toast('이미지 복사를 지원하지 않는 환경이에요. Save를 이용해줘')}
    });
    overlay.querySelector('#waCopyShareLink').addEventListener('click',()=>copyShareLink(shareUrl(share.token)));
    overlay.querySelector('#waNativeShare').addEventListener('click',async()=>{
      if(!currentBlob)return;
      const file=new File([currentBlob],'watch-archive-collection.png',{type:'image/png'});
      try{
        if(navigator.share&&(!navigator.canShare||navigator.canShare({files:[file]})))await navigator.share({title:share.title,text:'My collection on WATCH ARCHIVE',url:shareUrl(share.token),files:[file]});
        else await copyShareLink(shareUrl(share.token));
      }catch(error){if(error.name!=='AbortError')toast('공유를 실행하지 못했어요')}
    });
    overlay.querySelector('#waEditShare').addEventListener('click',()=>openShareEditor(boxId));
    overlay.querySelector('#waDisableShare').addEventListener('click',()=>disableCollectionShare(boxId));
    render().catch(error=>{console.error(error);overlay.querySelector('.wa-preview-loading').textContent='이미지 미리보기를 만들지 못했어요.'});
  }

  async function openShareEditor(boxId) {
    const box=collectionBoxes.find(x=>x.id===boxId);if(!box)return;
    const existing=await getExisting(boxId);
    const overlay=document.getElementById('collectionShareOverlay');
    if(overlay)overlay.remove();
    await openCollectionShareModal(boxId,true);
    const current=document.getElementById('collectionShareOverlay');
    if(existing&&current){
      const title=current.querySelector('#waShareTitleInput');if(title)title.value=existing.title;
      const desc=current.querySelector('#waShareDescriptionInput');if(desc)desc.value=existing.description||'';
      const selected=new Set((existing.watch_items||[]).map(w=>(w.brand||'')+'|'+(w.model||'')));
      if(selected.size)current.querySelectorAll('input[name="waShareWatch"]').forEach(input=>{
        const label=input.closest('.wa-share-watch');
        const name=label?.querySelector('strong')?.textContent||'';
        input.checked=[...selected].some(key=>name===key.replace('|',' '));
      });
    }
  }

  async function renderCollectionCardBlob(share,options) {
    const items=Array.isArray(share?.watch_items)?share.watch_items:[];
    const template=options.template||'editorial';
    const width=1080,height=template==='story'?1920:1280,margin=68;
    const canvas=document.createElement('canvas');canvas.width=width;canvas.height=height;
    const ctx=canvas.getContext('2d');
    const dark=template==='gallery',bg=dark?'#171614':'#f5f3ee',ink=dark?'#f5f3ee':'#171717',muted=dark?'#aaa59b':'#77736b',line=dark?'#49453f':'#d9d5cc';
    ctx.fillStyle=bg;ctx.fillRect(0,0,width,height);
    const hero=await loadCanvasImage(share.cover_image_url);
    if(template==='editorial'||template==='story'){
      const heroH=template==='story'?1640:1120,heroY=0;
      if(hero){const scale=Math.max(width/hero.width,heroH/hero.height),sw=width/scale,sh=heroH/scale;ctx.save();ctx.beginPath();ctx.rect(0,0,width,heroH);ctx.clip();ctx.drawImage(hero,(hero.width-sw)/2,(hero.height-sh)/2,sw,sh,0,0,width,heroH);ctx.restore()}
      else{ctx.fillStyle='#d8d0c4';ctx.fillRect(0,0,width,heroH)}
      const gradient=ctx.createLinearGradient(0,heroH*.52,0,heroH);
      gradient.addColorStop(0,'rgba(0,0,0,0)');gradient.addColorStop(1,'rgba(0,0,0,.72)');
      ctx.fillStyle=gradient;ctx.fillRect(0,0,width,heroH);
      ctx.fillStyle='#fff';ctx.font='600 25px Arial';ctx.fillText('WATCH ARCHIVE',margin,template==='story'?100:86);
      ctx.fillStyle='rgba(255,255,255,.78)';ctx.font='16px Arial';ctx.textAlign='right';ctx.fillText('A PERSONAL WATCH ARCHIVE',width-margin,template==='story'?100:86);ctx.textAlign='left';
      const title=String(share.title||'My Collection').slice(0,34);
      ctx.fillStyle='#fff';ctx.font=(template==='story'?'72px':'68px')+' Georgia';
      ctx.fillText(title,margin,heroH-(template==='story'?250:190),width-margin*2);
      let metaY=heroH-(template==='story'?180:125);
      if(options.nickname){const collector=currentUser?.user_metadata?.nickname||currentUser?.user_metadata?.full_name||currentUser?.email?.split('@')[0]||'WATCH ARCHIVE COLLECTOR';ctx.fillStyle='rgba(255,255,255,.86)';ctx.font='22px Arial';ctx.fillText('CURATED BY '+String(collector).toUpperCase().slice(0,38),margin,metaY);metaY+=38}
      if(options.count){ctx.fillStyle='rgba(255,255,255,.8)';ctx.font='18px Arial';ctx.fillText(String(items.length).padStart(2,'0')+' TIMEPIECES',margin,metaY)}
      ctx.fillStyle=ink;ctx.font='600 19px Arial';ctx.fillText('WATCH ARCHIVE',margin,height-55);
      if(options.note&&share.description){ctx.fillStyle=muted;ctx.font='18px Georgia';ctx.fillText(String(share.description).slice(0,105),margin,height-100,width-margin*2)}
    } else {
      ctx.fillStyle=ink;ctx.font='600 25px Arial';ctx.fillText('WATCH ARCHIVE',margin,86);
      ctx.fillStyle=muted;ctx.font='16px Arial';ctx.textAlign='right';ctx.fillText('A PERSONAL WATCH ARCHIVE',width-margin,86);ctx.textAlign='left';
      ctx.strokeStyle=line;ctx.lineWidth=2;ctx.beginPath();ctx.moveTo(margin,120);ctx.lineTo(width-margin,120);ctx.stroke();
      if(hero){const scale=Math.max((width-margin*2)/hero.width,330/hero.height),sw=(width-margin*2)/scale,sh=330/scale;ctx.save();ctx.beginPath();ctx.rect(margin,145,width-margin*2,330);ctx.clip();ctx.drawImage(hero,(hero.width-sw)/2,(hero.height-sh)/2,sw,sh,margin,145,width-margin*2,330);ctx.restore()}
      ctx.fillStyle=ink;ctx.font='58px Georgia';ctx.fillText(String(share.title||'My Collection').slice(0,30),margin,550,width-margin*2);
      let y=595;
      if(options.nickname){ctx.fillStyle=muted;ctx.font='19px Arial';ctx.fillText('CURATED BY WATCH ARCHIVE COLLECTOR',margin,y);y+=32}
      if(options.note&&share.description){ctx.fillStyle=muted;ctx.font='18px Georgia';ctx.fillText(String(share.description).slice(0,90),margin,y,width-margin*2);y+=44}
      if(options.count){ctx.fillStyle=muted;ctx.font='16px Arial';ctx.fillText(String(items.length).padStart(2,'0')+' TIMEPIECES',margin,y);y+=28}
      const gap=20,tileW=(width-margin*2-gap)/2,imageH=190,startY=Math.max(700,y+18);
      for(let i=0;i<Math.min(items.length,4);i++){
        const w=items[i],x=margin+(i%2)*(tileW+gap),top=startY+Math.floor(i/2)*270,photo=await loadCanvasImage(w.image_url);
        if(top+imageH+70>height-90)break;
        ctx.fillStyle='#302d29';ctx.fillRect(x,top,tileW,imageH);
        if(photo){const scale=Math.max(tileW/photo.width,imageH/photo.height),sw=tileW/scale,sh=imageH/scale;ctx.save();ctx.beginPath();ctx.rect(x,top,tileW,imageH);ctx.clip();ctx.drawImage(photo,(photo.width-sw)/2,(photo.height-sh)/2,sw,sh,x,top,tileW,imageH);ctx.restore()}
        ctx.fillStyle=muted;ctx.font='15px Arial';ctx.fillText(String(w.brand||'').toUpperCase().slice(0,28),x,top+imageH+25);
        ctx.fillStyle=ink;ctx.font='24px Georgia';ctx.fillText(String(w.model||'').slice(0,25),x,top+imageH+56,tileW);
      }
      ctx.strokeStyle=line;ctx.beginPath();ctx.moveTo(margin,height-70);ctx.lineTo(width-margin,height-70);ctx.stroke();
      ctx.fillStyle=muted;ctx.font='15px Arial';ctx.fillText('A PERSONAL ARCHIVE OF TIMEPIECES',margin,height-38);
    }
    return await new Promise((resolve,reject)=>canvas.toBlob(blob=>blob?resolve(blob):reject(new Error('이미지 생성 실패')),'image/png'));
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
    const coverChoice=overlay.querySelector('input[name="waShareCover"]:checked')?.value||'auto';
    const coverFile=overlay.querySelector('#waShareCoverUpload')?.files?.[0]||null;
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
      if(coverFile){
        const mime=coverFile.type||'image/jpeg',ext=mime.includes('png')?'png':mime.includes('webp')?'webp':'jpg';
        const path=currentUser.id+'/'+token+'/hero-'+crypto.randomUUID()+'.'+ext;
        const {error:uploadError}=await supabaseClient.storage.from(bucket).upload(path,coverFile,{contentType:mime,cacheControl:'31536000',upsert:false});
        if(uploadError)throw uploadError;
        coverUrl=supabaseClient.storage.from(bucket).getPublicUrl(path).data.publicUrl;
      } else if(coverChoice!=='auto'){
        const coverIndex=selected.findIndex(x=>x.item.id===coverChoice);
        coverUrl=publicWatches[coverIndex]?.image_url||'';
      } else if(box.cover_image_path)coverUrl=await uploadPublicCopy(box.cover_image_path,token,'cover');
      else {
        const coverIndex=Math.max(0,selected.findIndex(x=>x.watch.id===box.cover_watch_id));
        coverUrl=publicWatches[coverIndex]?.image_url||publicWatches[0]?.image_url||'';
      }
      const collectorName=currentUser.user_metadata?.nickname||currentUser.user_metadata?.full_name||currentUser.email?.split('@')[0]||'WATCH ARCHIVE COLLECTOR';
      const coverSource=coverChoice==='keep'?(old?.cover_source||'upload'):coverFile?'upload':coverChoice!=='auto'?'watch':box.cover_image_path?'box':'watch';
      const coverSourcePath=coverChoice==='keep'?(old?.cover_source_path||null):coverFile?null:coverChoice!=='auto'?coverChoice:box.cover_image_path||box.cover_watch_id||null;
      const payload={user_id:currentUser.id,box_id:boxId,token,title:title.slice(0,80),description:description.slice(0,500),collector_name:String(collectorName).slice(0,60),cover_image_url:coverUrl,cover_source:coverSource,cover_source_path:coverSourcePath,watch_items:publicWatches,is_active:true,updated_at:new Date().toISOString()};
      let result;
      if(old?.id)result=await supabaseClient.from('collection_shares').update(payload).eq('id',old.id).eq('user_id',currentUser.id).select().single();
      else result=await supabaseClient.from('collection_shares').insert(payload).select().single();
      if(result.error)throw result.error;
      oldUrls.filter(url=>!(coverChoice==='keep'&&url===(old?.cover_image_url||overlay.dataset.existingCoverUrl))).forEach(url=>{const path=publicPath(url);if(path)supabaseClient.storage.from(bucket).remove([path]).then(({error})=>{if(error)console.warn('Share image cleanup failed',error)})});
      toast('컬렉션 공유 링크를 만들었어요');
      openCollectionSharePreview(result.data,boxId);
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
  window.openCollectionShareModal=openCollectionShareModal;
  window.openCollectionSharePreview=openCollectionSharePreview;
  if(activeBoxId)injectShareButton();
})();