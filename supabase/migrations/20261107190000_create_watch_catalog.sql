-- Shared watch catalog. Existing personal watch records remain independent.
create table if not exists public.watch_catalog_brands (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.watch_catalog_models (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.watch_catalog_brands(id) on delete restrict,
  collection_name text,
  model_name text not null,
  description text,
  production_start smallint,
  production_end smallint,
  created_at timestamptz not null default now(),
  constraint watch_catalog_models_year_check check (
    production_start is null or production_end is null or production_end >= production_start
  )
);

create unique index if not exists watch_catalog_models_identity_idx
  on public.watch_catalog_models (brand_id, lower(coalesce(collection_name, '')), lower(model_name));

create table if not exists public.watch_catalog_references (
  id uuid primary key default gen_random_uuid(),
  model_id uuid not null references public.watch_catalog_models(id) on delete cascade,
  reference_number text not null,
  variant_name text,
  dial_variant text,
  case_diameter_mm numeric(5,2),
  thickness_mm numeric(5,2),
  lug_to_lug_mm numeric(5,2),
  movement text,
  caliber text,
  case_material text,
  crystal text,
  production_start smallint,
  production_end smallint,
  image_url text,
  source_url text,
  verification_status text not null default 'unverified'
    check (verification_status in ('unverified', 'community', 'verified')),
  created_at timestamptz not null default now(),
  constraint watch_catalog_references_year_check check (
    production_start is null or production_end is null or production_end >= production_start
  )
);

create unique index if not exists watch_catalog_references_identity_idx
  on public.watch_catalog_references (model_id, lower(reference_number), lower(coalesce(variant_name, '')));

create index if not exists watch_catalog_models_brand_idx
  on public.watch_catalog_models (brand_id);
create index if not exists watch_catalog_references_model_idx
  on public.watch_catalog_references (model_id);
create index if not exists watch_catalog_references_number_idx
  on public.watch_catalog_references (lower(reference_number));

alter table public.watches
  add column if not exists catalog_reference_id uuid
  references public.watch_catalog_references(id) on delete set null;

create index if not exists watches_catalog_reference_idx
  on public.watches (catalog_reference_id);

alter table public.watch_catalog_brands enable row level security;
alter table public.watch_catalog_models enable row level security;
alter table public.watch_catalog_references enable row level security;

drop policy if exists "Authenticated users can read watch catalog brands" on public.watch_catalog_brands;
create policy "Authenticated users can read watch catalog brands"
  on public.watch_catalog_brands for select to authenticated using (true);
drop policy if exists "Authenticated users can read watch catalog models" on public.watch_catalog_models;
create policy "Authenticated users can read watch catalog models"
  on public.watch_catalog_models for select to authenticated using (true);
drop policy if exists "Authenticated users can read watch catalog references" on public.watch_catalog_references;
create policy "Authenticated users can read watch catalog references"
  on public.watch_catalog_references for select to authenticated using (true);

revoke all on public.watch_catalog_brands from anon, authenticated;
revoke all on public.watch_catalog_models from anon, authenticated;
revoke all on public.watch_catalog_references from anon, authenticated;
grant select on public.watch_catalog_brands, public.watch_catalog_models, public.watch_catalog_references to authenticated;

create or replace function public.search_watch_catalog(p_query text, p_limit integer default 20)
returns table (
  id uuid,
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
  select
    r.id,
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
    r.verification_status
  from public.watch_catalog_references r
  join public.watch_catalog_models m on m.id = r.model_id
  join public.watch_catalog_brands b on b.id = m.brand_id
  where nullif(trim(p_query), '') is not null
    and (
      b.name ilike '%' || trim(p_query) || '%'
      or m.model_name ilike '%' || trim(p_query) || '%'
      or coalesce(m.collection_name, '') ilike '%' || trim(p_query) || '%'
      or r.reference_number ilike '%' || trim(p_query) || '%'
      or coalesce(r.variant_name, '') ilike '%' || trim(p_query) || '%'
    )
  order by
    case when lower(r.reference_number) = lower(trim(p_query)) then 0
         when lower(m.model_name) = lower(trim(p_query)) then 1
         else 2 end,
    b.name, m.model_name, r.reference_number
  limit greatest(1, least(coalesce(p_limit, 20), 50));
$$;

revoke all on function public.search_watch_catalog(text, integer) from public, anon;
grant execute on function public.search_watch_catalog(text, integer) to authenticated;
