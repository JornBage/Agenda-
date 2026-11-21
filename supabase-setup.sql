-- Run once in Supabase: SQL Editor -> New query -> paste -> Run.
-- Creates one row per user that holds the whole agenda (events + to-dos) as JSON.

create table if not exists public.agenda_data (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.agenda_data enable row level security;

-- Every user can only see and change their own row.
create policy "agenda_select_own" on public.agenda_data
  for select to authenticated using ((select auth.uid()) = user_id);

create policy "agenda_insert_own" on public.agenda_data
  for insert to authenticated with check ((select auth.uid()) = user_id);

create policy "agenda_update_own" on public.agenda_data
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "agenda_delete_own" on public.agenda_data
  for delete to authenticated using ((select auth.uid()) = user_id);
