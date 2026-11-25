alter table public.wear_logs
  add column if not exists photo_paths text[] not null default '{}'::text[],
  add column if not exists note text;

alter table public.wear_logs
  add constraint wear_logs_photo_paths_limit check (cardinality(photo_paths) <= 3),
  add constraint wear_logs_note_length check (note is null or char_length(note) <= 280);
