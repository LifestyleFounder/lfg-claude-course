---
description: "Set up the LFG Call Pipeline — Supabase + Notion + Zoom + Google Calendar + Gmail wiring for /process-calls, /mine-calls, and /call-digest. Walks the user through 4 steps and creates ~/.lfg/call-pipeline.json. No Anthropic API key required — runs entirely inside Claude Code Pro/Max."
---

# /lfg:setup-call-pipeline — Configure the Advanced Call Pipeline

You are walking the user through a 4-step setup of the LFG Call Pipeline. The end state is:

- Supabase project with 3 tables (`calls`, `call_action_items`, `call_content_ideas`)
- Notion duplicated template with 2 databases (`Calls`, `Daily Digests`)
- Zoom + Google Calendar + Notion + Supabase + Gmail MCP servers configured in Claude Code
- `~/.lfg/call-pipeline.json` config file with their IDs and preferences

**No Anthropic API key required.** Extraction and hook mining run inside the user's existing Claude Code Pro/Max session. $0/month additional cost.

## Voice and pacing

- Brisk, professional, confident — this is a paid/premium tier setup, not a free intro
- Direct and tactical. No fluff. The student is paying for value, not encouragement.
- One step at a time. Wait for "next" or completion confirmation before moving on.
- Show progress: `STEP 2 of 4`

## First action — open the setup PDF

```bash
open ~/.lfg/setup/call-pipeline-install.pdf 2>/dev/null || open "https://github.com/LifestyleFounder/lfg-claude-course/raw/main/setup/call-pipeline/PDF-LEAD-MAGNET.html"
```

Then say:

```
══════════════════════════════════════════════════════════
  LFG CALL PIPELINE — SETUP
  Advanced Module · Premium Tier
══════════════════════════════════════════════════════════

I just opened the setup walkthrough.

This installs the full call pipeline:
  /process-calls   — captures every Zoom recording
  /mine-calls      — extracts content ideas in your voice
  /call-digest     — emails you the daily rollup

4 steps. ~20 minutes if all your accounts are ready.

Runs inside your Claude Code Pro/Max plan — no API key, no extra cost.

Reply 'go' when you're ready to start.
```

Wait for confirmation.

---

## Step 1 — Supabase

Say:

```
STEP 1 of 4 — Supabase
══════════════════════════════════════════════════════════
```

Tell them:

> You need a Supabase project. Free tier is fine.

> 1. Go to https://supabase.com → sign up / log in → New Project
> 2. Pick a name like "call-pipeline". Pick the region closest to you. Set a strong database password.
> 3. Wait 2 minutes for it to provision.
> 4. Once ready, click **SQL Editor** in the left sidebar → **New query**.
> 5. Copy the contents of this file and paste into the SQL editor:

```bash
cat ~/.lfg/setup/supabase-schema.sql | pbcopy
echo "→ Schema SQL copied to clipboard. Paste into Supabase SQL Editor → Run."
```

> 6. Click **Run**. You should see "Success. No rows returned."
> 7. Verify tables exist: in **Table Editor** (left sidebar), you should see `calls`, `call_action_items`, `call_content_ideas`.

Then ask:

> Tables created? Reply 'yes' or paste any error you see.

If they confirm, move on. If they paste an error, debug it — common issues: pasted with line breaks wrong (re-copy), `gen_random_uuid()` not available (run `CREATE EXTENSION IF NOT EXISTS pgcrypto;` first).

---

## Step 2 — Notion template

Say:

```
STEP 2 of 4 — Notion
══════════════════════════════════════════════════════════
```

Tell them:

> Now you need two Notion databases: `Calls` and `Daily Digests`. We've built a template you can duplicate.

> 1. Open this template: https://www.notion.so/35a237e12a2c8196bd11e472a353b1ae
> 2. In the top-right of the page, click **Duplicate** → choose your workspace.
> 3. **Don't rename properties** — the skills look up columns by name, so renames break the integration.
> 4. Open the duplicated **Calls** database. Click ⋯ (top-right) → **Copy link to view** → paste it back here.
> 5. Repeat for the **Daily Digests** database.

Wait for them to paste both links. From each link, extract the data_source_id:
- A Notion data source URL looks like `https://www.notion.so/<workspace>/<title>-<id>?v=<view_id>`
- The `<id>` is the data_source_id (32 hex chars, optionally with hyphens — normalize to UUID format)

Save both IDs for Step 4.

---

## Step 3 — MCP servers

Say:

```
STEP 3 of 4 — Connect MCP servers
══════════════════════════════════════════════════════════
```

Tell them:

> You need 5 MCP servers connected to Claude Code. Two you may already have (Notion, Gmail). Three are pipeline-specific (Supabase, Zoom, Google Calendar).

> Open Claude Code's settings → MCP Servers, and connect each:
>
> 1. **Supabase** — paste your Supabase project URL + service role key from Settings → API in your Supabase dashboard
> 2. **Notion** — connect via OAuth (one click)
> 3. **Zoom** — connect via OAuth (Zoom Pro+ account required — recordings need to be cloud recordings, not local)
> 4. **Google Calendar** — connect via OAuth
> 5. **Gmail** — connect via OAuth (used to send the daily digest email)

> When all five are connected, reply 'connected'.

If they hit issues with Zoom (most common: no Pro+ subscription), explain that local recordings won't work — Zoom MCP only sees cloud recordings.

---

## Step 4 — Write the config file

Say:

```
STEP 4 of 4 — Final config
══════════════════════════════════════════════════════════
```

Now ask them a few questions to populate `~/.lfg/call-pipeline.json`:

1. **Email** — "Where should the daily digest land? (your inbox)"
2. **Name** — "Your name? (used in greetings AND as host_name when extraction decides whose action items belong to you)"
3. **Voice description** — "In one sentence, describe how you want hooks/content ideas written. Examples: 'Direct and contrarian — Frank Kern meets Pete Holmes' or 'Tactical, numbers-first — sounds like Hormozi' or 'Warm storyteller, vulnerable, lots of personal moments'."
4. **Active 1:1 clients** — "List the names of clients whose 1:1 calls should auto-classify as 'Coaching' (comma-separated, or skip if none). The classifier looks for these names in calendar event titles."

Build the config object. Use the data_source_ids from Step 2 and the values from this step. Then write it:

```bash
mkdir -p ~/.lfg
cat > ~/.lfg/call-pipeline.json <<'JSON'
{
  "user_email": "<email>",
  "user_name": "<name>",
  "user_voice_description": "<voice description>",
  "client_names": [<list>],
  "calendar_keywords": {
    "Sales": ["sales call", "discovery call", "intro call", "strategy call", "trial call"],
    "Coaching": ["coaching", "1:1", "private session", "check-in", "one-on-one"],
    "Group": ["group call", "office hours", "q&a", "implementation call"],
    "Workshop": ["workshop", "masterclass", "training"]
  },
  "notion": {
    "calls_data_source_id": "<from step 2>",
    "daily_digests_data_source_id": "<from step 2>"
  }
}
JSON
```

Verify by reading it back:

```bash
cat ~/.lfg/call-pipeline.json | python3 -m json.tool
```

Should pretty-print as valid JSON.

Then customize the prompts (optional but recommended):

> Two prompt files control the AI's voice. Open them now and skim — edit the "Voice" section in each to match how you want hooks and summaries written.

```bash
open ~/.claude/skills/call-capture/references/extraction-prompt.md
open ~/.claude/skills/mine-calls/references/hook-prompt.md
```

## Done — first run

Say:

```
══════════════════════════════════════════════════════════
  ✅ SETUP COMPLETE
══════════════════════════════════════════════════════════

Try your first run:

  /process-calls   — captures any Zoom recording from the last 24h
  /mine-calls      — extracts content ideas from processed calls
  /call-digest     — emails you the rollup

If /process-calls shows "no recordings found", make sure you have at
least one Zoom call from the last 24 hours that was cloud-recorded.

Heavy users: if you process 10+ calls in one batch you may briefly
hit your Claude Pro/Max usage cap. Most coaches doing 1–2 calls/day
never see this. If it happens, process in smaller batches or upgrade
to Max.

Set up the cron later if you want this automatic — see the setup PDF
for the launchctl recipe.
```

## If they want to retest setup later

`/lfg:setup-call-pipeline --verify` — re-checks the config file, MCP connections, table existence, and Notion access. (Implementation: read config, connect to each service, run a SELECT 1 against Supabase, fetch the data sources from Notion to confirm IDs are valid.)
