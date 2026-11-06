create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  collector_name text not null default 'WATCH COLLECTOR',
  bio text not null default '',
  avatar_url text,
  show_collector_name boolean not null default true,
  updated_at timestamptz not null default now(),
  constraint profiles_collector_name_length check (char_length(collector_name) between 1 and 40),
  constraint profiles_bio_length check (char_length(bio) <= 160)
);
alter table public.profiles enable row level security;
revoke all on public.profiles from anon, authenticated;
grant select, insert, update on public.profiles to authenticated;
drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile" on public.profiles for select to authenticated using ((select auth.uid()) = id);
drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile" on public.profiles for insert to authenticated with check ((select auth.uid()) = id);
drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" on public.profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
alter table public.collection_shares add column if not exists show_collector_name boolean not null default true;
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types) values ('collector-avatars','collector-avatars',true,5242880,array['image/jpeg','image/png','image/webp']) on conflict (id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
drop policy if exists "Public can view collector avatars" on storage.objects;
create policy "Public can view collector avatars" on storage.objects for select to anon, authenticated using (bucket_id='collector-avatars');
drop policy if exists "Users can upload own collector avatar" on storage.objects;
create policy "Users can upload own collector avatar" on storage.objects for insert to authenticated with check (bucket_id='collector-avatars' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "Users can update own collector avatar" on storage.objects;
create policy "Users can update own collector avatar" on storage.objects for update to authenticated using (bucket_id='collector-avatars' and (storage.foldername(name))[1]=(select auth.uid())::text) with check (bucket_id='collector-avatars' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "Users can delete own collector avatar" on storage.objects;
create policy "Users can delete own collector avatar" on storage.objects for delete to authenticated using (bucket_id='collector-avatars' and (storage.foldername(name))[1]=(select auth.uid())::text);