---
name: mine-calls
description: Mine call transcripts (already in Supabase) for content ideas — pre-written hooks in your voice, each with format suggestion (reel/carousel/email/workshop), one-line angle, and source quote + timestamp from the call. Writes to call_content_ideas table and updates the Notion Calls DB. Triggered by /mine-calls.
---

# Mine Calls

Reads processed call transcripts from Supabase and produces **pre-written hooks** + format + angle + source reference, ready to drop into a Reel script or carousel without re-watching the call.

Runs entirely inside your Claude Code session — no Anthropic API key required, no per-call billing. You (Claude) do the hook mining yourself in-context using the prompt at `references/hook-prompt.md` as guidance.

## When to use

- The user runs `/mine-calls`
- The user says "mine my calls", "get content ideas from today's calls", "what's in last week's calls"
- After `/process-calls` completes and the user wants polished, voice-tuned hooks (not just the seed ideas already in `call_content_ideas`)

## Prerequisite: config + processed calls

Requires `~/.lfg/call-pipeline.json` (run `/lfg:setup-call-pipeline` first) and at least one processed call in Supabase (run `/process-calls` first).

## What you do

### Step 1: Decide which calls to mine

Default = calls that haven't been mined yet (`mined = false`):

```sql
SELECT c.id, c.topic, c.call_type, c.call_date, c.duration_minutes, c.transcript_text, c.notion_page_id
FROM calls c
WHERE c.mined = false
  AND c.transcript_text IS NOT NULL
  AND c.transcript_text != ''
ORDER BY c.call_date DESC;
```

If `$ARGUMENTS` contains:
- A call ID (uuid) → only that call
- `--all` → re-mine every call (delete existing ideas first if user wants fresh ones — confirm before)
- `--since 2026-05-01` → only calls on/after that date
- `--type Coaching` → only Coaching calls (capitalized — match the schema)

### Step 2: For each call, mine the hooks (you do this in-context)

Read `~/.claude/skills/mine-calls/references/hook-prompt.md` for the complete mining guidance and your personal voice description. Then read the full transcript and produce up to 5 polished content hooks per call.

You are doing the mining yourself in this Claude Code session — there is no API call, no Python script, no separate billing.

The output for each call must be a JSON object:

```json
{
  "ideas": [
    {
      "format": "reel | carousel | email | workshop_angle",
      "hook": "the opening line — your voice, under 12 words, scroll-stopping",
      "angle": "1-sentence why-it-works note for future-you",
      "source_quote": "verbatim transcript line that triggered this idea",
      "timestamp_seconds": 0
    }
  ]
}
```

If nothing crosses the quality bar (the prompt enforces a quality bar — don't lower it), return `{"ideas": []}`.

### Step 3: Write ideas to Supabase

For each idea returned, INSERT into `call_content_ideas`:

```sql
INSERT INTO call_content_ideas (call_id, format, angle, hook, source_quote, timestamp_seconds, used)
VALUES ($1, $2, $3, $4, $5, $6, false);
```

Use `mcp__supabase__execute_sql`. Cap at 5 ideas per call (the prompt enforces this but defensive coding).

After all ideas are written for a call, mark the call as mined and update its status:

```sql
UPDATE calls
SET mined = true, status = 'Mined'
WHERE id = '<call_id>';
```

### Step 4: Render ideas as Notion blocks in the page BODY

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

After appending body blocks, update the row's properties:
- `Content Ideas` rich_text → short summary like `"5 ideas — see page ↓"`
- `Status` select → `Mined`
- `Mined` checkbox → checked

### Step 5: Report

```
✅ Mined <N> calls — <total_ideas> ideas total
   - [<Type>] <topic>: <idea_count> ideas → <notion_url>
   - ...
```

If a call had 0 ideas worth surfacing (the prompt enforces a quality bar), still mark it as mined (so it doesn't keep appearing in the unmined list) and report:
```
   - [<Type>] <topic>: no ideas crossed the quality bar (transcript may be tactical/admin)
```

## Arguments

- `/mine-calls` — default, mines all unmined calls (`mined = false`)
- `/mine-calls <call-uuid>` — mine just one call
- `/mine-calls --since 2026-05-01` — only calls on/after that date
- `/mine-calls --type Coaching` — filter by call type (Sales / Coaching / Workshop / Group / Discovery / Other)
- `/mine-calls --all` — re-mine even calls already mined (confirms first, then deletes existing ideas before re-mining)

## Error handling

- **No unmined calls**: "All processed calls have been mined. Pass --all to re-mine."
- **Notion update failure**: ideas still go to Supabase. Surface: "Supabase saved, Notion sync failed for: <topic>"
- **Empty transcript**: skip silently (mark as mined so it doesn't recur).
- **Config file missing**: print "Run /lfg:setup-call-pipeline first." Abort.

## Resources

- `references/hook-prompt.md` — the carefully-crafted hook prompt. **Edit the Voice section** to make hooks sound like you.
- Reads: Supabase `calls` + `call_content_ideas` tables
- Writes: Supabase `call_content_ideas` + `calls.mined` + `calls.status` + Notion `Calls` DB Content Ideas column + page body blocks
