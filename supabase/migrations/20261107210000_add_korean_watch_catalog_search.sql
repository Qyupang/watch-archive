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
set search_aliases = array['데이데이트', '데이 데이트']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Day-Date';

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
set search_aliases = array['씨드웰러', '씨 드웰러']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Sea-Dweller';

update public.watch_catalog_models m
set search_aliases = array['데이토나']
from public.watch_catalog_brands b
where m.brand_id = b.id and b.name = 'Rolex' and m.model_name = 'Cosmograph Daytona';

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
        or coalesce(r.variant_name, '') ilike '%' || q.token || '%'
        or coalesce(r.dial_variant, '') ilike '%' || q.token || '%'
        or coalesce(r.caliber, '') ilike '%' || q.token || '%'
        or exists (select 1 from unnest(b.search_aliases) a where lower(a) like '%' || q.token || '%')
        or exists (select 1 from unnest(m.search_aliases) a where lower(a) like '%' || q.token || '%')
        or exists (select 1 from unnest(r.search_aliases) a where lower(a) like '%' || q.token || '%')
      )
    )
  order by
    case when lower(coalesce(r.reference_number, '')) = lower(trim(p_query)) then 0
         when lower(m.model_name) = lower(trim(p_query)) then 1
         when exists (select 1 from unnest(r.search_aliases) a where lower(a) = lower(trim(p_query))) then 2
         else 3 end,
    b.name, m.model_name, r.reference_number nulls first
  limit greatest(1, least(coalesce(p_limit, 20), 50));
$$;

revoke all on function public.search_watch_catalog(text, integer) from public, anon;
grant execute on function public.search_watch_catalog(text, integer) to authenticated;
