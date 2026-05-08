---
description: "Update the LFG Claude Code course to the latest version. Re-runs the installer to pull the latest skills, lessons, and gifts from GitHub."
---

# /lfg:update — Update the Course

You are updating the LFG Claude Code course to the latest version on the user's machine. New lessons, skills, and gifts may have shipped since they last installed.

## What to do

Run this in bash:

```bash
curl -sL https://raw.githubusercontent.com/LifestyleFounder/lfg-claude-course/main/install.sh | bash
```

The installer is **idempotent** — it safely overwrites existing files with the latest versions from GitHub. No uninstall needed. User customizations to `categories.json` (in the time-spent skill) are preserved.

After it finishes, briefly summarize what's new compared to what they had before. If you don't know what they had, just confirm the install completed and tell them to type `/lfg:start` to see the latest course menu.
