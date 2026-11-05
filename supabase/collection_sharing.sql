-- Watch Archive collection sharing
-- Public content is a curated snapshot; acquisition, valuation and maintenance fields are never copied.
create table if not exists public.collection_shares (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  box_id uuid not null references public.collection_boxes(id) on delete cascade,
  token uuid not null unique default gen_random_uuid(),
  title text not null check (char_length(btrim(title)) between 1 and 80),
  description text not null default '' check (char_length(description) <= 500),
  cover_image_url text,
  watch_items jsonb not null default '[]'::jsonb,
  card_image_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint collection_shares_user_box_unique unique (user_id, box_id),
  constraint collection_shares_watch_items_array check (jsonb_typeof(watch_items) = 'array')
);
create index if not exists collection_shares_active_token_idx on public.collection_shares(token) where is_active = true;
alter table public.collection_shares enable row level security;

drop policy if exists "Owners can view their collection shares" on public.collection_shares;
create policy "Owners can view their collection shares" on public.collection_shares for select to authenticated using ((select auth.uid()) = user_id);
drop policy if exists "Anyone can view active collection shares" on public.collection_shares;
drop policy if exists "Owners can create collection shares" on public.collection_shares;
create policy "Owners can create collection shares" on public.collection_shares for insert to authenticated with check (
  (select auth.uid()) = user_id and exists (select 1 from public.collection_boxes b where b.id = box_id and b.user_id = (select auth.uid()))
);
drop policy if exists "Owners can update collection shares" on public.collection_shares;
create policy "Owners can update collection shares" on public.collection_shares for update to authenticated using ((select auth.uid()) = user_id) with check (
  (select auth.uid()) = user_id and exists (select 1 from public.collection_boxes b where b.id = box_id and b.user_id = (select auth.uid()))
);
drop policy if exists "Owners can delete collection shares" on public.collection_shares;
create policy "Owners can delete collection shares" on public.collection_shares for delete to authenticated using ((select auth.uid()) = user_id);

revoke all on public.collection_shares from anon, authenticated;
grant select, insert, update, delete on public.collection_shares to authenticated;

create or replace function public.get_collection_share(p_token uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $
  select jsonb_build_object(
    'token', s.token,
    'title', s.title,
    'description', s.description,
    'cover_image_url', s.cover_image_url,
    'watch_items', s.watch_items,
    'card_image_url', s.card_image_url
  )
  from public.collection_shares as s
  where s.token = p_token and s.is_active = true
  limit 1;
$;
revoke all on function public.get_collection_share(uuid) from public, anon, authenticated;
grant execute on function public.get_collection_share(uuid) to anon;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('collection-shares', 'collection-shares', true, 10485760, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = excluded.public, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Users can upload their collection share images" on storage.objects;
create policy "Users can upload their collection share images" on storage.objects for insert to authenticated with check (
  bucket_id = 'collection-shares' and (storage.foldername(name))[1] = (select auth.uid())::text
);
drop policy if exists "Users can delete their collection share images" on storage.objects;
create policy "Users can delete their collection share images" on storage.objects for delete to authenticated using (
  bucket_id = 'collection-shares' and (storage.foldername(name))[1] = (select auth.uid())::text
);
