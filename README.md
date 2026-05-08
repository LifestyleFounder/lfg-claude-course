# LFG Claude Code Course

A free interactive Claude Code course for coaches and consultants by [Dan Harrison](https://lifestylefounder.com) / Lifestyle Founders Group.

4 lessons. ~30 minutes. Build a full AI system for your coaching business.

**New here?** [Start with the welcome page on Skool →](https://www.skool.com/claudeforcoaches/classroom/dea59a65?md=32c85a1be0e84ebcaee669cc4d0c3529) (no signup required to view)

## Install

Paste this into your terminal:

```bash
curl -sL https://raw.githubusercontent.com/LifestyleFounder/lfg-claude-course/main/install.sh | bash
```

Then open Claude Code and type `/lfg:start`.

## What You'll Build

| Lesson | What Happens | What You Get |
|--------|-------------|--------------|
| 1. Build Your AI Assistant | Answer 5 questions, Claude creates your CLAUDE.md | Personalized AI that knows your business |
| 2. Build Your First Skill | Learn what skills are, build one from scratch | A custom command that does real work |
| 3. Your AI Content Team | 3 agents research your niche live on the internet | Competitor, pain point, and content gap reports |
| 4. Build Something Real | Claude builds a web page for your business | A real page opened in your browser |

Plus gifts: 30 AI prompts, a skill builder, 5 agent workflows, 10 coaching business templates, and a Mac time-audit tool.

## Prerequisites

- [Claude Code](https://claude.ai/download) installed
- That's it for the lessons. (The `/time-spent` gift skill also needs [ActivityWatch](https://activitywatch.net), free + local-only.)

## Course Commands

| Command | Description |
|---------|-------------|
| `/lfg:start` | Welcome + course overview |
| `/lfg:lesson-1` | Build your AI assistant |
| `/lfg:lesson-2` | Build your first skill |
| `/lfg:lesson-3` | Your AI content team |
| `/lfg:lesson-4` | Build something real + finale |
| `/lfg:skill-builder` | Gift — builds skills on demand |
| `/lfg:update` | Pull the latest course version (new lessons, skills, fixes) |
| `/time-spent` | Gift skill — audit where your day actually goes (needs ActivityWatch) |

## Advanced Module — The Call Pipeline (Premium)

A three-skill pipeline that captures every Zoom call, extracts structured data, and emails you a daily rollup. Requires Supabase + Notion + Zoom Pro+. ~30-min setup.

| Command | Description |
|---------|-------------|
| `/lfg:setup-call-pipeline` | 5-step interactive setup — Supabase schema, Notion template, MCP servers, API key, config file |
| `/process-calls` | Pulls Zoom recordings → classifies → extracts → writes to Supabase + Notion |
| `/mine-calls` | Generates content hooks (in your voice) from processed transcripts |
| `/call-digest` | End-of-day rollup — Notion page + email |

**[Setup Guide PDF →](https://github.com/LifestyleFounder/lfg-claude-course/blob/main/setup/call-pipeline/PDF-LEAD-MAGNET.html)** (4 pages of setup, troubleshooting, and architecture).

## Updating

When new lessons or skills ship, type `/lfg:update` inside Claude Code (or re-run the install command above). The installer is safe to re-run — it overwrites with the latest from main and preserves any customizations you've made to `~/.claude/skills/time-spent/categories.json`.

## Uninstall

```bash
rm -rf ~/.claude/commands/lfg ~/.claude/skills/time-spent ~/.lfg
```

## About

Built by Dan Harrison — 3x Skool Games winner, founder of [Lifestyle Founders Group](https://skool.com/lfg).

Want to go deeper? [Apply here](https://www.skool.com/quantum100/about).
