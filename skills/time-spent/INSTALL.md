# Time-Spent — Setup (5 min)

A Claude Code skill that audits your time using ActivityWatch.

The course installer already dropped the skill files into `~/.claude/skills/time-spent/` for you. You just need ActivityWatch running.

## 1. Install ActivityWatch (free, local-only)

Download from https://activitywatch.net → run the installer → make sure the tray icon is running.

That's the only dependency. ActivityWatch is open-source and stores all data on your machine. Nothing leaves your computer.

## 2. Try it out

Open Claude Code and ask:

> Where did my time go this morning?

Or just type `/time-spent`.

You should see a categorized breakdown of where your active time went, with an active vs. AFK split and a quick interpretation.

## 3. (Optional) Tune the categories

The starter `categories.json` covers common founder/coach workflows (dev tools, Claude, content, Canva, Skool, Meta Ads, email, etc.). After your first day or two of running it, look at the **"Other"** bucket — anything in there is unmatched. Add rules to `categories.json` to capture it.

```bash
open ~/.claude/skills/time-spent/categories.json
```

First match wins. Match types:
- `app` — exact app name (e.g., `"Cursor"`, `"Final Cut Pro"`)
- `title_contains` — case-insensitive substring of the window title
- `url_contains` — case-insensitive substring of URL (only if you install the browser extension below)

## 4. (Optional) Install the Chrome extension for URL detail

https://chromewebstore.google.com/detail/activitywatch-web-watcher/nglaklhklhcoonedhgnpgddginnjdadi

Without it, you still get app + window-title categorization (usually plenty). With it, you get URL-level rules — useful for separating "Skool admin" from "Skool browsing", "GitHub coding" from "GitHub browsing", etc.

## Updating

Run `/lfg:update` to pull the latest skill code. The installer **only seeds `categories.json` on first install** — your customizations are preserved on updates. To start fresh from the latest defaults, delete it and re-run:

```bash
rm ~/.claude/skills/time-spent/categories.json
/lfg:update
```
