---
name: time-spent
description: Audit time spent on the Mac via ActivityWatch — categorized breakdown by activity (dev, content, comms, distractions), with active vs. AFK time, longest deep-work block, and context switches. Use when asked "where did my time go", "time audit", "what did I do this morning", "time spent today/yesterday", or for end-of-day recaps.
---

# Time-Spent Audit

Pulls active-window data from ActivityWatch (running locally on `:5600`) and produces a clean categorized summary aligned to your actual work — not raw app names.

## How to use

Run the script. Pass an optional time range as an argument.

```bash
python3 ~/.claude/skills/time-spent/audit.py today
python3 ~/.claude/skills/time-spent/audit.py morning        # 9am–12pm
python3 ~/.claude/skills/time-spent/audit.py afternoon      # 12pm–4pm
python3 ~/.claude/skills/time-spent/audit.py "last 2h"
python3 ~/.claude/skills/time-spent/audit.py yesterday
python3 ~/.claude/skills/time-spent/audit.py 09:00-12:30
```

The output is **already formatted for the user** — print it verbatim, do NOT re-summarize the table. Then add a 1-2 sentence interpretation at the bottom (deep work? distracted? where the day actually went).

## Categories

Defined in `categories.json` (same dir). First match wins. To add or rename a bucket, edit that file — no code change needed.

The starter categories are tuned to a coach/founder workflow (dev, Claude/AI, content, design, community, ads, email, comms, video, distraction). Open `categories.json` and edit the rules to match your apps and window titles. The file has a comment at the top explaining the format.

If "Other" is more than ~10% of the total, ask the user if they want you to look at what's hiding in there and add rules — the script can be re-run on the same window to inspect uncategorized titles.

## Browser URL detail (optional, recommended)

Without a browser extension, all Chrome activity is identified only by window title (which is usually fine — page title leaks the context). With the extension, AW captures URLs too, enabling URL-based rules.

To install:
- **Chrome:** https://chromewebstore.google.com/detail/activitywatch-web-watcher/nglaklhklhcoonedhgnpgddginnjdadi
- **Safari:** https://apps.apple.com/us/app/aw-watcher-safari/id1620596502

After install, restart Chrome. The script auto-detects `aw-watcher-web-*` buckets and merges URL data with window events.

## Notes

- Script uses stdlib only — no `pip install` needed.
- AFK overlap is computed from `aw-watcher-afk` so idle time doesn't inflate active totals.
- "Context switches" counts category transitions across the time range — high number = fragmented work; low number with one big block = deep focus.
- ActivityWatch must be running. If the script errors with connection refused, open the AW tray app.
