# LFG Claude Code Course — Guide

A free interactive course by Dan Harrison that teaches coaches and consultants how to use Claude Code to run their business with AI. 4 lessons, ~30 minutes total, every lesson produces a tangible deliverable.

---

## Overview

**Who it's for:** Coaches, consultants, and service providers aged 35-52 who are non-technical but want to use AI strategically in their business.

**What they walk away with:**
- A personalized AI assistant that knows their business (CLAUDE.md)
- A custom skill they built themselves
- Live niche research from 3 AI agents working simultaneously
- A real, professional web page opened in their browser
- 4 gift files with prompts, workflows, and templates

**How to start:** Type `/lfg:start` in Claude Code.

**Prerequisites:** Claude Code installed and running. That's it.

---

## Course Flow

### `/lfg:start` — Welcome + Overview (~2 min)
- Opens video placeholder at lifestylefounder.com/ai-course
- LFG ASCII banner
- Dan introduces himself: 3x Skool Games winner, $1M+ sold by chat, 4-day work weeks
- Course overview card showing all 4 lessons and what they'll build
- User types `/lfg:lesson-1` to begin

**No auto-invoke.** User controls the pace.

---

### `/lfg:lesson-1` — Build Your AI Assistant (~10 min)
**The goal:** Claude learns their business. They see personalized output.

**Step 1: The 5 Questions**
Dan asks 5 questions one at a time:
1. Name and what they do
2. Who their ideal client is
3. How they communicate (their voice)
4. What tools they use
5. Their dream — if AI could do ONE thing for their business

Coaching analogy: "You're onboarding an AI assistant — like a discovery call for your new team member."

Fun fact connections from `~/.lfg/course/fun-facts.md` are dropped in naturally based on their answers.

**CLAUDE.md Creation:**
After all 5 questions, Claude creates a CLAUDE.md file using their exact words. Then explicitly tells them: "This isn't a one-time thing. You can come back and add more context anytime. The more you add, the smarter Claude gets."

**Step 2: Proof Moment**
User picks from 3 options (content ideas, client outreach, welcome email) or types their own. Claude generates a deeply personalized response and calls out 2-3 specific callbacks from their answers.

**Gift:** Creates `~/.lfg/gifts/30-ai-prompts-for-coaches.md` — 30 coaching-specific prompts in 4 categories.

**Next:** "Type `/lfg:lesson-2` to continue."

---

### `/lfg:lesson-2` — Build Your First Skill (~8 min)
**The goal:** Understand skills and build one from scratch.

**Step 1: Meta Moment**
"You've been using skills this whole course. `/lfg:lesson-1`? That's a skill. A text file with instructions. That's it."

Coaching analogy: "Like an SOP for your assistant."

**Step 2: Look Inside**
Claude reads and displays the `start.md` file. Breaks down the 3 parts: frontmatter, instructions, rules. "No code. Just words."

**Step 3: Build Their Own**
Claude reads their CLAUDE.md, suggests ONE coaching-relevant skill. They build it together. Saved to `~/.claude/commands/my-[name].md`.

Skill ideas: discovery-questions, client-welcome, content-ideas, workshop-outline, session-prep, etc.

**Step 4: Run It (HARD GATE)**
User MUST type `/my-[name]` and respond. Claude celebrates: "You built that."

**Gift:** Creates `~/.claude/commands/lfg/skill-builder.md` — a skill that builds other skills, with coaching-specific suggestions.

**Next:** "Type `/lfg:lesson-3` to continue."

---

### `/lfg:lesson-3` — Your AI Content Team (~12 min)
**The goal:** Experience parallel agents + live internet research.

**Step 1: Explain Agents**
"So far: one Claude, one task. What if you had THREE working at the SAME TIME — and one of them could go ONLINE and research your market?"

Coaching analogy: "Going from solopreneur to having a team — with internet access."

**Step 2: Live Demo — Niche Deep Dive**
3 agents spawn simultaneously via Task tool. ALL 3 use WebSearch:
- Agent 1: Pain points and desires of their ideal client
- Agent 2: Competitor landscape in their niche
- Agent 3: Content gaps and opportunities

Results saved to:
- `./niche-research-pain-points.md`
- `./niche-research-competitors.md`
- `./niche-research-content-gaps.md`

All 3 opened for the user to see.

**Step 3: Their Turn (HARD GATE)**
Pick from 3 options or custom:
1. Content Blitz — 3 agents create IG post, email, and video script
2. Client Engagement Pack — welcome + check-in + testimonial requests
3. Go Deeper — 3 more research agents on a specific angle

Claude spawns real agents, saves results, opens files.

**Gift:** Creates `~/.lfg/gifts/5-agent-workflows-for-coaches.md` — 5 copy-paste multi-agent recipes.

**Next:** "Type `/lfg:lesson-4` to continue."

---

### `/lfg:lesson-4` — Build Something Real + Close (~12 min)
**The goal:** Build a real web page + course finale + CTA.

**Step 1: Callback**
Claude quotes their Q5 dream from CLAUDE.md. Presents 3 personalized build options:
1. Lead magnet landing page
2. Services/programs page
3. Niche research report (formatted HTML of the L3 research)

**Step 2: The Build**
Creates `index.html` with LFG brand aesthetic:
- Fonts: Oswald (headlines), Montserrat (body)
- Colors: Cream #F7F3EA, Forest green #0F2A1E, Gold #C8A24A
- All CSS embedded, mobile-responsive
- Deeply personalized content from CLAUDE.md
- Opens in browser

Claude calls out 2-3 specific personalizations.

**Step 3: Iterate**
2 edit options (visual + content) or custom. Claude makes the edit, re-opens browser. Reinforces the Describe → Build → Iterate pattern.

**Victory Lap:**
Course complete achievement card. Connects the dots: CLAUDE.md + Skills + Agents + Build = "Running your coaching business with AI."

**Gift:** Creates `~/.lfg/gifts/coaching-business-templates.md` — 10 mega-prompts.

**CTA:** "Work with us: https://lifestylefounder.com/application" — earned, not pushed. Anti-bro-marketing.

**Graduation card** signed "— Dan"

---

## Gift Summary

| Lesson | Gift | File Location |
|--------|------|---------------|
| 1 | 30 AI Prompts for Coaches | `~/.lfg/gifts/30-ai-prompts-for-coaches.md` |
| 2 | Skill Builder (skill that builds skills) | `~/.claude/commands/lfg/skill-builder.md` |
| 3 | 5 Agent Workflows for Coaches | `~/.lfg/gifts/5-agent-workflows-for-coaches.md` |
| 4 | Coaching Business Templates (10 mega-prompts) | `~/.lfg/gifts/coaching-business-templates.md` |

---

## Technical Notes

### Distribution
To share the course, users need:
1. Claude Code installed
2. The `~/.claude/commands/lfg/` folder (6 files) copied to their machine
3. The `~/.lfg/` folder will be created automatically as gifts are unlocked

**Simplest method:** A script or zip that copies the commands folder. The gift files are created during the course itself.

### Video Placeholders
Each lesson opens a video URL before starting. Current placeholder: `https://lifestylefounder.com/ai-course`

Update these URLs once videos are recorded:
- `start.md` → Welcome video
- `lesson-1.md` → Lesson 1 video
- `lesson-2.md` → Lesson 2 video
- `lesson-3.md` → Lesson 3 video
- `lesson-4.md` → Lesson 4 video

### Minimum Viable Videos (2)
1. **Welcome** (2-3 min) — for `/lfg:start`
2. **Close** (2-3 min) — for `/lfg:lesson-4` ending

### Recommended Videos (5, one per page)
1. Welcome — what Claude Code is, why coaches need it
2. Lesson 1 — "We're about to build your AI's brain"
3. Lesson 2 — "Skills are just text files" — the meta moment
4. Lesson 3 — "One assistant vs a whole team" — agents + research
5. Lesson 4 — "Claude builds real things" — the build + CTA

Each ~2-3 min. Talking head, casual. Total: ~12-15 min of recording.

### Commands Reference
| Command | Description |
|---------|-------------|
| `/lfg:start` | Welcome + course overview |
| `/lfg:lesson-1` | Build your AI assistant (CLAUDE.md) |
| `/lfg:lesson-2` | Build your first skill |
| `/lfg:lesson-3` | AI content team (agents + research) |
| `/lfg:lesson-4` | Build something real + close |
| `/lfg:skill-builder` | Gift — builds skills on demand |
