---
name: call-digest
description: Generate end-of-day digest of all Zoom calls processed today — action items + content ideas. Use at end of day or when user says "show me today's call digest". Triggered by /call-digest or 5pm cron.
---

# Call Digest

Reads today's processed calls from Supabase and produces a digest delivered to Notion + email.

## When to use

- The user runs `/call-digest`
- The 5pm cron fires `/call-digest`
- The user says "what came out of today's calls" or "build today's digest"

## Prerequisite: config + processed calls

Requires `~/.lfg/call-pipeline.json` (run `/lfg:setup-call-pipeline` first) and at least one processed call in Supabase from today (run `/process-calls` first).

The config provides:
- `notion.daily_digests_data_source_id` — your Daily Digests DB
- `user_email` — recipient of the digest email

## What you do

### Step 1: Query today's calls

Use `mcp__supabase__execute_sql`:

```sql
SELECT
  c.id::text AS id,
  c.call_date::text AS call_date,
  c.call_type,
  c.duration_minutes,
  c.topic,
  c.summary,
  c.transcript_url,
  COALESCE(
    (SELECT json_agg(row_to_json(ai)) FROM call_action_items ai WHERE ai.call_id = c.id),
    '[]'::json
  ) AS action_items,
  COALESCE(
    (SELECT json_agg(row_to_json(ci)) FROM call_content_ideas ci WHERE ci.call_id = c.id),
    '[]'::json
  ) AS content_ideas
FROM calls c
WHERE c.call_date::date = CURRENT_DATE
ORDER BY c.call_date ASC;
```

(Or pass a specific date in `$ARGUMENTS` — replace `CURRENT_DATE` with `'YYYY-MM-DD'::date`.)

### Step 2: Format the digest

```bash
python3 -c "
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path.home() / '.claude/skills/call-digest'))
from scripts.format_digest import format_digest
calls = json.loads(sys.stdin.read())
print(format_digest(calls, date='<YYYY-MM-DD>'))
" <<< '<JSON from Step 1>'
```

Capture the output — that's the digest string.

### Step 3: Write the Notion digest page

Read `~/.lfg/call-pipeline.json` for `notion.daily_digests_data_source_id`.

Use `mcp__notion__notion-create-pages` with `parent.data_source_id` = the value from config.

Properties (must match the names from the Notion template spec):
- Title: `Call Digest — <YYYY-MM-DD>`
- Date: today
- Number of Calls: count
- Type Breakdown: e.g. `2 coaching · 1 sales · 1 group`

Page body: the formatted digest as a code block (preserves spacing) plus a "View full transcripts in Calls DB" link.

### Step 4: Send the email

Read `user_email` from `~/.lfg/call-pipeline.json`.

Use `mcp__gmail__send_email`:
- To: the user_email value from config
- Subject: `Call Digest — <YYYY-MM-DD>`
- Body: HTML mirror of the digest. Sections become `<h2>`, bullets become `<ul><li>`, no inline styles. Convert the `═══` separators to `<hr>`.

### Step 5: Report

```
✅ Digest sent — <N> calls, <A> actions, <I> ideas
   Notion: <page_url>
   Email: <user_email from config>
```

## Error handling

- **No calls today**: still write Notion page + send email saying "No calls today" so the user knows the job ran.
- **Notion failure**: still send email. Log warning.
- **Gmail failure**: still create Notion page. Notion is canonical record.
- **Supabase failure**: abort. Digest is meaningless without data.
- **Config file missing**: print "Run /lfg:setup-call-pipeline first." Abort.

## Arguments

- `/call-digest` — today
- `/call-digest 2026-05-03` — specific date

## Resources

- `scripts/format_digest.py` — formats Supabase rows into the digest string
