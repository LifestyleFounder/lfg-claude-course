---
name: call-capture
description: Capture Zoom call recordings, transcribe, classify by type (coaching/sales/workshop/group), and store in Supabase + Notion. Use when processing new Zoom calls or after a coaching/sales/workshop call ends. Triggered by /process-calls or hourly cron.
---

# Call Capture

Pulls new Zoom recordings, classifies them, extracts summary + action items + content ideas via Claude Haiku 4.5, and writes to Supabase + Notion. Idempotent — safe to rerun.

## When to use

- The user runs `/process-calls`
- The hourly cron fires `/process-calls`
- The user says "process my calls" or "ingest today's calls"

## Prerequisite: config file

This skill reads from `~/.lfg/call-pipeline.json`. If the file doesn't exist, tell the user to run `/lfg:setup-call-pipeline` first.

```bash
test -f ~/.lfg/call-pipeline.json || echo "Run /lfg:setup-call-pipeline first."
```

The config provides:
- `notion.calls_data_source_id` — your Notion Calls DB
- `client_names`, `calendar_keywords` — for keyword classifier
- `user_email` — used by call-digest, but loaded once for the whole pipeline

## What you do

For each unprocessed Zoom recording in the last 24 hours:

### Step 1: Find unprocessed recordings

Use `mcp__zoom__recordings_list` to fetch recordings from the last 24 hours.

For each recording, check Supabase for dedupe:

`mcp__supabase__execute_sql` with:
```sql
SELECT id FROM calls WHERE zoom_meeting_id = '<meeting_id>'
```

If a row exists, skip this recording (idempotent).

### Step 2: Fetch the transcript

Use `mcp__zoom__get_recording_resource` with the recording's transcript file ID. The result is VTT content. Save it to `/tmp/zoom-vtt-<meeting_id>.vtt`.

Parse it (note: the script uses `Path(__file__)` so it works from any install location):

```bash
python3 -c "
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path.home() / '.claude/skills/call-capture'))
from scripts.parse_vtt import parse_vtt
content = Path('/tmp/zoom-vtt-<meeting_id>.vtt').read_text()
print(json.dumps(parse_vtt(content)))
"
```

Use the parsed `text` and `index` for next steps.

### Step 3: Find the matching calendar event

Use `mcp__google_calendar__list_events` with:
- `time_min` = call_start - 15 min
- `time_max` = call_start + 15 min

Pick the matching event:
- Prefer events whose description contains the Zoom join URL or meeting ID
- Else pick the event with the longest overlap with the call window

If no event found, skip to Step 4b.

### Step 4a: Classify via calendar (preferred)

Run the keyword classifier on the calendar event:

```bash
python3 -c "
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path.home() / '.claude/skills/call-capture'))
from scripts.classify_keywords import classify_from_calendar
config = json.load(open(Path.home() / '.lfg/call-pipeline.json'))
result = classify_from_calendar('<event_title>', '<event_description>', config)
print(json.dumps(result))
"
```

If non-null: use it (`type`, `confidence=0.95`, `source='calendar'`). Skip to Step 5.

### Step 4b: Classify via AI (fallback)

Send the first 2 minutes of transcript (filter index entries with `start_seconds < 120`) to Claude Haiku 4.5 via Anthropic SDK. System prompt:

> Classify this call transcript into: coaching, sales, workshop, group, unknown. Return JSON: {"type": "...", "confidence": 0.0-1.0, "reasoning": "..."}. Use "unknown" if you can't tell.

Set `source='ai'`. If `confidence < 0.7`, set `type='unknown'`.

### Step 5: Extract structured data

Run the extraction module on the full transcript. Make sure `ANTHROPIC_API_KEY` is set in the environment — students set this in their shell profile during setup.

```bash
python3 -c "
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path.home() / '.claude/skills/call-capture'))
from scripts.extract import extract_from_transcript
result = extract_from_transcript('<call_type>', '''<full transcript text>''')
print(json.dumps(result))
"
```

Returns `{summary, action_items[], content_ideas[]}`.

### Step 6: Write to Supabase

Use `mcp__supabase__execute_sql` to insert:

1. One row in `calls` (capture the returned `id`):

```sql
INSERT INTO calls (
  zoom_meeting_id, zoom_recording_id, call_date, duration_minutes, topic,
  call_type, classification_source, classification_confidence,
  attendees, transcript_url, transcript_text, summary
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9::jsonb, $10, $11, $12
) RETURNING id;
```

2. One row per action item (FK to `calls.id`)
3. One row per content idea (FK to `calls.id`)

Use parameterized SQL. Cast jsonb fields explicitly.

### Step 7: Write to Notion

Read `~/.lfg/call-pipeline.json` for `notion.calls_data_source_id`.

Use `mcp__notion__notion-create-pages` with `parent.data_source_id` = the value from config.

Properties (must match the names exactly — see the Notion template spec):
- Title: `[<type>] — <topic> — <YYYY-MM-DD>`
- Date: call_date
- Type: select value matching call_type
- Duration: duration_minutes (number)
- Summary: summary text
- Action Items: short summary like `"<N> items — see page ↓"`. Full list lives in the page body (heading_2 "✅ Action Items" + bulleted_list_item per task)
- Content Ideas: short summary like `"<N> ideas — see page ↓"`. Full list goes in page body via /mine-calls
- Transcript: transcript_url
- Supabase ID: the uuid from Step 6

### Step 8: Update Supabase with notion_page_id

```sql
UPDATE calls SET notion_page_id = '<page_id>' WHERE id = '<call_id>';
```

### Step 9: Report

For each processed call:

```
✅ Processed: [<type>] <topic> (<duration> min) — <action_count> actions, <idea_count> ideas
```

Or for skipped/failed:

```
⏭ Skipped: <reason>
❌ Failed: <reason> — <call topic>
```

## Error handling

- **Recording not yet ready** (Zoom 404 or "processing"): skip, will retry next run.
- **Calendar MCP timeout**: skip Steps 3-4a, fall through to Step 4b (AI classify).
- **Claude API failure on extraction**: insert the `calls` row with `summary=null`, no action_items/content_ideas. Log: "extraction failed, run /process-calls --retry-failed".
- **Notion API failure**: leave `notion_page_id` null. Report: "Supabase row created, Notion sync failed."
- **Empty/short transcript** (< 30 sec or no cues): skip extraction, set `call_type='unknown'`, write minimal Supabase row.
- **Config file missing or malformed**: print "Config not found at ~/.lfg/call-pipeline.json — run /lfg:setup-call-pipeline." Abort.

## Arguments

- `/process-calls` — default, last 24h
- `/process-calls --retry-failed` — also retry rows where `summary IS NULL`
- `/process-calls --sync-notion` — retry rows where `notion_page_id IS NULL`

## Resources

- `config/call-types.json` — keyword → type map (note: superseded by `~/.lfg/call-pipeline.json` which contains the same fields; this file is shipped as fallback example)
- `scripts/parse_vtt.py` — VTT → text + timestamp index
- `scripts/classify_keywords.py` — calendar event → type
- `scripts/extract.py` — Claude Haiku 4.5 extraction
- `references/extraction-prompt.md` — extraction prompt template (edit to tune for your voice)
