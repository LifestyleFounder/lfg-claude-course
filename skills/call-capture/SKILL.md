---
name: call-capture
description: Capture Zoom call recordings, transcribe, classify by type (Sales/Coaching/Workshop/Group/Discovery/Other), and store in Supabase + Notion. Use when processing new Zoom calls or after a coaching/sales/workshop call ends. Triggered by /process-calls or hourly cron.
---

# Call Capture

Pulls new Zoom recordings, classifies them, extracts a summary + action items + key quotes + content idea seeds, and writes to Supabase + Notion.

Runs entirely inside your Claude Code session — no Anthropic API key required, no per-call billing. Idempotent — safe to rerun.

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
- `user_name` — used as `host_name` in extraction
- `user_voice_description` — used as voice guidance in extraction
- `client_names`, `calendar_keywords` — for keyword classifier

## What you do

For each unprocessed Zoom recording in the last 24 hours:

### Step 1: Find unprocessed recordings

Use `mcp__zoom__recordings_list` to fetch recordings from the last 24 hours.

For each recording, check Supabase for dedupe via `mcp__supabase__execute_sql`:

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

### Step 4b: Classify via transcript (fallback — you do this in-context)

Read the first 2 minutes of transcript (filter index entries with `start_seconds < 120`) and classify the call yourself based on these heuristics:

- **Sales / Discovery** — host is qualifying a new lead, asking diagnostic questions, talking about offers and prices
- **Coaching** — repeating client by name, working on a specific challenge they brought to the session
- **Workshop / Masterclass** — host is teaching, multiple attendees, structured content delivery
- **Group** — multiple attendees, mix of teaching + Q&A, recurring format (office hours, implementation calls)
- **Other** — none of the above apply cleanly

Pick the closest fit. Set `classification_source='transcript'`. If nothing fits, use `Other`.

### Step 5: Extract structured data (you do this in-context)

Read `~/.claude/skills/call-capture/references/extraction-prompt.md` for the extraction guidance and voice notes. Then read the full transcript and produce the JSON output described in that file.

You are doing the extraction yourself in this Claude Code session — there is no API call, no Python script, no separate billing. Use the host_name from config to determine action item ownership.

The extraction must produce:
- `summary` — 3–5 sentences
- `client_name` — primary non-host attendee, or null
- `action_items[]` — with `owner_type` ('mine' or 'theirs') and `owner_name`
- `key_quotes[]` — 4–8 verbatim non-host lines worth remembering
- `content_ideas[]` — up to 5 hook seeds for `/mine-calls` to refine later

If the transcript is empty or under 30 seconds, skip extraction and write a minimal calls row with `call_type='Other'`.

### Step 6: Write to Supabase

Use `mcp__supabase__execute_sql` to insert:

1. One row in `calls` (capture the returned `id`):

```sql
INSERT INTO calls (
  zoom_meeting_id, zoom_recording_id, call_date, duration_minutes, topic,
  client_name, call_type, classification_source, classification_confidence,
  attendees, recording_url, transcript_text, summary, key_quotes, status
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10::jsonb, $11, $12, $13, $14::jsonb, 'Processed'
) RETURNING id;
```

2. One row per action item in `call_action_items` (FK to `calls.id`) — set `owner_type` and `owner_name` from the extraction
3. One row per content idea seed in `call_content_ideas` (FK to `calls.id`) — these are seeds; `/mine-calls` will produce the polished, voice-tuned hooks

Use parameterized SQL. Cast jsonb fields explicitly.

### Step 7: Write to Notion

Read `~/.lfg/call-pipeline.json` for `notion.calls_data_source_id`.

Use `mcp__notion__notion-create-pages` with `parent.data_source_id` = the value from config.

**Properties** (must match the Notion template exactly — see the spec):

| Property | Value |
|---|---|
| **Name** (Title) | `[<Type>] · <Topic> · <YYYY-MM-DD>` |
| **Date** | call_date |
| **Type** | select value matching call_type (Sales / Coaching / Workshop / Group / Discovery / Other) |
| **Duration** | duration_minutes (number) |
| **Client** | client_name (or empty) |
| **Summary** | summary text |
| **My Action Items** | short summary like `"<N> items — see page ↓"`. Full list lives in the page body. |
| **Their Action Items** | short summary like `"<N> items — see page ↓"`. Full list lives in the page body. |
| **Content Ideas** | short summary like `"<N> seeds — run /mine-calls to polish"`. Full list goes in the page body via /mine-calls. |
| **Key Quotes** | short summary like `"<N> quotes — see page ↓"`. Full list lives in the page body. |
| **Recording URL** | the Zoom recording URL |
| **Status** | `Processed` |
| **Mined** | unchecked |
| **Digested** | unchecked |
| **Supabase ID** | the uuid from Step 6 |

**Page body** (use `mcp__notion__API-patch-block-children`):

1. `heading_2` — `"✅ My Action Items"` followed by `to_do` blocks per item (checked=false). Include the source_quote as a sub-bullet for each.
2. `heading_2` — `"📋 Their Action Items"` followed by `to_do` blocks per item.
3. `heading_2` — `"💬 Key Quotes"` followed by per-quote: `paragraph` with the quote in italic, then a smaller paragraph with `<speaker> · <MM:SS> — <why_it_matters>`.
4. (Content ideas section is appended later by `/mine-calls`.)

### Step 8: Update Supabase with notion_page_id

```sql
UPDATE calls SET notion_page_id = '<page_id>' WHERE id = '<call_id>';
```

### Step 9: Report

For each processed call:

```
✅ Processed: [<Type>] <topic> (<duration> min) — <my_actions>/<their_actions> actions, <quotes> quotes, <seeds> idea seeds
```

Or for skipped/failed:

```
⏭ Skipped: <reason>
❌ Failed: <reason> — <call topic>
```

## Error handling

- **Recording not yet ready** (Zoom 404 or "processing"): skip, will retry next run.
- **Calendar MCP timeout**: skip Steps 3–4a, fall through to Step 4b (transcript-based classify).
- **Extraction unclear** (too short, too noisy): insert the `calls` row with `summary=null`, `status='Failed'`, no action_items/content_ideas. Log: "extraction failed, run /process-calls --retry-failed".
- **Notion API failure**: leave `notion_page_id` null. Report: "Supabase row created, Notion sync failed."
- **Empty/short transcript** (< 30 sec or no cues): skip extraction, set `call_type='Other'`, `status='Failed'`, write minimal Supabase row.
- **Config file missing or malformed**: print "Config not found at ~/.lfg/call-pipeline.json — run /lfg:setup-call-pipeline." Abort.

## Arguments

- `/process-calls` — default, last 24h
- `/process-calls --retry-failed` — also retry rows where `status='Failed'`
- `/process-calls --sync-notion` — retry rows where `notion_page_id IS NULL`

## Resources

- `config/call-types.json` — keyword → type map (note: superseded by `~/.lfg/call-pipeline.json` which contains the same fields; this file is shipped as fallback example)
- `scripts/parse_vtt.py` — VTT → text + timestamp index
- `scripts/classify_keywords.py` — calendar event → type
- `references/extraction-prompt.md` — extraction prompt template (edit to tune for your voice)
