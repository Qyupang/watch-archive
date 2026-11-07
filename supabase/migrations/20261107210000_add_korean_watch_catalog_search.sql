-- Add Korean and alternate-name search support to the shared watch catalog.
-- Search terms are additive metadata; canonical English names and references
-- remain unchanged. Existing personal watch records are not modified.

alter table public.watch_catalog_brands
  add column if not exists search_aliases text[] not null default '{}';
alter table public.watch_catalog_models
  add column if not exists search_aliases text[] not null default '{}';
alter table public.watch_catalog_references
  add column if not exists search_aliases text[] not null default '{}';

-- Common Korean brand spellings and names.
update public.watch_catalog_brands
set search_aliases = array['롤렉스', '로렉스']
where name = 'Rolex';

update public.watch_catalog_brands
set search_aliases = array['오메가']
where name = 'Omega';

update public.watch_catalog_brands
set search_aliases = array['까르띠에', '카르티에']
where name = 'Cartier';

update public.watch_catalog_brands
set search_aliases = array['세이코']
where name = 'Seiko';

update public.watch_catalog_brands
set search_aliases = array['그랜드세이코', '그랜드 세이코']
where name = 'Grand Seiko';

update public.watch_catalog_brands
set search_aliases = array['튜더']
where name = 'Tudor';

update public.watch_catalog_brands
set search_aliases = array['태그호이어', '태그 호이어', '태그']
where name = 'TAG Heuer';

update public.watch_catalog_brands
set search_aliases = array['브라이틀링']
where name = 'Breitling';

update public.watch_catalog_brands
set search_aliases = array['아이더블유씨', 'IWC']
where name = 'IWC';

update public.watch_catalog_brands
set search_aliases = array['예거 르쿨트르', '예거르쿨트르', '예거']
where name = 'Jaeger-LeCoultre';

update public.watch_catalog_brands
set search_aliases = array['제니스']
where name = 'Zenith';

update public.watch_catalog_brands
set search_aliases = array['론진']
where name = 'Longines';

update public.watch_catalog_brands
set search_aliases = array['티쏘', '티소']
where name = 'Tissot';

update public.watch_catalog_brands
set search_aliases = array['해밀턴']
where name = 'Hamilton';

update public.watch_catalog_brands
set search_aliases = array['오리스']
where name = 'Oris';

update public.watch_catalog_brands
set search_aliases = array['파네라이']
where name = 'Panerai';

update public.watch_catalog_brands
set search_aliases = array['브레게']
where name = 'Breguet';

update public.watch_catalog_brands
set search_aliases = array['블랑팡']
where name = 'Blancpain';

update public.watch_catalog_brands
set search_aliases = array['오데마피게', '오데마 피게']
where name = 'Audemars Piguet';

update public.watch_catalog_brands
set search_aliases = array['파텍필립', '파텍 필립']
where name = 'Patek Philippe';

update public.watch_catalog_brands
set search_aliases = array['바쉐론 콘스탄틴', '바쉐론콘스탄틴']
where name = 'Vacheron Constantin';

update public.watch_catalog_brands
set search_aliases = array['랑에운트죄네', '랑에']
where name = 'A. Lange & Söhne';

update public.watch_catalog_brands
set search_aliases = array['위블로']
where name = 'Hublot';

update public.watch_catalog_brands
set search_aliases = array['불가리']
where name = 'Bulgari';

update public.watch_catalog_brands
set search_aliases = array['지라드페리고', '지라드 페리고']
where name = 'Girard-Perregaux';

update public.watch_catalog_brands
set search_aliases = array['쇼파드']
where name = 'Chopard';

update public.watch_catalog_brands
set search_aliases = array['벨앤로스', '벨 앤 로스']
where name = 'Bell & Ross';

update public.watch_catalog_brands
set search_aliases = array['노모스']
where name = 'NOMOS Glashütte';

update public.watch_catalog_brands
set search_aliases = array['진']
where name = 'Sinn';

update public.watch_catalog_brands
set search_aliases = array['시티즌']
where name = 'Citizen';

-- Korean model-family aliases for the most common vintage and core searches.
update public.watch_catalog_models m
set search_aliases = array['오이스터 퍼페츄얼', '오이스터 퍼페추얼']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Oyster Perpetual';

update public.watch_catalog_models m
set search_aliases = array['데이트저스트', '데이저스트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Datejust';

update public.watch_catalog_models m
set search_aliases = array['서브마리너', '섭마']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Submariner';


update public.watch_catalog_models m
set search_aliases = array['gmt마스터', '지엠티 마스터', '펩시']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'GMT-Master';

update public.watch_catalog_models m
set search_aliases = array['스피드마스터', '문워치']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Omega' and m.model_name = 'Speedmaster Professional';

update public.watch_catalog_models m
set search_aliases = array['스피드마스터 리듀스드', '스피드마스터 리듀스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Omega' and m.model_name = 'Speedmaster Reduced';

update public.watch_catalog_models m
set search_aliases = array['씨마스터', '씨마스터 300']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Omega' and m.model_name = 'Seamaster 300';

update public.watch_catalog_models m
set search_aliases = array['컨스틸레이션', '콘스텔레이션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Omega' and m.model_name = 'Constellation';

update public.watch_catalog_models m
set search_aliases = array['포뮬러 원', '포뮬러1', '포뮬러']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = 'Formula 1';

update public.watch_catalog_models m
set search_aliases = array['까레라', '카레라']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = 'Carrera';

update public.watch_catalog_models m
set search_aliases = array['모나코']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = 'Monaco';

update public.watch_catalog_models m
set search_aliases = array['아쿠아레이서']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = 'Aquaracer';

update public.watch_catalog_models m
set search_aliases = array['오타비아']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = 'Autavia';

update public.watch_catalog_models m
set search_aliases = array['62마스', '육이마스', '식스투마스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = '62MAS';

update public.watch_catalog_models m
set search_aliases = array['6105 다이버', '우에무라']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = '6105 Diver';

update public.watch_catalog_models m
set search_aliases = array['터틀', '세이코 터틀']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = '6309 Diver';

update public.watch_catalog_models m
set search_aliases = array['스피드타이머', '스피드 타이머', '포그']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'Speed Timer';

update public.watch_catalog_models m
set search_aliases = array['쿼츠 다이버', '쿼츠다이버']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = '7548 Quartz Diver';

update public.watch_catalog_models m
set search_aliases = array['skx', '에스케이엑스', '세이코 에스케이엑스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'SKX Diver';

-- Additional Korean aliases across frequently searched model families.
update public.watch_catalog_models m
set search_aliases = array['익스플로러']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Explorer';

update public.watch_catalog_models m
set search_aliases = array['익스플로러 2', '익스플로러 투']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Explorer II';

update public.watch_catalog_models m
set search_aliases = array['데이데이트', '데이 데이트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Day-Date';






update public.watch_catalog_models m
set search_aliases = array['링크']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = 'Link';

update public.watch_catalog_models m
set search_aliases = array['프로페셔널']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = 'Professional';

update public.watch_catalog_models m
set search_aliases = array['호이어 다이버', '844 다이버']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = 'Heuer Diver 844';

update public.watch_catalog_models m
set search_aliases = array['천 시리즈', '천번대', '1000 시리즈']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = '1000 Series';

update public.watch_catalog_models m
set search_aliases = array['프로스펙스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'Prospex';

update public.watch_catalog_models m
set search_aliases = array['프레사지']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'Presage';

update public.watch_catalog_models m
set search_aliases = array['알피니스트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'Alpinist';

update public.watch_catalog_models m
set search_aliases = array['내비타이머', '네비타이머']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breitling' and m.model_name = 'Navitimer';

update public.watch_catalog_models m
set search_aliases = array['크로노맷']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breitling' and m.model_name = 'Chronomat';

update public.watch_catalog_models m
set search_aliases = array['슈퍼오션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breitling' and m.model_name = 'Superocean';

update public.watch_catalog_models m
set search_aliases = array['블랙베이', '블랙 베이']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tudor' and m.model_name = 'Black Bay';

update public.watch_catalog_models m
set search_aliases = array['펠라고스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tudor' and m.model_name = 'Pelagos';

update public.watch_catalog_models m
set search_aliases = array['탱크']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Cartier' and m.model_name = 'Tank';

update public.watch_catalog_models m
set search_aliases = array['산토스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Cartier' and m.model_name = 'Santos';

update public.watch_catalog_models m
set search_aliases = array['리베르소']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Jaeger-LeCoultre' and m.model_name = 'Reverso';

-- Curated Korean names for additional catalog families.
-- Aliases are limited to established Korean usage or clear transliterations;
-- obscure/ambiguous names are intentionally left searchable by their canonical names.
update public.watch_catalog_models m
set search_aliases = array['딥씨', '딥씨드']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Deepsea';

update public.watch_catalog_models m
set search_aliases = array['씨드웰러', '씨 드웰러']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Sea-Dweller';

update public.watch_catalog_models m
set search_aliases = array['데이토나']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Cosmograph Daytona';

update public.watch_catalog_models m
set search_aliases = array['씨마스터 다이버 300', '씨마스터 300m', '다이버 300m']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Omega' and m.model_name = 'Seamaster Diver 300M';

update public.watch_catalog_models m
set search_aliases = array['아쿠아테라', '아쿠아 테라']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Omega' and m.model_name = 'Seamaster Aqua Terra';

update public.watch_catalog_models m
set search_aliases = array['플래닛오션', '플래닛 오션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Omega' and m.model_name = 'Seamaster Planet Ocean';

update public.watch_catalog_models m
set search_aliases = array['드빌', '드 빌']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Omega' and m.model_name = 'De Ville';

update public.watch_catalog_models m
set search_aliases = array['레일마스터']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Omega' and m.model_name = 'Railmaster';

update public.watch_catalog_models m
set search_aliases = array['글로브마스터']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Omega' and m.model_name = 'Globemaster';

update public.watch_catalog_models m
set search_aliases = array['팬더', '팬테르']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Cartier' and m.model_name = 'Panthère';

update public.watch_catalog_models m
set search_aliases = array['발롱블루', '발롱 블루']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Cartier' and m.model_name = 'Ballon Bleu';

update public.watch_catalog_models m
set search_aliases = array['파샤']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Cartier' and m.model_name = 'Pasha';

update public.watch_catalog_models m
set search_aliases = array['롱드 드 까르띠에', '롱드']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Cartier' and m.model_name = 'Ronde de Cartier';

update public.watch_catalog_models m
set search_aliases = array['베누아']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Cartier' and m.model_name = 'Baignoire';

update public.watch_catalog_models m
set search_aliases = array['끌레 드 까르띠에', '끌레']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Cartier' and m.model_name = 'Clé de Cartier';

update public.watch_catalog_models m
set search_aliases = array['세이코5 스포츠', '세이코 파이브 스포츠']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'Seiko 5 Sports';

update public.watch_catalog_models m
set search_aliases = array['킹세이코', '킹 세이코']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'King Seiko';

update public.watch_catalog_models m
set search_aliases = array['아스트론']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'Astron';

update public.watch_catalog_models m
set search_aliases = array['튜나', '터나', '세이코 튜나']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'Prospex Tuna';

update public.watch_catalog_models m
set search_aliases = array['몬스터', '세이코 몬스터']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'Prospex Monster';

update public.watch_catalog_models m
set search_aliases = array['돌체']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'Dolce';

update public.watch_catalog_models m
set search_aliases = array['크레도르']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Seiko' and m.model_name = 'Credor';

update public.watch_catalog_models m
set search_aliases = array['헤리티지 컬렉션', '헤리티지']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Grand Seiko' and m.model_name = 'Heritage Collection';

update public.watch_catalog_models m
set search_aliases = array['엘레강스 컬렉션', '엘레강스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Grand Seiko' and m.model_name = 'Elegance Collection';

update public.watch_catalog_models m
set search_aliases = array['스포츠 컬렉션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Grand Seiko' and m.model_name = 'Sport Collection';

update public.watch_catalog_models m
set search_aliases = array['에볼루션 9', '에볼루션나인']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Grand Seiko' and m.model_name = 'Evolution 9 Collection';

update public.watch_catalog_models m
set search_aliases = array['하이비트', '하이비트 36000', '메카니컬 하이비트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Grand Seiko' and m.model_name = 'Mechanical Hi-Beat 36000';

update public.watch_catalog_models m
set search_aliases = array['스프링드라이브', '스프링 드라이브']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Grand Seiko' and m.model_name = 'Spring Drive';

update public.watch_catalog_models m
set search_aliases = array['쿼츠']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Grand Seiko' and m.model_name = 'Quartz';

update public.watch_catalog_models m
set search_aliases = array['마스터피스 컬렉션', '마스터피스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Grand Seiko' and m.model_name = 'Masterpiece Collection';

update public.watch_catalog_models m
set search_aliases = array['엘레강스 GMT']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Grand Seiko' and m.model_name = 'Elegance GMT';

update public.watch_catalog_models m
set search_aliases = array['헤리티지 GMT']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Grand Seiko' and m.model_name = 'Heritage GMT';

update public.watch_catalog_models m
set search_aliases = array['튜더 1926']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tudor' and m.model_name = '1926';

update public.watch_catalog_models m
set search_aliases = array['로얄']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tudor' and m.model_name = 'Royal';

update public.watch_catalog_models m
set search_aliases = array['레인저']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tudor' and m.model_name = 'Ranger';

update public.watch_catalog_models m
set search_aliases = array['블랙베이 58', '블랙 베이 58', 'BB58']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tudor' and m.model_name = 'Black Bay 58';

update public.watch_catalog_models m
set search_aliases = array['블랙베이 54', 'BB54']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tudor' and m.model_name = 'Black Bay 54';

update public.watch_catalog_models m
set search_aliases = array['블랙베이 크로노', '블랙베이 크로노그래프']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tudor' and m.model_name = 'Black Bay Chrono';

update public.watch_catalog_models m
set search_aliases = array['블랙베이 GMT', '블랙베이 지엠티']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tudor' and m.model_name = 'Black Bay GMT';

update public.watch_catalog_models m
set search_aliases = array['노스플래그', '노스 플래그']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tudor' and m.model_name = 'North Flag';

update public.watch_catalog_models m
set search_aliases = array['2000 시리즈', '2000 시리즈']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = '2000 Series';

update public.watch_catalog_models m
set search_aliases = array['6000 시리즈']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = '6000 Series';

update public.watch_catalog_models m
set search_aliases = array['키리움']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'TAG Heuer' and m.model_name = 'Kirium';

update public.watch_catalog_models m
set search_aliases = array['슈퍼오션 헤리티지']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breitling' and m.model_name = 'Superocean Heritage';

update public.watch_catalog_models m
set search_aliases = array['어벤저', '어벤져']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breitling' and m.model_name = 'Avenger';

update public.watch_catalog_models m
set search_aliases = array['프리미에르']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breitling' and m.model_name = 'Premier';

update public.watch_catalog_models m
set search_aliases = array['탑타임', '탑 타임']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breitling' and m.model_name = 'Top Time';

update public.watch_catalog_models m
set search_aliases = array['트랜스오션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breitling' and m.model_name = 'Transocean';

update public.watch_catalog_models m
set search_aliases = array['콜트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breitling' and m.model_name = 'Colt';

update public.watch_catalog_models m
set search_aliases = array['이머전시']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breitling' and m.model_name = 'Emergency';

update public.watch_catalog_models m
set search_aliases = array['파일럿 워치', '파일럿워치', '마크 시리즈']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'IWC' and m.model_name = 'Pilot''s Watch';

update public.watch_catalog_models m
set search_aliases = array['포르투기저', '포르투기저']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'IWC' and m.model_name = 'Portugieser';

update public.watch_catalog_models m
set search_aliases = array['포르토피노']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'IWC' and m.model_name = 'Portofino';

update public.watch_catalog_models m
set search_aliases = array['인제니어']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'IWC' and m.model_name = 'Ingenieur';

update public.watch_catalog_models m
set search_aliases = array['아쿠아타이머']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'IWC' and m.model_name = 'Aquatimer';

update public.watch_catalog_models m
set search_aliases = array['다빈치']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'IWC' and m.model_name = 'Da Vinci';

update public.watch_catalog_models m
set search_aliases = array['요트 클럽']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'IWC' and m.model_name = 'Yacht Club';

update public.watch_catalog_models m
set search_aliases = array['지에스티']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'IWC' and m.model_name = 'GST';

update public.watch_catalog_models m
set search_aliases = array['포르쉐 디자인']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'IWC' and m.model_name = 'Porsche Design';

update public.watch_catalog_models m
set search_aliases = array['인제니어 SL']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'IWC' and m.model_name = 'Ingenieur SL';

update public.watch_catalog_models m
set search_aliases = array['마스터 컨트롤']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Jaeger-LeCoultre' and m.model_name = 'Master Control';

update public.watch_catalog_models m
set search_aliases = array['마스터 울트라 씬', '울트라 씬']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Jaeger-LeCoultre' and m.model_name = 'Master Ultra Thin';

update public.watch_catalog_models m
set search_aliases = array['폴라리스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Jaeger-LeCoultre' and m.model_name = 'Polaris';

update public.watch_catalog_models m
set search_aliases = array['랑데부']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Jaeger-LeCoultre' and m.model_name = 'Rendez-Vous';

update public.watch_catalog_models m
set search_aliases = array['듀오미터']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Jaeger-LeCoultre' and m.model_name = 'Duomètre';

update public.watch_catalog_models m
set search_aliases = array['지오피직']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Jaeger-LeCoultre' and m.model_name = 'Geophysic';

update public.watch_catalog_models m
set search_aliases = array['메모복스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Jaeger-LeCoultre' and m.model_name = 'Memovox';

update public.watch_catalog_models m
set search_aliases = array['아트모스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Jaeger-LeCoultre' and m.model_name = 'Atmos';

update public.watch_catalog_models m
set search_aliases = array['마스터 컴프레서']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Jaeger-LeCoultre' and m.model_name = 'Master Compressor';

update public.watch_catalog_models m
set search_aliases = array['크로노마스터']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Zenith' and m.model_name = 'Chronomaster';

update public.watch_catalog_models m
set search_aliases = array['데피']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Zenith' and m.model_name = 'Defy';

update public.watch_catalog_models m
set search_aliases = array['엘리트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Zenith' and m.model_name = 'Elite';

update public.watch_catalog_models m
set search_aliases = array['파일럿']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Zenith' and m.model_name = 'Pilot';

update public.watch_catalog_models m
set search_aliases = array['포트 로얄']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Zenith' and m.model_name = 'Port Royal';

update public.watch_catalog_models m
set search_aliases = array['아카데미']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Zenith' and m.model_name = 'Academy';

update public.watch_catalog_models m
set search_aliases = array['캡틴']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Zenith' and m.model_name = 'Captain';

update public.watch_catalog_models m
set search_aliases = array['레인보우']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Zenith' and m.model_name = 'Rainbow';

update public.watch_catalog_models m
set search_aliases = array['뉴 빈티지 1969']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Zenith' and m.model_name = 'New Vintage 1969';

update public.watch_catalog_models m
set search_aliases = array['레스피레이터']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Zenith' and m.model_name = 'Respirator';

update public.watch_catalog_models m
set search_aliases = array['마스터 컬렉션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Longines' and m.model_name = 'Master Collection';

update public.watch_catalog_models m
set search_aliases = array['콩퀘스트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Longines' and m.model_name = 'Conquest';

update public.watch_catalog_models m
set search_aliases = array['하이드로콘퀘스트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Longines' and m.model_name = 'HydroConquest';

update public.watch_catalog_models m
set search_aliases = array['스피릿']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Longines' and m.model_name = 'Spirit';

update public.watch_catalog_models m
set search_aliases = array['레전드 다이버']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Longines' and m.model_name = 'Legend Diver';

update public.watch_catalog_models m
set search_aliases = array['헤리티지 클래식']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Longines' and m.model_name = 'Heritage Classic';

update public.watch_catalog_models m
set search_aliases = array['돌체비타']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Longines' and m.model_name = 'DolceVita';

update public.watch_catalog_models m
set search_aliases = array['라 그랑드 클래식']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Longines' and m.model_name = 'La Grande Classique';

update public.watch_catalog_models m
set search_aliases = array['플래그십']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Longines' and m.model_name = 'Flagship';

update public.watch_catalog_models m
set search_aliases = array['에비덴자']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Longines' and m.model_name = 'Evidenza';

update public.watch_catalog_models m
set search_aliases = array['티쏘 PRX', '피알엑스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tissot' and m.model_name = 'PRX';

update public.watch_catalog_models m
set search_aliases = array['씨스타']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tissot' and m.model_name = 'Seastar';

update public.watch_catalog_models m
set search_aliases = array['르 로끌', '르로끌']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tissot' and m.model_name = 'Le Locle';

update public.watch_catalog_models m
set search_aliases = array['젠틀맨']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tissot' and m.model_name = 'Gentleman';

update public.watch_catalog_models m
set search_aliases = array['슈망 데 뚜렐', '슈망 데 투렐']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tissot' and m.model_name = 'Chemin des Tourelles';

update public.watch_catalog_models m
set search_aliases = array['티터치', 'T 터치']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tissot' and m.model_name = 'T-Touch';

update public.watch_catalog_models m
set search_aliases = array['비소데이트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tissot' and m.model_name = 'Visodate';

update public.watch_catalog_models m
set search_aliases = array['발라드']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tissot' and m.model_name = 'Ballade';

update public.watch_catalog_models m
set search_aliases = array['카키 필드']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hamilton' and m.model_name = 'Khaki Field';

update public.watch_catalog_models m
set search_aliases = array['카키 에비에이션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hamilton' and m.model_name = 'Khaki Aviation';

update public.watch_catalog_models m
set search_aliases = array['카키 네이비']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hamilton' and m.model_name = 'Khaki Navy';

update public.watch_catalog_models m
set search_aliases = array['재즈마스터']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hamilton' and m.model_name = 'Jazzmaster';

update public.watch_catalog_models m
set search_aliases = array['벤츄라']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hamilton' and m.model_name = 'Ventura';

update public.watch_catalog_models m
set search_aliases = array['아메리칸 클래식']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hamilton' and m.model_name = 'American Classic';

update public.watch_catalog_models m
set search_aliases = array['인트라매틱']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hamilton' and m.model_name = 'Intra-Matic';

update public.watch_catalog_models m
set search_aliases = array['브로드웨이']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hamilton' and m.model_name = 'Broadway';

update public.watch_catalog_models m
set search_aliases = array['볼튼']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hamilton' and m.model_name = 'Boulton';

update public.watch_catalog_models m
set search_aliases = array['아드모어']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hamilton' and m.model_name = 'Ardmore';

update public.watch_catalog_models m
set search_aliases = array['애커스', '아퀴스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Oris' and m.model_name = 'Aquis';

update public.watch_catalog_models m
set search_aliases = array['빅크라운', '빅 크라운']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Oris' and m.model_name = 'Big Crown';

update public.watch_catalog_models m
set search_aliases = array['다이버즈']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Oris' and m.model_name = 'Divers';

update public.watch_catalog_models m
set search_aliases = array['프로파일럿']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Oris' and m.model_name = 'ProPilot';

update public.watch_catalog_models m
set search_aliases = array['아뜰리에', '아틀리에']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Oris' and m.model_name = 'Artelier';

update public.watch_catalog_models m
set search_aliases = array['렉탱귤러']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Oris' and m.model_name = 'Rectangular';

update public.watch_catalog_models m
set search_aliases = array['윌리엄스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Oris' and m.model_name = 'Williams';

update public.watch_catalog_models m
set search_aliases = array['크로노리스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Oris' and m.model_name = 'Chronoris';

update public.watch_catalog_models m
set search_aliases = array['루미노르']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Panerai' and m.model_name = 'Luminor';

update public.watch_catalog_models m
set search_aliases = array['루미노르 마리나']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Panerai' and m.model_name = 'Luminor Marina';

update public.watch_catalog_models m
set search_aliases = array['루미노르 두에']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Panerai' and m.model_name = 'Luminor Due';

update public.watch_catalog_models m
set search_aliases = array['라디오미르']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Panerai' and m.model_name = 'Radiomir';

update public.watch_catalog_models m
set search_aliases = array['섭머저블', '서브머저블']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Panerai' and m.model_name = 'Submersible';

update public.watch_catalog_models m
set search_aliases = array['마레 노스트럼']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Panerai' and m.model_name = 'Mare Nostrum';

update public.watch_catalog_models m
set search_aliases = array['루미노르 1950']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Panerai' and m.model_name = 'Luminor 1950';

update public.watch_catalog_models m
set search_aliases = array['라디오미르 1940']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Panerai' and m.model_name = 'Radiomir 1940';

update public.watch_catalog_models m
set search_aliases = array['루미노르 크로노']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Panerai' and m.model_name = 'Luminor Chrono';

update public.watch_catalog_models m
set search_aliases = array['페라리']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Panerai' and m.model_name = 'Ferrari';

update public.watch_catalog_models m
set search_aliases = array['클래식']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breguet' and m.model_name = 'Classique';

update public.watch_catalog_models m
set search_aliases = array['마린']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breguet' and m.model_name = 'Marine';

update public.watch_catalog_models m
set search_aliases = array['타입 20', '타입 XX']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breguet' and m.model_name = 'Type XX';

update public.watch_catalog_models m
set search_aliases = array['타입 21', '타입 XXI']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breguet' and m.model_name = 'Type XXI';

update public.watch_catalog_models m
set search_aliases = array['타입 22', '타입 XXII']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breguet' and m.model_name = 'Type XXII';

update public.watch_catalog_models m
set search_aliases = array['트래디션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breguet' and m.model_name = 'Tradition';

update public.watch_catalog_models m
set search_aliases = array['레인 드 네이플']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breguet' and m.model_name = 'Reine de Naples';

update public.watch_catalog_models m
set search_aliases = array['헤리티지']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breguet' and m.model_name = 'Héritage';

update public.watch_catalog_models m
set search_aliases = array['라 뮤지칼']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breguet' and m.model_name = 'La Musicale';

update public.watch_catalog_models m
set search_aliases = array['오라 문디']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Breguet' and m.model_name = 'Hora Mundi';

update public.watch_catalog_models m
set search_aliases = array['피프티 패덤즈', '피프티패덤즈']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Blancpain' and m.model_name = 'Fifty Fathoms';

update public.watch_catalog_models m
set search_aliases = array['바티스카프']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Blancpain' and m.model_name = 'Bathyscaphe';

update public.watch_catalog_models m
set search_aliases = array['빌레레']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Blancpain' and m.model_name = 'Villeret';

update public.watch_catalog_models m
set search_aliases = array['레망']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Blancpain' and m.model_name = 'Léman';

update public.watch_catalog_models m
set search_aliases = array['에어 커맨드']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Blancpain' and m.model_name = 'Air Command';

update public.watch_catalog_models m
set search_aliases = array['엘 에볼루션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Blancpain' and m.model_name = 'L-Evolution';

update public.watch_catalog_models m
set search_aliases = array['플라이백 크로노그래프']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Blancpain' and m.model_name = 'Chronographe Flyback';

update public.watch_catalog_models m
set search_aliases = array['로열오크', '로얄오크']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Audemars Piguet' and m.model_name = 'Royal Oak';

update public.watch_catalog_models m
set search_aliases = array['로열오크 오프쇼어', '로얄오크 오프쇼어']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Audemars Piguet' and m.model_name = 'Royal Oak Offshore';

update public.watch_catalog_models m
set search_aliases = array['로열오크 컨셉트', '로얄오크 컨셉트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Audemars Piguet' and m.model_name = 'Royal Oak Concept';

update public.watch_catalog_models m
set search_aliases = array['코드 11.59', '코드']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Audemars Piguet' and m.model_name = 'Code 11.59';

update public.watch_catalog_models m
set search_aliases = array['줄 오데마']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Audemars Piguet' and m.model_name = 'Jules Audemars';

update public.watch_catalog_models m
set search_aliases = array['밀리너리']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Audemars Piguet' and m.model_name = 'Millenary';

update public.watch_catalog_models m
set search_aliases = array['에드워드 피게']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Audemars Piguet' and m.model_name = 'Edward Piguet';

update public.watch_catalog_models m
set search_aliases = array['위티엠']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Audemars Piguet' and m.model_name = 'Huitième';

update public.watch_catalog_models m
set search_aliases = array['칼라트라바']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Patek Philippe' and m.model_name = 'Calatrava';

update public.watch_catalog_models m
set search_aliases = array['노틸러스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Patek Philippe' and m.model_name = 'Nautilus';

update public.watch_catalog_models m
set search_aliases = array['아쿠아넛']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Patek Philippe' and m.model_name = 'Aquanaut';

update public.watch_catalog_models m
set search_aliases = array['골든 엘립스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Patek Philippe' and m.model_name = 'Golden Ellipse';

update public.watch_catalog_models m
set search_aliases = array['트웬티포', '트웬티 4']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Patek Philippe' and m.model_name = 'Twenty~4';

update public.watch_catalog_models m
set search_aliases = array['곤돌로']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Patek Philippe' and m.model_name = 'Gondolo';

update public.watch_catalog_models m
set search_aliases = array['큐비터스', '큐비투스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Patek Philippe' and m.model_name = 'Cubitus';

update public.watch_catalog_models m
set search_aliases = array['엘립스 도르']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Patek Philippe' and m.model_name = 'Ellipse d''Or';

update public.watch_catalog_models m
set search_aliases = array['패트리모니']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Vacheron Constantin' and m.model_name = 'Patrimony';

update public.watch_catalog_models m
set search_aliases = array['트래디셔널']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Vacheron Constantin' and m.model_name = 'Traditionnelle';

update public.watch_catalog_models m
set search_aliases = array['오버시즈']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Vacheron Constantin' and m.model_name = 'Overseas';

update public.watch_catalog_models m
set search_aliases = array['피프티식스', '피프티 식스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Vacheron Constantin' and m.model_name = 'Fiftysix';

update public.watch_catalog_models m
set search_aliases = array['히스토리크']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Vacheron Constantin' and m.model_name = 'Historiques';

update public.watch_catalog_models m
set search_aliases = array['말테']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Vacheron Constantin' and m.model_name = 'Malte';

update public.watch_catalog_models m
set search_aliases = array['에제리']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Vacheron Constantin' and m.model_name = 'Égérie';

update public.watch_catalog_models m
set search_aliases = array['로열 이글']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Vacheron Constantin' and m.model_name = 'Royal Eagle';

update public.watch_catalog_models m
set search_aliases = array['랑에 1', '랑에 원']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'A. Lange & Söhne' and m.model_name = 'Lange 1';

update public.watch_catalog_models m
set search_aliases = array['삭소니아']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'A. Lange & Söhne' and m.model_name = 'Saxonia';

update public.watch_catalog_models m
set search_aliases = array['자이트베르크']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'A. Lange & Söhne' and m.model_name = 'Zeitwerk';

update public.watch_catalog_models m
set search_aliases = array['리하르트 랑에']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'A. Lange & Söhne' and m.model_name = 'Richard Lange';

update public.watch_catalog_models m
set search_aliases = array['오디세우스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'A. Lange & Söhne' and m.model_name = 'Odysseus';

update public.watch_catalog_models m
set search_aliases = array['카바레']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'A. Lange & Söhne' and m.model_name = 'Cabaret';

update public.watch_catalog_models m
set search_aliases = array['투르보그라프']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'A. Lange & Söhne' and m.model_name = 'Tourbograph';

update public.watch_catalog_models m
set search_aliases = array['다토그래프']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'A. Lange & Söhne' and m.model_name = 'Datograph';

update public.watch_catalog_models m
set search_aliases = array['랑에마틱']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'A. Lange & Söhne' and m.model_name = 'Langematik';

update public.watch_catalog_models m
set search_aliases = array['클래식 퓨전']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hublot' and m.model_name = 'Classic Fusion';

update public.watch_catalog_models m
set search_aliases = array['빅뱅']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hublot' and m.model_name = 'Big Bang';

update public.watch_catalog_models m
set search_aliases = array['스피릿 오브 빅뱅']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hublot' and m.model_name = 'Spirit of Big Bang';

update public.watch_catalog_models m
set search_aliases = array['킹파워', '킹 파워']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hublot' and m.model_name = 'King Power';

update public.watch_catalog_models m
set search_aliases = array['빅뱅 유니코']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hublot' and m.model_name = 'Big Bang Unico';

update public.watch_catalog_models m
set search_aliases = array['빅뱅 인테그랄']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hublot' and m.model_name = 'Big Bang Integral';

update public.watch_catalog_models m
set search_aliases = array['빅뱅 메카 10', '메카10']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hublot' and m.model_name = 'Big Bang Meca-10';

update public.watch_catalog_models m
set search_aliases = array['클래식 오리지널']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hublot' and m.model_name = 'Classic Original';

update public.watch_catalog_models m
set search_aliases = array['옥토']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bulgari' and m.model_name = 'Octo';

update public.watch_catalog_models m
set search_aliases = array['옥토 피니씨모', '옥토 피니시모']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bulgari' and m.model_name = 'Octo Finissimo';

update public.watch_catalog_models m
set search_aliases = array['세르펜티']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bulgari' and m.model_name = 'Serpenti';

update public.watch_catalog_models m
set search_aliases = array['불가리 불가리']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bulgari' and m.model_name = 'Bulgari Bulgari';

update public.watch_catalog_models m
set search_aliases = array['디아고노']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bulgari' and m.model_name = 'Diagono';

update public.watch_catalog_models m
set search_aliases = array['알루미늄']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bulgari' and m.model_name = 'Aluminium';

update public.watch_catalog_models m
set search_aliases = array['루체아']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bulgari' and m.model_name = 'Lvcea';

update public.watch_catalog_models m
set search_aliases = array['아시오마']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bulgari' and m.model_name = 'Assioma';

update public.watch_catalog_models m
set search_aliases = array['에르곤']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bulgari' and m.model_name = 'Ergon';

update public.watch_catalog_models m
set search_aliases = array['파피용']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bulgari' and m.model_name = 'Papillon';

update public.watch_catalog_models m
set search_aliases = array['로레아토']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Girard-Perregaux' and m.model_name = 'Laureato';

update public.watch_catalog_models m
set search_aliases = array['브릿지']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Girard-Perregaux' and m.model_name = 'Bridges';

update public.watch_catalog_models m
set search_aliases = array['캣츠아이', '캣츠 아이']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Girard-Perregaux' and m.model_name = 'Cat''s Eye';

update public.watch_catalog_models m
set search_aliases = array['빈티지 1945']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Girard-Perregaux' and m.model_name = 'Vintage 1945';

update public.watch_catalog_models m
set search_aliases = array['씨호크', '씨 호크']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Girard-Perregaux' and m.model_name = 'Sea Hawk';

update public.watch_catalog_models m
set search_aliases = array['리치빌']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Girard-Perregaux' and m.model_name = 'Richeville';

update public.watch_catalog_models m
set search_aliases = array['알파인 이글']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Chopard' and m.model_name = 'Alpine Eagle';

update public.watch_catalog_models m
set search_aliases = array['밀레밀리아', '밀레 밀리아']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Chopard' and m.model_name = 'Mille Miglia';

update public.watch_catalog_models m
set search_aliases = array['해피 스포츠']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Chopard' and m.model_name = 'Happy Sport';

update public.watch_catalog_models m
set search_aliases = array['해피 다이아몬드']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Chopard' and m.model_name = 'Happy Diamonds';

update public.watch_catalog_models m
set search_aliases = array['임페리얼']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Chopard' and m.model_name = 'Imperiale';

update public.watch_catalog_models m
set search_aliases = array['세인트 모리츠']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Chopard' and m.model_name = 'St. Moritz';

update public.watch_catalog_models m
set search_aliases = array['아이스 큐브']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Chopard' and m.model_name = 'Ice Cube';

update public.watch_catalog_models m
set search_aliases = array['BR01', '비알 01']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bell & Ross' and m.model_name = 'BR 01';

update public.watch_catalog_models m
set search_aliases = array['BR03', '비알 03']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bell & Ross' and m.model_name = 'BR 03';

update public.watch_catalog_models m
set search_aliases = array['BR05', '비알 05']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bell & Ross' and m.model_name = 'BR 05';

update public.watch_catalog_models m
set search_aliases = array['BRX5', '비알 엑스파이브']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bell & Ross' and m.model_name = 'BR X5';

update public.watch_catalog_models m
set search_aliases = array['빈티지']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bell & Ross' and m.model_name = 'Vintage';

update public.watch_catalog_models m
set search_aliases = array['에비에이션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bell & Ross' and m.model_name = 'Aviation';

update public.watch_catalog_models m
set search_aliases = array['마린']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bell & Ross' and m.model_name = 'Marine';

update public.watch_catalog_models m
set search_aliases = array['인스트루먼트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Bell & Ross' and m.model_name = 'Instruments';

update public.watch_catalog_models m
set search_aliases = array['탕겐테']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'NOMOS Glashütte' and m.model_name = 'Tangente';

update public.watch_catalog_models m
set search_aliases = array['오리온']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'NOMOS Glashütte' and m.model_name = 'Orion';

update public.watch_catalog_models m
set search_aliases = array['루드비히']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'NOMOS Glashütte' and m.model_name = 'Ludwig';

update public.watch_catalog_models m
set search_aliases = array['테트라']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'NOMOS Glashütte' and m.model_name = 'Tetra';

update public.watch_catalog_models m
set search_aliases = array['클럽']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'NOMOS Glashütte' and m.model_name = 'Club';

update public.watch_catalog_models m
set search_aliases = array['메트로']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'NOMOS Glashütte' and m.model_name = 'Metro';

update public.watch_catalog_models m
set search_aliases = array['아호이']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'NOMOS Glashütte' and m.model_name = 'Ahoi';

update public.watch_catalog_models m
set search_aliases = array['람다']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'NOMOS Glashütte' and m.model_name = 'Lambda';

update public.watch_catalog_models m
set search_aliases = array['룩스']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'NOMOS Glashütte' and m.model_name = 'Lux';

update public.watch_catalog_models m
set search_aliases = array['미니마틱']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'NOMOS Glashütte' and m.model_name = 'Minimatik';

update public.watch_catalog_models m
set search_aliases = array['더 시티즌']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Citizen' and m.model_name = 'The Citizen';

update public.watch_catalog_models m
set search_aliases = array['크로노마스터']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Citizen' and m.model_name = 'Chronomaster';

update public.watch_catalog_models m
set search_aliases = array['프로마스터']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Citizen' and m.model_name = 'Promaster';

update public.watch_catalog_models m
set search_aliases = array['시리즈 8', '시리즈8']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Citizen' and m.model_name = 'Series 8';

update public.watch_catalog_models m
set search_aliases = array['아테사']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Citizen' and m.model_name = 'Attesa';

update public.watch_catalog_models m
set search_aliases = array['에코드라이브 원', '에코 드라이브 원']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Citizen' and m.model_name = 'Eco-Drive One';

update public.watch_catalog_models m
set search_aliases = array['추요사', '쯔요사']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Citizen' and m.model_name = 'Tsuyosa';

update public.watch_catalog_models m
set search_aliases = array['캄파놀라']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Citizen' and m.model_name = 'Campanola';

update public.watch_catalog_models m
set search_aliases = array['슈퍼 티타늄']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Citizen' and m.model_name = 'Super Titanium';

-- Additional well-established Korean names for selected dress and complication lines.
update public.watch_catalog_models m
set search_aliases = array['드라이브 드 까르띠에', '드라이브']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Cartier' and m.model_name = 'Drive de Cartier';

update public.watch_catalog_models m
set search_aliases = array['쿠생']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Cartier' and m.model_name = 'Coussin';

update public.watch_catalog_models m
set search_aliases = array['헤리티지']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tissot' and m.model_name = 'Heritage';

update public.watch_catalog_models m
set search_aliases = array['PR100', '피알 100']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Tissot' and m.model_name = 'PR 100';

update public.watch_catalog_models m
set search_aliases = array['그랑드 더블 소네리']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Blancpain' and m.model_name = 'Grande Double Sonnerie';

update public.watch_catalog_models m
set search_aliases = array['트래디션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Audemars Piguet' and m.model_name = 'Tradition';

update public.watch_catalog_models m
set search_aliases = array['클래식']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Audemars Piguet' and m.model_name = 'Classique';

update public.watch_catalog_models m
set search_aliases = array['컴플리케이션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Patek Philippe' and m.model_name = 'Complications';

update public.watch_catalog_models m
set search_aliases = array['그랜드 컴플리케이션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Patek Philippe' and m.model_name = 'Grand Complications';

update public.watch_catalog_models m
set search_aliases = array['MP 컬렉션', '엠피 컬렉션']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hublot' and m.model_name = 'MP Collection';

update public.watch_catalog_models m
set search_aliases = array['엘레강트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Hublot' and m.model_name = 'Elegant';

update public.watch_catalog_models m
set search_aliases = array['엘유씨']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Chopard' and m.model_name = 'L.U.C';

update public.watch_catalog_models m
set search_aliases = array['클래식 레이싱']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Chopard' and m.model_name = 'Classic Racing';

update public.watch_catalog_models m
set search_aliases = array['뢰르 뒤 디아망']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Chopard' and m.model_name = 'L''Heure du Diamant';

-- Reference-specific nicknames and Korean forms.
update public.watch_catalog_references r
set search_aliases = array['슈마허', '슈마허 레드', '스피드마스터 슈마허', '레드 다이얼']
from public.watch_catalog_models m
join public.watch_catalog_brands b on b.id = m.brand_id
where r.model_id = m.id and b.name = 'Omega'
  and r.reference_number = '3510.61.00';

update public.watch_catalog_references r
set search_aliases = array['에드 화이트', '에드화이트']
from public.watch_catalog_models m
join public.watch_catalog_brands b on b.id = m.brand_id
where r.model_id = m.id and b.name = 'Omega'
  and r.reference_number = '105.003';

update public.watch_catalog_references r
set search_aliases = array['문워치', '프리문']
from public.watch_catalog_models m
join public.watch_catalog_brands b on b.id = m.brand_id
where r.model_id = m.id and b.name = 'Omega'
  and r.reference_number in ('105.012', '145.012');

update public.watch_catalog_references r
set search_aliases = array['포그', '파오그']
from public.watch_catalog_models m
join public.watch_catalog_brands b on b.id = m.brand_id
where r.model_id = m.id and b.name = 'Seiko'
  and r.reference_number = '6139-6002';

drop function if exists public.search_watch_catalog(text, integer);

create function public.search_watch_catalog(p_query text, p_limit integer default 20)
returns table (
  id uuid,
  model_id uuid,
  brand_name text,
  collection_name text,
  model_name text,
  reference_number text,
  variant_name text,
  dial_variant text,
  case_diameter_mm numeric,
  thickness_mm numeric,
  lug_to_lug_mm numeric,
  movement text,
  caliber text,
  case_material text,
  crystal text,
  production_start smallint,
  production_end smallint,
  image_url text,
  verification_status text
)
language sql
stable
security invoker
set search_path = public
as $$
  with query_tokens as (
    select token
    from unnest(regexp_split_to_array(lower(trim(p_query)), '[[:space:]]+')) as tokens(token)
    where token <> ''
  )
  select
    r.id,
    m.id,
    b.name,
    m.collection_name,
    m.model_name,
    r.reference_number,
    r.variant_name,
    r.dial_variant,
    r.case_diameter_mm,
    r.thickness_mm,
    r.lug_to_lug_mm,
    r.movement,
    r.caliber,
    r.case_material,
    r.crystal,
    coalesce(r.production_start, m.production_start),
    coalesce(r.production_end, m.production_end),
    r.image_url,
    coalesce(r.verification_status, m.verification_status)
  from public.watch_catalog_models m
  join public.watch_catalog_brands b on b.id = m.brand_id
  left join public.watch_catalog_references r on r.model_id = m.id
  where nullif(trim(p_query), '') is not null
    and exists (select 1 from query_tokens)
    and not exists (
      select 1
      from query_tokens q
      where not (
        b.name ilike '%' || q.token || '%'
        or m.model_name ilike '%' || q.token || '%'
        or coalesce(m.collection_name, '') ilike '%' || q.token || '%'
        or coalesce(r.reference_number, '') ilike '%' || q.token || '%'
        or (
          length(regexp_replace(q.token, '[^0-9]', '', 'g')) >= 4
          and regexp_replace(coalesce(r.reference_number, ''), '[^0-9]', '', 'g') like '%' || regexp_replace(q.token, '[^0-9]', '', 'g') || '%'
        )
        or coalesce(r.variant_name, '') ilike '%' || q.token || '%'
        or coalesce(r.dial_variant, '') ilike '%' || q.token || '%'
        or coalesce(r.caliber, '') ilike '%' || q.token || '%'
        or exists (select 1 from unnest(b.search_aliases) a where lower(a) like '%' || q.token || '%')
        or exists (select 1 from unnest(m.search_aliases) a where lower(a) like '%' || q.token || '%')
        or exists (select 1 from unnest(r.search_aliases) a where lower(a) like '%' || q.token || '%')
      )
    )
  order by
    case
      when r.reference_number is not null
       and regexp_replace(r.reference_number, '[^0-9]', '', 'g') <> ''
       and exists (
         select 1 from query_tokens q
         where length(regexp_replace(q.token, '[^0-9]', '', 'g')) >= 4
           and regexp_replace(r.reference_number, '[^0-9]', '', 'g') = regexp_replace(q.token, '[^0-9]', '', 'g')
       ) then 0
      when lower(coalesce(r.reference_number, '')) = lower(trim(p_query)) then 0
      when exists (select 1 from query_tokens q where lower(m.model_name) = q.token) then 1
      when exists (
        select 1 from query_tokens q
        where exists (select 1 from unnest(m.search_aliases) a where lower(a) = q.token)
      ) then 2
      when exists (
        select 1 from query_tokens q
        where exists (select 1 from unnest(r.search_aliases) a where lower(a) = q.token)
      ) then 2
      when lower(m.model_name) = lower(trim(p_query)) then 2
      when lower(b.name) = lower(trim(p_query)) then 3
      else 4
    end,
    b.name, m.model_name, r.reference_number nulls first
  limit greatest(1, least(coalesce(p_limit, 20), 50));
$$;

revoke all on function public.search_watch_catalog(text, integer) from public, anon;
grant execute on function public.search_watch_catalog(text, integer) to authenticated;
