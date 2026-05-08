# Notion Template Spec — Call Pipeline

**Live template URL:** https://www.notion.so/35a237e12a2c8196bd11e472a353b1ae

This is the canonical spec for the **LFG Call Pipeline** Notion template. The live URL above is the page students duplicate during `/lfg:setup-call-pipeline`. This file documents the schema so you (Dan) or contributors can audit / rebuild it if needed.

> **Critical:** the skills query Notion by exact property name. Any rename breaks the integration. If you change a name here, you must change it in `skills/call-capture/SKILL.md`, `skills/mine-calls/SKILL.md`, and `skills/call-digest/SKILL.md`.

## What it contains

A single Notion page titled **"LFG Call Pipeline · Database Template"** with two databases nested below:

1. **Calls** — one entry per Zoom recording
2. **Daily Digests** — one entry per day's rollup

The Daily Digests DB has a two-way relation to the Calls DB.

---

## Database 1 — `Calls`

One row per processed Zoom call. Written by `/process-calls` and updated by `/mine-calls` and `/call-digest`.

| Property name        | Type        | Notes |
|----------------------|-------------|-------|
| **Name** *(default)* | Title       | Format: `[<Type>] · <Topic> · <YYYY-MM-DD>` |
| Date                 | Date        | When the call happened |
| Type                 | Select      | Options: `Sales` (red), `Coaching` (blue), `Workshop` (purple), `Group` (orange), `Discovery` (yellow), `Other` (gray) |
| Duration             | Number      | Minutes |
| Client               | Text        | Primary non-host attendee. Empty for group/workshop calls. |
| Summary              | Text        | 3–5 sentence call summary |
| My Action Items      | Text        | Set to `"<N> items — see page ↓"`. Real items live as `to_do` blocks in the page body under `## ✅ My Action Items`. |
| Their Action Items   | Text        | Set to `"<N> items — see page ↓"`. Real items live as `to_do` blocks in the page body under `## 📋 Their Action Items`. |
| Content Ideas        | Text        | Set to `"<N> seeds"` after `/process-calls`, then `"<N> ideas — see page ↓"` after `/mine-calls`. Real ideas live as formatted blocks in the page body. |
| Key Quotes           | Text        | Set to `"<N> quotes — see page ↓"`. Real quotes live as italic paragraphs in the page body. |
| Recording URL        | URL         | Link to the Zoom cloud recording |
| Status               | Select      | Options: `Processed` (blue), `Mined` (purple), `Digested` (green), `Failed` (red). Set by skill order. |
| Mined                | Checkbox    | Set true by `/mine-calls`. Lets the skill skip already-mined calls on the next run. |
| Digested             | Checkbox    | Set true by `/call-digest`. |
| Supabase ID          | Text        | UUID — for cross-referencing with the Supabase `calls` table |

**Default view:** Table, sorted by `Date` descending. Group by `Type` (optional).

---

## Database 2 — `Daily Digests`

One row per day. Written by `/call-digest` at end of day.

| Property name              | Type        | Notes |
|----------------------------|-------------|-------|
| **Name** *(default)*       | Title       | Format: `Daily Digest · <YYYY-MM-DD>` |
| Date                       | Date        | The day being digested |
| Calls Count                | Number      | How many calls were processed that day |
| Action Items Summary       | Text        | Concise rollup of all action items from the day, grouped by call |
| Content Ideas Summary      | Text        | Concise rollup of all content hooks from the day, grouped by call |
| Email Sent                 | Checkbox    | Set true after the digest email goes out |
| Email Sent At              | Date        | Timestamp of when the email fired |
| Calls                      | Relation    | Two-way relation → `Calls` DB. Backlinks to every call included in this digest. The inverse property on the Calls side is named `Daily Digest`. |

**Default view:** Table, sorted by `Date` descending.

**Page body:** the formatted digest as proper Notion blocks (heading_2 per call, paragraph for summary, to_do for action items, bulleted_list_item for content ideas), plus a "View full transcripts in Calls DB" link at the top.

---

## Sharing the template publicly

For students to be able to duplicate the page from outside Dan's workspace:

1. Open the template page in Notion
2. Click **Share** in the top-right
3. Toggle on **Publish to web** — or share with **"Anyone with the link"**
4. Copy the public URL — that's what goes in the lead magnet and setup command

Without this step, the URL only works for people in Dan's workspace.

---

## Rebuilding the template (rare)

If the live template needs to be rebuilt from scratch (corruption, accidental delete, schema overhaul), use the Notion MCP from Claude Code:

1. Create a parent page titled `LFG Call Pipeline · Database Template`
2. Inside, create the Calls database with the schema in Database 1 above
3. Inside, create the Daily Digests database with the schema in Database 2 above (capture the Calls data source ID first so the relation works)
4. Update the URL in:
   - `commands/lfg/setup-call-pipeline.md` (Step 2)
   - `setup/call-pipeline/PDF-LEAD-MAGNET.html` (Step 02 link)
   - This file (top)

## Why these exact property names

The three skills (`/process-calls`, `/mine-calls`, `/call-digest`) write to Notion using property name lookups — not IDs. If a student's duplicated database has slightly different property names ("Action items" vs "My Action Items"), the writes silently fail or land in the wrong column. Locking the names in this spec means students who duplicate cleanly never have to debug property mismatches.

Adding extra properties (e.g., a Person property for the attendee, or extra views) is fine — the skills only touch the properties listed above and ignore extras.
