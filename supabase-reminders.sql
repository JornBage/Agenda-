-- Meldingen en alarmen. Run once in Supabase: SQL Editor -> New query -> paste -> Run.
-- Replace <CRON_SECRET> (at the bottom) with the same value you saved as the CRON_SECRET secret of the Edge Function.

-- Phones that may receive notifications (one row per phone/browser).
create table if not exists public.push_subs (
  endpoint   text primary key,
  user_id    uuid not null references auth.users(id) on delete cascade,
  sub        jsonb not null,
  created_at timestamptz not null default now()
);
alter table public.push_subs enable row level security;
create policy "subs_own" on public.push_subs for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

-- Upcoming notifications/alarms, filled by the app for the next 30 days.
create table if not exists public.reminders (
  id        uuid primary key default gen_random_uuid(),
  user_id   uuid not null references auth.users(id) on delete cascade,
  key       text not null,               -- item id | date | kind, so a sent one is not sent again
  kind      text not null check (kind in ('notify','alarm')),
  fire_at   timestamptz not null,
  title     text not null,
  body      text not null default '',
  token     uuid not null default gen_random_uuid(),  -- lets the phone stop an alarm without logging in
  sent_at   timestamptz,
  last_sent timestamptz,
  repeats   int not null default 0,
  acked_at  timestamptz
);
create index if not exists reminders_due on public.reminders (fire_at) where acked_at is null;
alter table public.reminders enable row level security;
create policy "rem_select_own" on public.reminders for select to authenticated using ((select auth.uid()) = user_id);

-- Table rights (newer Supabase projects do not grant these automatically).
grant select, insert, update, delete on public.push_subs to authenticated, service_role;
grant select on public.reminders to authenticated;
grant select, insert, update, delete on public.reminders to service_role;

-- The app replaces all not-yet-sent reminders of the logged-in user in one go.
create or replace function public.replace_reminders(rows jsonb)
returns void language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'not logged in'; end if;
  delete from reminders where user_id = uid and sent_at is null;
  insert into reminders (user_id, key, kind, fire_at, title, body)
  select uid, r->>'key', r->>'kind', (r->>'fire_at')::timestamptz, left(r->>'title', 200), left(coalesce(r->>'body', ''), 300)
  from jsonb_array_elements(rows) r
  where (r->>'fire_at')::timestamptz > now() - interval '1 minute'
    and not exists (select 1 from reminders x where x.user_id = uid and x.key = r->>'key');
  delete from reminders where user_id = uid and fire_at < now() - interval '2 days';
end $$;
revoke all on function public.replace_reminders(jsonb) from public, anon;
grant execute on function public.replace_reminders(jsonb) to authenticated;

-- "Stop" on an alarm notification.
create or replace function public.ack_reminder(p_id uuid, p_token uuid)
returns void language sql security definer set search_path = public as $$
  update reminders set acked_at = now() where id = p_id and token = p_token and acked_at is null;
$$;
grant execute on function public.ack_reminder(uuid, uuid) to anon, authenticated;

-- True when the Edge Function has something to send right now (same rules as the function itself).
create or replace function public.reminders_due_now()
returns boolean language sql stable set search_path = public as $$
  select exists (
    select 1 from public.reminders r
    where r.acked_at is null
      and r.fire_at <= now()
      and r.fire_at >= now() - interval '6 hours'
      and (
        (r.kind = 'notify' and r.sent_at is null)
        or (r.kind = 'alarm' and r.repeats < 10
            and (r.last_sent is null or r.last_sent < now() - interval '50 seconds'))
      )
  );
$$;
revoke all on function public.reminders_due_now() from public, anon, authenticated;

-- Every minute: if something is due, ask the Edge Function to send it (no call, and no log lines, otherwise).
create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists pg_net with schema extensions;
select cron.unschedule('send-reminders') where exists (select 1 from cron.job where jobname = 'send-reminders');
select cron.schedule('send-reminders', '* * * * *', $$
  select net.http_post(
    url := 'https://xvuqcmmxarvkpcetztno.supabase.co/functions/v1/send-reminders',
    headers := jsonb_build_object('Content-Type', 'application/json', 'x-cron-secret', '<CRON_SECRET>'),
    body := '{}'::jsonb)
  where public.reminders_due_now()
$$);

-- pg_cron keeps a history row for every run; keep only the last day.
select cron.unschedule('cleanup-cron-history')
  where exists (select 1 from cron.job where jobname = 'cleanup-cron-history');
select cron.schedule('cleanup-cron-history', '17 3 * * *',
  $$delete from cron.job_run_details where end_time < now() - interval '1 day'$$);
