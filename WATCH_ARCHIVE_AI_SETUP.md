# Watch Archive AI v1 — implementation notes

## Current implementation

- Keeps the existing GitHub Pages / single-page HTML application.
- Adds an Archive AI entry inside the existing More menu.
- Uses the existing Supabase tables only; no database schema migration is required.
- Adds a local-first read-only data context builder in `watch-archive-ai.js`.
- Supports device cache, automatic cloud refresh with local fallback, and strict cloud-only mode.
- Stores chat history in the current browser's localStorage, scoped by the signed-in user.
- Sends only the question and selected structured watch data to the Edge Function. Watch photo binaries and authentication credentials are not included in the model context.
- Requires a one-time explicit consent before the first OpenAI request on each device.
- Deploys `watch-archive-ai` as a Supabase Edge Function with JWT verification enabled.
- Does not expose an API key in browser code and does not provide any write tools.

## Required setup

Set the following Edge Function secret in the Supabase project:

- Name: `OPENAI_API_KEY`
- Value: an OpenAI API key created by the project owner

In the Supabase Dashboard, open the project's Edge Functions secrets settings and add the secret. Alternatively, use the Supabase CLI:

```bash
supabase secrets set OPENAI_API_KEY=your_api_key --project-ref brtwmzobcukyifzjnkpb
```

Do not put this key in `index.html`, `watch-archive-ai.js`, GitHub, or a message to ChatGPT.

The Edge Function currently calls the OpenAI Responses API using `gpt-4.1-mini`. API billing is separate from a ChatGPT subscription.

## Data access

- `watches`: current collection and archive records.
- `wear_logs`: fetched only for wear-related questions.
- `watch_history`: fetched only for maintenance, valuation-history, or timeline questions.
- `collection_boxes` and `collection_box_items`: fetched only for collection-box questions.

All cloud queries are scoped to the authenticated user's `user_id`; existing RLS policies remain active. The AI endpoint accepts context only and never executes SQL or mutating database operations.

## Important scope boundary

The in-app AI foundation is deployed. The external ChatGPT connection is **not yet enabled**. It requires a separate read-only MCP endpoint and an OAuth 2.1 authorization/consent flow. That work must be completed and tested before enabling an external ChatGPT connector. External access will be restricted to cloud-synchronized records; device-only IndexedDB data will never be exposed to the MCP endpoint.

## Validation checklist

1. Add `OPENAI_API_KEY` as an Edge Function secret.
2. Merge this feature branch into the GitHub Pages deployment branch.
3. Sign in to Watch Archive and open More → Archive AI.
4. Test device data mode while offline with a previously cached collection.
5. Test automatic mode online and confirm it falls back to local data if cloud refresh fails.
6. Test cloud mode online and confirm it reports an error rather than silently using local data if cloud access fails.
7. Confirm that AI chat history remains on the current device and is not written to Supabase.
8. Confirm that a second account cannot retrieve the first account's records.
