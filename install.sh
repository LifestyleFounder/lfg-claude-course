#!/bin/bash

# LFG Claude Code Course — Installer
# by Dan Harrison / Lifestyle Founders Group
#
# This script installs the free Claude Code course for coaches.
# Run it with: curl -sL https://raw.githubusercontent.com/LifestyleFounder/lfg-claude-course/main/install.sh | bash

set -e

REPO="https://raw.githubusercontent.com/LifestyleFounder/lfg-claude-course/main"

# Colors
GREEN='\033[0;32m'
GOLD='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  ██╗     ███████╗ ██████╗"
echo "  ██║     ██╔════╝██╔════╝"
echo "  ██║     █████╗  ██║  ███╗"
echo "  ██║     ██╔══╝  ██║   ██║"
echo "  ███████╗██║     ╚██████╔╝"
echo "  ╚══════╝╚═╝      ╚═════╝"
echo ""
echo "  CLAUDE CODE FOR COACHES"
echo "  Installing..."
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

# Helper: download a file from the repo into a destination path
# Usage: dl <repo-relative-source> <local-destination>
dl() {
  curl -sf "$REPO/$1" -o "$2"
}

# Helper: download only if local file doesn't already exist (preserves user edits)
# Usage: dl_seed <repo-relative-source> <local-destination>
dl_seed() {
  if [ ! -f "$2" ]; then
    curl -sf "$REPO/$1" -o "$2"
  fi
}

# Create directories
echo "  Creating directories..."
mkdir -p ~/.claude/commands/lfg
mkdir -p ~/.claude/skills/time-spent
mkdir -p ~/.claude/skills/call-capture/scripts ~/.claude/skills/call-capture/config ~/.claude/skills/call-capture/references
mkdir -p ~/.claude/skills/mine-calls/scripts ~/.claude/skills/mine-calls/references
mkdir -p ~/.claude/skills/call-digest/scripts
mkdir -p ~/.lfg/course ~/.lfg/gifts ~/.lfg/setup

# Download slash commands
echo "  Downloading slash commands..."
for cmd in start lesson-1 lesson-2 lesson-3 lesson-4 skill-builder update setup-call-pipeline; do
  dl "commands/lfg/${cmd}.md" "$HOME/.claude/commands/lfg/${cmd}.md"
done

# Download time-spent skill (multi-file)
# categories.json only seeded on first install — preserves user customizations on update
echo "  Downloading time-spent skill..."
for f in SKILL.md INSTALL.md audit.py; do
  dl "skills/time-spent/${f}" "$HOME/.claude/skills/time-spent/${f}"
done
chmod +x ~/.claude/skills/time-spent/audit.py
dl_seed "skills/time-spent/categories.json" "$HOME/.claude/skills/time-spent/categories.json"

# Download advanced module — call pipeline (call-capture + mine-calls + call-digest)
echo "  Downloading call-pipeline skills..."
for f in SKILL.md scripts/__init__.py scripts/parse_vtt.py scripts/classify_keywords.py scripts/extract.py references/extraction-prompt.md; do
  dl "skills/call-capture/${f}" "$HOME/.claude/skills/call-capture/${f}"
done
dl_seed "skills/call-capture/config/call-types.json" "$HOME/.claude/skills/call-capture/config/call-types.json"

for f in SKILL.md scripts/__init__.py scripts/mine_call.py references/hook-prompt.md; do
  dl "skills/mine-calls/${f}" "$HOME/.claude/skills/mine-calls/${f}"
done

for f in SKILL.md scripts/__init__.py scripts/format_digest.py; do
  dl "skills/call-digest/${f}" "$HOME/.claude/skills/call-digest/${f}"
done

# Setup files for the call pipeline (Supabase schema + example config)
echo "  Downloading call-pipeline setup files..."
dl "setup/call-pipeline/supabase-schema.sql" "$HOME/.lfg/setup/supabase-schema.sql"
dl "setup/call-pipeline/example-config.json" "$HOME/.lfg/setup/call-pipeline-example-config.json"

# Download course support files
echo "  Downloading course support files..."
for f in fun-facts course-guide; do
  dl "course/${f}.md" "$HOME/.lfg/course/${f}.md"
done

# Download gift files
echo "  Downloading gifts..."
for f in 30-ai-prompts-for-coaches 5-agent-workflows-for-coaches coaching-business-templates; do
  dl "gifts/${f}.md" "$HOME/.lfg/gifts/${f}.md"
done

# Verify
COMMANDS=$(ls ~/.claude/commands/lfg/*.md 2>/dev/null | wc -l | tr -d ' ')
TIME_SPENT=$(ls ~/.claude/skills/time-spent/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
CALL_PIPELINE=$(ls ~/.claude/skills/call-capture/SKILL.md ~/.claude/skills/mine-calls/SKILL.md ~/.claude/skills/call-digest/SKILL.md 2>/dev/null | wc -l | tr -d ' ')

echo ""

if [ "$COMMANDS" -ge 8 ] && [ "$TIME_SPENT" -ge 1 ] && [ "$CALL_PIPELINE" -ge 3 ]; then
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  echo -e "  ${GREEN}${BOLD}✅ LFG Claude Code Course — INSTALLED${NC}"
  echo ""
  echo "  8 commands installed"
  echo "  4 skills installed (time-spent + call-capture + mine-calls + call-digest)"
  echo "  3 gift files ready"
  echo "  2 course support files ready"
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  echo -e "  ${BOLD}Next step:${NC}"
  echo ""
  echo -e "  1. Open Claude Code"
  echo -e "  2. Type ${GOLD}${BOLD}/lfg:start${NC} and hit enter"
  echo ""
  echo "  That's it. I'll walk you through everything from there."
  echo ""
  echo -e "  ${BOLD}Available commands:${NC}"
  echo -e "  • ${GOLD}/lfg:start${NC} through ${GOLD}/lfg:lesson-4${NC} — the free 4-lesson course"
  echo -e "  • ${GOLD}/lfg:skill-builder${NC} — build a custom skill from a conversation"
  echo -e "  • ${GOLD}/lfg:update${NC} — pull future course updates"
  echo -e "  • ${GOLD}/time-spent${NC} — audit your Mac time (needs ActivityWatch)"
  echo ""
  echo -e "  ${BOLD}Advanced module (premium):${NC}"
  echo -e "  • ${GOLD}/lfg:setup-call-pipeline${NC} — configure the call pipeline"
  echo -e "  • ${GOLD}/process-calls${NC} — capture Zoom calls → Supabase + Notion"
  echo -e "  • ${GOLD}/mine-calls${NC} — extract content ideas in your voice"
  echo -e "  • ${GOLD}/call-digest${NC} — daily digest emailed to you"
  echo "    (Run ${GOLD}/lfg:setup-call-pipeline${NC} first to wire up Zoom + Supabase + Notion.)"
  echo ""
  echo "  — Dan"
  echo ""
else
  echo "  ❌ Something went wrong."
  echo "  Got: $COMMANDS commands, $TIME_SPENT time-spent skill files, $CALL_PIPELINE call-pipeline skills."
  echo "  Try running the command again, or check your internet connection."
  echo ""
fi
