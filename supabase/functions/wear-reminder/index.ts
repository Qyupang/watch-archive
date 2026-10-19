import { createClient } from "npm:@supabase/supabase-js@2";
import webpush from "npm:web-push";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Content-Type": "application/json",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "POST required" }), { status: 405, headers: corsHeaders });

  const cronSecret = Deno.env.get("WEAR_REMINDER_CRON_SECRET");
  if (!cronSecret || req.headers.get("authorization") !== `Bearer ${cronSecret}`) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
  }

  const publicKey = Deno.env.get("VAPID_PUBLIC_KEY");
  const privateKey = Deno.env.get("VAPID_PRIVATE_KEY");
  const subject = Deno.env.get("VAPID_SUBJECT") || "mailto:admin@watch-archive.app";
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!publicKey || !privateKey || !supabaseUrl || !serviceRoleKey) {
    return new Response(JSON.stringify({ error: "Missing server secrets" }), { status: 500, headers: corsHeaders });
  }

  webpush.setVapidDetails(subject, publicKey, privateKey);
  const supabase = createClient(supabaseUrl, serviceRoleKey);
  const todayKst = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Seoul", year: "numeric", month: "2-digit", day: "2-digit",
  }).format(new Date());

  const { data: subscriptions, error: subscriptionError } = await supabase
    .from("push_subscriptions").select("id,user_id,endpoint,p256dh,auth");
  if (subscriptionError) return new Response(JSON.stringify({ error: subscriptionError.message }), { status: 500, headers: corsHeaders });

  const { data: logs, error: logError } = await supabase
    .from("wear_logs").select("user_id").eq("wear_date", todayKst);
  if (logError) return new Response(JSON.stringify({ error: logError.message }), { status: 500, headers: corsHeaders });

  const usersWithWearLog = new Set((logs || []).map((row: { user_id: string }) => row.user_id));
  let sent = 0, skipped = 0, removed = 0, failed = 0;
  for (const sub of subscriptions || []) {
    if (usersWithWearLog.has(sub.user_id)) { skipped++; continue; }
    try {
      await webpush.sendNotification({
        endpoint: sub.endpoint,
        keys: { p256dh: sub.p256dh, auth: sub.auth },
      }, JSON.stringify({
        title: "Watch Archive",
        body: "오늘 착용한 시계를 기록해 주세요.",
        url: "./",
        tag: `wear-reminder-${todayKst}`,
      }));
      sent++;
    } catch (error) {
      const status = (error as { statusCode?: number })?.statusCode;
      if (status === 404 || status === 410) {
        await supabase.from("push_subscriptions").delete().eq("id", sub.id);
        removed++;
      } else {
        failed++;
        console.error("Push send failed", status, error);
      }
    }
  }

  return new Response(JSON.stringify({ date: todayKst, subscriptions: subscriptions?.length || 0, sent, skipped, removed, failed }), { status: 200, headers: corsHeaders });
});
