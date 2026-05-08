---
name: mine-calls
description: Mine call transcripts (already in Supabase) for content ideas — pre-written hooks in your voice, each with format suggestion (reel/carousel/email/workshop), one-line angle, and source quote + timestamp from the call. Writes to call_content_ideas table and updates the Notion Calls DB. Triggered by /mine-calls.
---

# Mine Calls

Reads processed call transcripts from Supabase and produces **pre-written hooks** + format + angle + source reference, ready to drop into a Reel script or carousel without re-watching the call.

Uses Claude **Sonnet 4.5** (better hook quality than Haiku for voice-driven copy).

## When to use

- The user runs `/mine-calls`
- The user says "mine my calls", "get content ideas from today's calls", "what's in last week's calls"
- After `/process-calls` completes and the user wants ideas (not just summaries + actions)

## Prerequisite: config + processed calls

Requires `~/.lfg/call-pipeline.json` (run `/lfg:setup-call-pipeline` first) and at least one processed call in Supabase (run `/process-calls` first).

## What you do

### Step 1: Decide which calls to mine

Default = calls that have a transcript but no content ideas yet:

```sql
SELECT c.id, c.topic, c.call_type, c.call_date, c.duration_minutes, c.transcript_text
FROM calls c
LEFT JOIN call_content_ideas ci ON ci.call_id = c.id
WHERE c.transcript_text IS NOT NULL
  AND c.transcript_text != ''
  AND ci.id IS NULL
ORDER BY c.call_date DESC;
```

If `$ARGUMENTS` contains:
- A call ID (uuid) → only that call
- `--all` → re-mine every call (delete existing ideas first if user wants fresh ones — confirm before)
- `--since 2026-05-01` → only calls on/after that date
- `--type coaching` → only coaching calls

### Step 2: For each call, run the hook miner

```bash
python3 -c "
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path.home() / '.claude/skills/mine-calls'))
from scripts.mine_call import mine_call
transcript = sys.stdin.read()
result = mine_call('<call_type>', transcript)
print(json.dumps(result))
"
```

Pipe the transcript text to stdin. Returns `{"ideas": [...]}`.

`ANTHROPIC_API_KEY` must be set in the environment (set during `/lfg:setup-call-pipeline`).

If the transcript is very long (> ~30k tokens), the call will still work but cost more. That's fine for this skill — quality matters here.

### Step 3: Write ideas to Supabase

For each idea returned, INSERT into `call_content_ideas`:

```sql
INSERT INTO call_content_ideas (call_id, format, angle, hook, source_quote, timestamp_seconds, used)
VALUES ($1, $2, $3, $4, $5, $6, false);
```

Use `mcp__supabase__execute_sql`. Cap at 5 ideas per call (the prompt enforces this but defensive coding).

### Step 4: Render ideas as Notion blocks in the page BODY (not in the property column)

The `Content Ideas` rich_text property on the row should hold ONLY a short summary like `"5 ideas — see page ↓"`. The full formatted ideas go into the page body as proper Notion blocks so the formatting actually renders (real bold, real headings, real spacing — not raw markdown text).

**Per call**, append this block sequence to the page body using `mcp__notion__API-patch-block-children`:

1. `heading_2` — text: `"💡 Content Ideas"` (skip if already present from a prior run)
2. `divider`
3. **Per idea**, in order:
   - `heading_3` — text: `"<N>. <FORMAT_UPPERCASE> · <MM:SS or H:MM:SS>"` (heading gives the bold section break)
   - `paragraph` — rich_text: `"<hook>"`, with `annotations.bold = true` (focal phrase, the actual hook)
   - `paragraph` — rich_text: `<angle>` (no annotations — the why-it-works line)
   - `paragraph` — rich_text: `↳ "<source_quote>"`, with `annotations.italic = true` and `annotations.color = "gray"` (subdued reference back to the call)
   - `divider` (between ideas; skip after the last idea)

Timestamp format: under 1 hour use `MM:SS` (e.g. `14:23`), over 1 hour use `H:MM:SS` (e.g. `1:22:18`).

After appending body blocks, update the row's `Content Ideas` property to a short summary — e.g. `"5 ideas — see page ↓"` — so the database column view stays clean.

### Step 5: Report

```
✅ Mined <N> calls — <total_ideas> ideas total
   - [<type>] <topic>: <idea_count> ideas → <notion_url>
   - ...
```

If a call had 0 ideas worth surfacing (the prompt enforces a quality bar), report:
```
   - [<type>] <topic>: no ideas crossed the quality bar (transcript may be tactical/admin)
```

## Arguments

- `/mine-calls` — default, mines all unmined calls
- `/mine-calls <call-uuid>` — mine just one call
- `/mine-calls --since 2026-05-01` — only calls on/after that date
- `/mine-calls --type coaching` — filter by call type
- `/mine-calls --all` — re-mine even calls that already have ideas (confirms first)

## Error handling

- **No unmined calls**: "All processed calls have been mined. Pass --all to re-mine."
- **Anthropic API failure**: log error, skip the call, continue with next.
- **Notion update failure**: ideas still go to Supabase. Surface: "Supabase saved, Notion sync failed for: <topic>"
- **Empty transcript**: skip silently.
- **Config file missing**: print "Run /lfg:setup-call-pipeline first." Abort.

## Resources

- `references/hook-prompt.md` — the carefully-crafted hook prompt. **Edit the Voice section** to make hooks sound like you.
- `scripts/mine_call.py` — Sonnet 4.5 caller, returns structured ideas
- Reads: Supabase `calls` + `call_content_ideas` tables
- Writes: Supabase `call_content_ideas` + Notion `Calls` DB Content Ideas column
