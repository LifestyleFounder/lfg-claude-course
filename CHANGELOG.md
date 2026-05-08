# LFG Claude Code Course — Changelog

> Run `/lfg:update` to pull these. **Restart Claude Code after** so the new skills/commands load into your session.

## 2026-05-08 — Call Pipeline v2: No API Key Required

The advanced **Call Pipeline** module no longer requires an Anthropic API key. Everything now runs inside your Claude Code Pro/Max session.

### What changed

- **No more Anthropic API key.** Extraction and hook mining run in-context using your existing Claude subscription. $0/month additional cost.
- **Setup is shorter:** 4 steps instead of 5 (~20 minutes instead of ~30).
- **New Notion schema:** Calls DB now has split `My Action Items` / `Their Action Items`, plus new `Client`, `Key Quotes`, `Status`, `Mined`, `Digested` properties. `Type` values are capitalized (Sales / Coaching / Workshop / Group / Discovery / Other).
- **Live Notion template URL** baked into setup. No more "build the template yourself."
- **Supabase schema updates:** `call_action_items` now has `owner_type` ('mine' or 'theirs'); `calls` has new `status`, `mined`, `digested`, `client_name`, `key_quotes` columns.

### What you need to do if you already had the pipeline running

⚠️ **Existing users on the old schema have a broken pipeline now.** To migrate:

1. Run `/lfg:update` (you just did, or this changelog wouldn't be on screen)
2. **Restart Claude Code** so the new skills + commands load
3. Re-run `/lfg:setup-call-pipeline` from scratch:
   - Re-run the new Supabase schema (the old `call_type` CHECK constraint will conflict — you may need to drop and recreate the table)
   - Re-duplicate the new Notion template at https://www.notion.so/35a237e12a2c8196bd11e472a353b1ae
   - Re-paste the new database links into the config
4. Old data in Supabase from the previous schema won't auto-migrate. If you want to preserve it, export to CSV first.

### Files added/changed in this release

- `skills/call-capture/SKILL.md` — rewritten for in-context extraction
- `skills/mine-calls/SKILL.md` — rewritten for in-context hook mining
- `skills/call-digest/SKILL.md` — updated property names + status flags
- `skills/call-capture/references/extraction-prompt.md` — adds Key Quotes + owner_type
- `skills/call-capture/scripts/classify_keywords.py` — capitalized Type values
- `commands/lfg/setup-call-pipeline.md` — 4-step flow, no API key step
- `setup/call-pipeline/supabase-schema.sql` — new columns and CHECK constraints
- `setup/call-pipeline/NOTION-TEMPLATE-SPEC.md` — full schema documentation
- `setup/call-pipeline/PDF-LEAD-MAGNET.html` — print-ready setup guide
- `setup/call-pipeline/example-config.json` — capitalized keyword keys

### Files removed

- `skills/call-capture/scripts/extract.py` — obsolete (no API key needed)
- `skills/mine-calls/scripts/mine_call.py` — obsolete (no API key needed)

The installer auto-removes these from existing installs on next `/lfg:update`.

---

## Earlier releases

For changes before 2026-05-08, see git history at `github.com/LifestyleFounder/lfg-claude-course`.
