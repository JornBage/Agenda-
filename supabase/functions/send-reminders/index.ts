// Supabase Edge Function "send-reminders": called every minute by pg_cron (see supabase-reminders.sql).
// Sends due notifications once, and alarms every minute (max 10 times) until "Stop" is tapped.
// Secrets needed (Edge Functions -> Secrets): VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY, CRON_SECRET.
// Turn OFF "Verify JWT" for this function; it checks CRON_SECRET instead.
import webpush from "npm:web-push@3.6.7";
import { createClient } from "npm:@supabase/supabase-js@2";

const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
webpush.setVapidDetails("https://github.com/JornBage/claude-bestanden",
  Deno.env.get("VAPID_PUBLIC_KEY")!, Deno.env.get("VAPID_PRIVATE_KEY")!);

const ALARM_MAX = 10;

Deno.serve(async (req) => {
  if (req.headers.get("x-cron-secret") !== Deno.env.get("CRON_SECRET")) return new Response("forbidden", { status: 403 });
  const now = new Date();
  const { data: due, error } = await sb.from("reminders").select("*")
    .lte("fire_at", now.toISOString()).is("acked_at", null)
    .gte("fire_at", new Date(now.getTime() - 6 * 3600e3).toISOString()); // skip very old ones
  if (error) return new Response(error.message, { status: 500 });

  const todo = (due ?? []).filter((r) =>
    r.kind === "notify" ? !r.sent_at
      : r.repeats < ALARM_MAX && (!r.last_sent || now.getTime() - new Date(r.last_sent).getTime() > 50e3));
  const subsByUser: Record<string, { endpoint: string; sub: any }[]> = {};
  let sent = 0;

  for (const r of todo) {
    if (!subsByUser[r.user_id]) {
      const { data } = await sb.from("push_subs").select("endpoint,sub").eq("user_id", r.user_id);
      subsByUser[r.user_id] = data ?? [];
    }
    const payload = JSON.stringify({ id: r.id, token: r.token, kind: r.kind, title: r.title, body: r.body, n: r.repeats + 1 });
    for (const s of subsByUser[r.user_id]) {
      try {
        await webpush.sendNotification(s.sub, payload, { TTL: 600, urgency: "high" });
        sent++;
      } catch (e) {
        const code = (e as { statusCode?: number }).statusCode;
        if (code === 404 || code === 410) await sb.from("push_subs").delete().eq("endpoint", s.endpoint); // phone unsubscribed
      }
    }
    await sb.from("reminders").update({
      sent_at: r.sent_at ?? now.toISOString(), last_sent: now.toISOString(), repeats: r.repeats + 1,
      ...(r.kind === "notify" || r.repeats + 1 >= ALARM_MAX ? { acked_at: now.toISOString() } : {}),
    }).eq("id", r.id);
  }
  return new Response(JSON.stringify({ due: todo.length, sent }), { headers: { "Content-Type": "application/json" } });
});
