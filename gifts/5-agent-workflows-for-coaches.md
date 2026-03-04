# 5 Agent Workflows for Coaches

These are copy-paste multi-agent recipes. Each one spawns multiple Claude agents that work simultaneously — like having a team instead of one assistant.

**How to use:** Copy the prompt. Paste it into Claude Code. Fill in the [BRACKETS]. Watch multiple agents spin up and work at the same time. All results are saved to files you can use immediately.

**Why this works:** Agents run in parallel. Instead of asking Claude to do 3 things one at a time (slow), you tell it to do all 3 at once (fast). Same quality. 3x the speed.

---

## 1. Niche Deep Dive (Research Team)

The exact workflow from Lesson 3. Three agents go online and research your entire coaching niche simultaneously.

```
I need a deep dive on my coaching niche. Spawn 3 research agents that work simultaneously:

Agent 1 — Pain Points & Desires: Research the top pain points and desires of [YOUR IDEAL CLIENT]. What are they searching for? What are they complaining about in forums, Reddit, Facebook groups? What do they WISH existed? Save to ./niche-research-pain-points.md

Agent 2 — Competitor Landscape: Research who's coaching [YOUR NICHE] well. Who are the top 5-10 coaches/programs? What do they charge? How do they position themselves? What's their unique angle? Save to ./niche-research-competitors.md

Agent 3 — Content Gaps & Opportunities: Research what content exists (and what's MISSING) in [YOUR NICHE]. What topics get engagement? What questions go unanswered? What angles is nobody using? Save to ./niche-research-content-gaps.md

Each agent should use WebSearch to find real, current data. Open all 3 files when done.
```

---

## 2. Content Blitz (1 Topic → 3 Pieces)

One coaching topic, three pieces of content, all created simultaneously.

```
Content Blitz on this topic: [YOUR TOPIC]

Spawn 3 agents simultaneously:

Agent 1 — Instagram Post: Write a carousel-style caption (hook, 5 value points, CTA) about this topic for my coaching audience. Include hashtag suggestions. Save to ./content-blitz-instagram.md

Agent 2 — Email Newsletter: Write a full email about this topic. Subject line options (3), preview text, body (story → lesson → CTA format), and a PS line. Save to ./content-blitz-email.md

Agent 3 — Video Script (60 seconds): Write a short-form video script. Hook (first 3 seconds), 3 quick points, CTA. Include delivery notes (pace, tone, where to look). Save to ./content-blitz-video.md

Use my voice from CLAUDE.md. All content should reference my ideal clients specifically. Open all 3 files when done.
```

---

## 3. Client Engagement Pack

Three client communication pieces, all personalized and created at once.

```
Build me a Client Engagement Pack. Spawn 3 agents simultaneously:

Agent 1 — Welcome Sequence: Write a 3-message onboarding sequence for new coaching clients. Message 1 = warm welcome + what to expect. Message 2 = first quick win assignment. Message 3 = check-in after first week. Save to ./client-welcome-sequence.md

Agent 2 — Check-In Templates: Write 5 different weekly check-in message templates. Each should feel different — not the same message with swapped words. Mix of: celebration, accountability, curiosity, reflection, and motivation. Save to ./client-check-in-templates.md

Agent 3 — Testimonial & Referral System: Write a testimonial request message (with 3 easy questions), a referral request message, and a "share your win" prompt for social media. Save to ./client-testimonial-referral.md

All in my coaching voice. Make them feel human, not templated. Open all 3 files when done.
```

---

## 4. Workshop Engine

Plan and prepare an entire workshop simultaneously.

```
I'm running a workshop on: [YOUR WORKSHOP TOPIC]

Spawn 3 agents simultaneously:

Agent 1 — Workshop Outline: Create the full workshop structure. Title options (3), the big promise, a 60-minute flow (intro → 3 teaching sections → exercise → transition to offer), key talking points for each section, and the close. Save to ./workshop-outline.md

Agent 2 — Promo Content: Write 5 social media posts to promote the workshop (spread across 7 days). Post 1 = curiosity, Post 2 = pain point, Post 3 = social proof, Post 4 = behind-the-scenes, Post 5 = last call. Plus 2 email invites (early bird + reminder). Save to ./workshop-promo.md

Agent 3 — Follow-Up System: Write the post-workshop follow-up sequence. Message for attendees who signed up (celebration + next steps), message for attendees who DIDN'T sign up (value + open door), and a 48-hour reminder for fence-sitters. Save to ./workshop-followup.md

Use my voice and reference my coaching offer naturally. Open all 3 files when done.
```

---

## 5. Weekly CEO Brief (Research + Strategy)

Your weekly business intelligence briefing — research and analysis running simultaneously.

```
Run my Weekly CEO Brief. Spawn 3 agents simultaneously:

Agent 1 — Market Pulse: Use WebSearch to find what's trending in [YOUR COACHING NICHE] this week. New conversations, viral posts, emerging pain points, competitor moves. What should I be paying attention to? Save to ./ceo-brief-market.md

Agent 2 — Content Performance Review: Based on everything you know about my business, analyze what content themes are working in my niche right now. What hooks are getting engagement? What topics are oversaturated? What should I post about this week? Save to ./ceo-brief-content.md

Agent 3 — Weekly Action Plan: Based on my business goals, write my top 5 priorities for this week. For each: what to do, why it matters, and the expected outcome. Include 1 thing I should STOP doing and 1 opportunity I'm probably missing. Save to ./ceo-brief-actions.md

Be direct. No fluff. I want this in 5 minutes, not 50. Open all 3 files when done.
```

---

**Pro tips:**
- Run the Content Blitz every week and your content is basically done
- The Niche Deep Dive is gold for refining your messaging — run it quarterly
- Workshop Engine saves you 3+ hours of prep per workshop
- Customize these! Change the agents, add more, make them yours

These are YOUR recipes. Edit them. Remix them. Build new ones.

— Dan
