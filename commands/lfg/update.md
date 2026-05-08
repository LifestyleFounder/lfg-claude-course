---
description: "Update the LFG Claude Code course to the latest version. Re-runs the installer to pull the latest skills, lessons, and gifts from GitHub, then shows the changelog."
---

# /lfg:update — Update the Course

You are updating the LFG Claude Code course to the latest version on the user's machine. New lessons, skills, and gifts may have shipped since they last installed.

## What to do

### Step 1 — Run the installer

```bash
curl -sL https://raw.githubusercontent.com/LifestyleFounder/lfg-claude-course/main/install.sh | bash
```

The installer is **idempotent** — it safely overwrites existing files with the latest versions from GitHub. It also removes obsolete scripts from prior installs (e.g., the old API-dependent `extract.py` and `mine_call.py`).

User customizations to `categories.json` (in the time-spent skill) are preserved.

### Step 2 — Show the changelog

After the install completes, read and display the freshly-downloaded changelog:

```bash
cat ~/.lfg/CHANGELOG.md
```

Show the user the **most recent release section** (the top entry under the title) so they can see what just landed. Don't dump the whole file — just the latest release.

### Step 3 — Tell them to restart Claude Code

This is **critical** and easy to miss. Display this message prominently:

```
══════════════════════════════════════════════════════════
  ⚠️  RESTART CLAUDE CODE
══════════════════════════════════════════════════════════

The new skills and commands have been written to disk, but
Claude Code only loads them at session start.

To use the new versions:
  1. Quit this Claude Code session (Cmd+Q or close the window)
  2. Reopen Claude Code
  3. New skills and commands will be available

If you skip this step, /process-calls, /mine-calls, /call-digest,
and /lfg:setup-call-pipeline will keep running the OLD versions
that were loaded when you started this session.
══════════════════════════════════════════════════════════
```

### Step 4 — Verify the install (optional)

If they want to confirm the install worked, run:

```bash
ls -lt ~/.claude/commands/lfg/ | head -5
ls -lt ~/.claude/skills/call-capture/SKILL.md ~/.claude/skills/mine-calls/SKILL.md ~/.claude/skills/call-digest/SKILL.md
```

The timestamps should be from within the last minute or two. If they're older, the install didn't run (most likely a permission issue with the `curl | bash` step — the user may need to approve the bash command in Claude Code's permission prompt).

## If the update fails

Common causes:

1. **Permission denied on bash** — Claude Code's permission mode blocked the curl command. Have the user re-run with permissions explicitly granted, or run the curl command manually in a terminal outside Claude Code.

2. **No internet / GitHub down** — Test with `curl -sI https://raw.githubusercontent.com/LifestyleFounder/lfg-claude-course/main/install.sh` — should return `HTTP/2 200`.

3. **Files are read-only** — Check with `ls -l ~/.claude/skills/`. If files are owned by another user or read-only, the install will silently fail. Tell the user to fix permissions: `chmod -R u+w ~/.claude/skills/ ~/.claude/commands/lfg/`.

4. **Stale Claude Code session after install** — The install worked, but Claude Code is still running the old versions because skills load at session start. **This is the most common reason "/lfg:update doesn't work."** Restart Claude Code.
