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

# Create directories
echo "  Creating directories..."
mkdir -p ~/.claude/commands/lfg
mkdir -p ~/.claude/skills/time-spent
mkdir -p ~/.lfg/course
mkdir -p ~/.lfg/gifts

# Download command files (slash commands)
echo "  Downloading course files..."
curl -sf "$REPO/commands/lfg/start.md" -o ~/.claude/commands/lfg/start.md
curl -sf "$REPO/commands/lfg/lesson-1.md" -o ~/.claude/commands/lfg/lesson-1.md
curl -sf "$REPO/commands/lfg/lesson-2.md" -o ~/.claude/commands/lfg/lesson-2.md
curl -sf "$REPO/commands/lfg/lesson-3.md" -o ~/.claude/commands/lfg/lesson-3.md
curl -sf "$REPO/commands/lfg/lesson-4.md" -o ~/.claude/commands/lfg/lesson-4.md
curl -sf "$REPO/commands/lfg/skill-builder.md" -o ~/.claude/commands/lfg/skill-builder.md
curl -sf "$REPO/commands/lfg/update.md" -o ~/.claude/commands/lfg/update.md

# Download time-spent skill (multi-file: SKILL.md + audit.py + categories.json)
# categories.json only seeded on first install — preserves user customizations on update
echo "  Downloading time-spent skill..."
curl -sf "$REPO/skills/time-spent/SKILL.md" -o ~/.claude/skills/time-spent/SKILL.md
curl -sf "$REPO/skills/time-spent/INSTALL.md" -o ~/.claude/skills/time-spent/INSTALL.md
curl -sf "$REPO/skills/time-spent/audit.py" -o ~/.claude/skills/time-spent/audit.py
chmod +x ~/.claude/skills/time-spent/audit.py
if [ ! -f ~/.claude/skills/time-spent/categories.json ]; then
  curl -sf "$REPO/skills/time-spent/categories.json" -o ~/.claude/skills/time-spent/categories.json
fi

# Download course support files
echo "  Downloading course support files..."
curl -sf "$REPO/course/fun-facts.md" -o ~/.lfg/course/fun-facts.md
curl -sf "$REPO/course/course-guide.md" -o ~/.lfg/course/course-guide.md

# Download gift files
echo "  Downloading gifts..."
curl -sf "$REPO/gifts/30-ai-prompts-for-coaches.md" -o ~/.lfg/gifts/30-ai-prompts-for-coaches.md
curl -sf "$REPO/gifts/5-agent-workflows-for-coaches.md" -o ~/.lfg/gifts/5-agent-workflows-for-coaches.md
curl -sf "$REPO/gifts/coaching-business-templates.md" -o ~/.lfg/gifts/coaching-business-templates.md

# Verify
COMMANDS=$(ls ~/.claude/commands/lfg/*.md 2>/dev/null | wc -l | tr -d ' ')
SKILLS=$(ls ~/.claude/skills/time-spent/*.md 2>/dev/null | wc -l | tr -d ' ')

echo ""

if [ "$COMMANDS" -ge 7 ] && [ "$SKILLS" -ge 1 ]; then
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  echo -e "  ${GREEN}${BOLD}✅ LFG Claude Code Course — INSTALLED${NC}"
  echo ""
  echo "  7 commands installed (4 lessons + start + skill-builder + update)"
  echo "  1 skill installed (time-spent — needs ActivityWatch)"
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
  echo -e "  ${BOLD}Already installed before?${NC} You just got new stuff:"
  echo -e "  • ${GOLD}/lfg:update${NC} — pull future updates with one command"
  echo -e "  • ${GOLD}/time-spent${NC} — audit where your day actually goes"
  echo "    (needs ActivityWatch — see ~/.claude/skills/time-spent/INSTALL.md)"
  echo ""
  echo "  — Dan"
  echo ""
else
  echo "  ❌ Something went wrong. Got $COMMANDS commands and $SKILLS skill files."
  echo "  Try running the command again, or check your internet connection."
  echo ""
fi
