# Notion Template Spec — Call Pipeline

This is for **Dan** to build the public, duplicatable Notion template that students copy. Do this once. After you publish, update `setup/call-pipeline/PDF-LEAD-MAGNET.html` and the `/lfg:setup-call-pipeline` command with the public URL.

## What you're building

One Notion page titled **"LFG Call Pipeline"** containing two databases:

1. **Calls** — one entry per Zoom recording
2. **Daily Digests** — one entry per day's rollup

Both databases must use the exact property names below — the skills query Notion by name, so any rename breaks the integration.

---

## Database 1 — `Calls`

| Property name      | Type        | Notes |
|--------------------|-------------|-------|
| **Title** *(default)* | Title       | Format: `[<type>] — <topic> — <YYYY-MM-DD>` |
| Date               | Date        | When the call happened |
| Type               | Select      | Options: `coaching`, `sales`, `workshop`, `group`, `unknown`. Use 5 distinct colors. |
| Duration           | Number      | Minutes |
| Summary            | Text        | 3–5 sentence call summary |
| Action Items       | Text        | Set to `"<N> items — see page ↓"`. Real items live in the page body. |
| Content Ideas      | Text        | Set to `"<N> ideas — see page ↓"`. Real ideas live in the page body. |
| Transcript         | URL         | Link to Zoom transcript |
| Supabase ID        | Text        | UUID — for cross-referencing with the Supabase calls table |

**Default view:** Table, sorted by `Date` descending. Group by `Type` (optional).

---

## Database 2 — `Daily Digests`

| Property name        | Type    | Notes |
|----------------------|---------|-------|
| **Title** *(default)*   | Title   | Format: `Call Digest — <YYYY-MM-DD>` |
| Date                 | Date    | The digest's date |
| Number of Calls      | Number  | Today's count |
| Type Breakdown       | Text    | E.g. `2 coaching · 1 sales · 1 group` |

**Default view:** Table, sorted by `Date` descending.

---

## How to publish as a duplicatable template

1. Build the page + 2 databases in your own Notion workspace
2. Add a short README at the top of the page:
   > **LFG Call Pipeline — Notion Template**
   > Click "Duplicate" in the top-right to copy this to your workspace, then follow the setup PDF to connect Zoom + Supabase.
3. Click **Share** → toggle **Publish to web** → ON
4. Toggle **Allow duplicate as template** → ON
5. **Disable** Search engine indexing (it's a private utility, not SEO content)
6. Copy the public URL — it'll look like `https://www.notion.so/lfg/LFG-Call-Pipeline-<id>`

## After publishing

Update three places with the public URL:

1. `setup/call-pipeline/PDF-LEAD-MAGNET.html` — search for `NOTION_TEMPLATE_URL` and replace
2. `commands/lfg/setup-call-pipeline.md` — same placeholder
3. `skills/call-capture/SKILL.md` — at the top, in the Notion setup note

Then commit + push.

## Why these exact property names

The three skills (`/process-calls`, `/mine-calls`, `/call-digest`) write to Notion using property name lookups — not IDs. If a student's duplicated database has slightly different property names ("Action items" vs "Action Items", or "Type" vs "Call Type"), the writes silently fail or land in the wrong column. Locking the names in this spec means students who duplicate cleanly never have to debug property mismatches.

If you want to add more properties (e.g., a Status select for "needs review", a Person property for the attendee), go for it — the skills only touch the properties listed above and ignore extras.
