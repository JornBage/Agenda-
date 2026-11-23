-- Update 1 for notifications: call the Edge Function only when something is actually due.
-- Before: every minute, even with nothing to send (about 43,000 calls and lots of log lines per month).
-- After: the database checks every minute (cheap, no function call); the function only runs when a
-- notification or alarm has to go out. Notifications still arrive within the same minute.
-- Run once in Supabase: SQL Editor -> New query -> paste -> Run. Safe to run more than once.
-- The secret already stored in the existing job is kept; you do not need to fill anything in.

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

-- Add the condition to the existing every-minute job.
do $$
declare j record;
begin
  select jobid, command into j from cron.job where jobname = 'send-reminders';
  if j.jobid is null then
    raise exception 'Job send-reminders not found. Run supabase-reminders.sql first.';
  end if;
  if j.command like '%reminders_due_now%' then
    raise notice 'Job send-reminders was already updated.';
  else
    perform cron.alter_job(j.jobid,
      command := rtrim(j.command, E' \n\r\t;') || E'\n  where public.reminders_due_now()');
  end if;
end $$;

-- pg_cron keeps a history row for every run (1,440 per day); keep only the last day.
select cron.unschedule('cleanup-cron-history')
  where exists (select 1 from cron.job where jobname = 'cleanup-cron-history');
select cron.schedule('cleanup-cron-history', '17 3 * * *',
  $$delete from cron.job_run_details where end_time < now() - interval '1 day'$$);

-- Check: the command should end with "where public.reminders_due_now()".
select jobname, schedule, command from cron.job order by jobname;
