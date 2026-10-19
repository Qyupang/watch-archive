# Daily Wear Reminder Push Setup

The Edge Function `wear-reminder` is intended to be invoked daily at 09:00 Asia/Seoul by a trusted scheduler. It refuses requests unless the `Authorization: Bearer <WEAR_REMINDER_CRON_SECRET>` header matches the server secret.

## Required Edge Function secrets

Configure these in Supabase Dashboard → Edge Functions → Secrets:

- `VAPID_PUBLIC_KEY`: public key matching the value `WEAR_PUSH_VAPID_PUBLIC_KEY` in `index.html`
- `VAPID_PRIVATE_KEY`: matching VAPID private key (never place it in client code or Git)
- `VAPID_SUBJECT`: a contact URI, preferably `mailto:<maintainer email>`
- `WEAR_REMINDER_CRON_SECRET`: a long random secret used only by the scheduler

Supabase provides `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to Edge Functions in the standard runtime. Keep the service-role key private.

## Scheduling

Create a daily scheduler in Asia/Seoul at 09:00 that sends a POST request to:

`https://brtwmzobcukyifzjnkpb.supabase.co/functions/v1/wear-reminder`

Headers:

- `Authorization: Bearer <the same WEAR_REMINDER_CRON_SECRET>`
- `Content-Type: application/json`

Body: `{}`

The function checks `wear_logs.wear_date` for the current Korean date. It skips users who already have a record and sends a push to subscriptions for users without a record. Expired subscriptions (HTTP 404/410) are removed.

## iPhone setup

Open the deployed Watch Archive site in Safari, use Share → Add to Home Screen, launch the installed app, open Settings → Notifications, and enable Daily Wear Reminder. Allow notifications when prompted. iOS web push requires an installed Home Screen web app and supported iOS/iPadOS version.

## Before production use

1. Add the matching private VAPID key and cron secret in Supabase secrets.
2. Configure the scheduler with the exact URL and bearer secret above.
3. Verify a test notification on the installed iPhone PWA.
4. Run a test with today's wear log present and absent to confirm both branches.
