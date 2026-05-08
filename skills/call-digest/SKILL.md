---
name: call-digest
description: Generate end-of-day digest of all Zoom calls processed today — action items + content ideas. Use at end of day or when user says "show me today's call digest". Triggered by /call-digest or 5pm cron.
---

# Call Digest

Reads today's processed calls from Supabase and produces a digest delivered to Notion + email. Marks calls as digested.

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
  c.client_name,
  c.summary,
  c.recording_url,
  c.notion_page_id,
  COALESCE(
    (SELECT json_agg(row_to_json(ai)) FROM call_action_items ai WHERE ai.call_id = c.id),
    '[]'::json
  ) AS action_items,
  COALESCE(
    (SELECT json_agg(row_to_json(ci)) FROM call_content_ideas ci WHERE ci.call_id = c.id),
    '[]'::json
  ) AS content_ideas,
  c.key_quotes
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

The digest groups by call and includes:
- Per call: type, topic, client, duration, summary
- All action items (split: `My Action Items` / `Their Action Items`)
- All content ideas
- Type breakdown summary at the top

### Step 3: Write the Notion digest page

Read `~/.lfg/call-pipeline.json` for `notion.daily_digests_data_source_id`.

Use `mcp__notion__notion-create-pages` with `parent.data_source_id` = the value from config.

**Properties** (must match the Notion template exactly):

| Property | Value |
|---|---|
| **Name** (Title) | `Daily Digest · <YYYY-MM-DD>` |
| **Date** | today |
| **Calls Count** | count |
| **Action Items Summary** | concise text rollup of all action items grouped by call |
| **Content Ideas Summary** | concise text rollup of all content ideas grouped by call |
| **Email Sent** | unchecked initially (set to checked in Step 4 after email send) |
| **Email Sent At** | leave empty (set in Step 4) |
| **Calls** | relation — link to all the call rows from today (look up by `Supabase ID`) |

Page body: the formatted digest as the main content (use real Notion blocks: heading_2 per call, paragraph for summary, to_do for action items, bulleted_list_item for content ideas) plus a "View full transcripts in Calls DB" link at the top.

Capture the returned `page_id`.

### Step 4: Send the email

Read `user_email` from `~/.lfg/call-pipeline.json`.

Use `mcp__gmail__send_email`:
- To: the user_email value from config
- Subject: `Daily Digest · <YYYY-MM-DD> · <N> calls`
- Body: HTML mirror of the digest. Sections become `<h2>`, action items become `<ul><li>` (with ☐), content ideas become `<ul><li>`. No inline styles. Convert section dividers to `<hr>`.

After the email sends successfully, update the digest page:

```javascript
// Update the digest row's properties
mcp__notion__API-patch-page (page_id from Step 3):
  - Email Sent: true
  - Email Sent At: now()
```

### Step 5: Mark calls as digested

For every call included in this digest:

```sql
UPDATE calls
SET digested = true, status = 'Digested'
WHERE id = ANY('{<call_uuids>}'::uuid[]);
```

Also update the corresponding Notion Calls rows:
- `Status` → `Digested`
- `Digested` checkbox → checked

(Use `mcp__notion__API-patch-page` for each `notion_page_id`.)

### Step 6: Report

```
✅ Digest sent — <N> calls, <A> actions (mine: <M>, theirs: <T>), <I> ideas
   Notion: <page_url>
   Email: <user_email from config>
```

## Error handling

- **No calls today**: still write Notion page + send email saying "No calls today" so the user knows the job ran. Don't update any call statuses (no calls to update).
- **Notion failure**: still send email. Log warning. Skip Step 5 if Notion creation failed.
- **Gmail failure**: still create Notion page (Notion is canonical record). Skip the Email Sent update. Skip Step 5 — calls aren't truly "digested" until email goes out.
- **Supabase failure**: abort. Digest is meaningless without data.
- **Config file missing**: print "Run /lfg:setup-call-pipeline first." Abort.

## Arguments

- `/call-digest` — today
- `/call-digest 2026-05-03` — specific date
- `/call-digest --redigest 2026-05-03` — re-run digest for a date that already has one (overwrites the existing digest page)

## Resources

- `scripts/format_digest.py` — formats Supabase rows into the digest string
