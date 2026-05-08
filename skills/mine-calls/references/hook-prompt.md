# Hook Mining Prompt

> Edit the **Voice section** below to tune hook generation for your business. The script `mine_call.py` reads this file at runtime — your edits take effect on the next run.

You're mining a coaching/sales/workshop transcript for content ideas worth turning into a Reel, carousel, email, or workshop angle.

## Voice (CUSTOMIZE THIS)

Replace the block below with a description of your voice. The more specific, the better the hooks.

> **Direct and contrarian. Anti-fluff. Short punchy sentences. Specific numbers over generic claims. Conversational, not corporate. Reframe conventional wisdom. Hook patterns: contradiction, specific number, calling out a hidden trap, naming a 3-word framework.**

Three examples of voices to write here:
- **Anti-bro coach:** "Frank Kern meets Pete Holmes. Anti-bro marketing. Systems over hustle. Freedom over flexing. Spirituality + psychology + comedy + marketing. Short punchy sentences. Conversational."
- **Tactical operator:** "Numbers-first. Tactical, no fluff. Sounds like Alex Hormozi. Short sentences. Specific frameworks named in 3 words or fewer."
- **Warm storyteller:** "Vulnerable, story-driven, supportive. Lots of 'I used to think X, but now…' framings. Real emotion, not performative."

## What counts as a content idea

A moment in the call where you said something — or surfaced something a client said — that contains a punchy, contrarian, or specific insight that could carry a 30-second Reel or a 6-slide carousel.

**Strong signals:**
- A number was specific ("167 apps but only 15 calls", "$5K to $40K MRR in 6 months")
- A common belief got reversed ("you don't have a lead problem, you have a qualification problem")
- A framework got named in 3 words or fewer ("the 3-question filter", "the silent close")
- An emotional moment landed ("I cried when I realized I was the bottleneck")
- A client pattern emerged across multiple sessions ("every plateaued coach over-relies on free content")

**Skip:**
- Generic platitudes ("be authentic", "show up consistently")
- Tactical advice without a story or number
- Ideas that require more than one screen to explain
- Anything that's just restating the call topic

## Output: strict JSON, no markdown

```json
{
  "ideas": [
    {
      "format": "reel | carousel | email | workshop_angle",
      "hook": "the opening line — under 12 words, your voice, would make someone stop scrolling",
      "angle": "1 sentence — the story or insight behind the hook, what makes it work",
      "source_quote": "the line(s) from the transcript that triggered this idea — verbatim",
      "timestamp_seconds": 0
    }
  ]
}
```

## Rules

- Cap at **5 ideas per call**. Quality over quantity. If only 1 strong moment exists, return 1.
- Return `{"ideas": []}` if nothing crosses the quality bar. Never fabricate.
- `hook` must match your voice (defined above): punchy, specific, on-brand. **Reject** corporate-speak, generic motivation, or anything that could appear in 100 other coaches' content.
- `angle` is for your eyes only — explain the idea in 1 sentence so future-you can re-find your thinking.
- `source_quote` must be a direct quote from the transcript so you can grab the audio/clip.
- `timestamp_seconds` should match the source quote's approximate position (use the timestamp index provided).
- Match `format` to the idea's natural shape:
  - **reel**: a single moment, story, or contradiction that lands in 30 seconds
  - **carousel**: a framework or list of 3-7 items that benefits from slide-by-slide reveal
  - **email**: a personal story or longer thinkpiece
  - **workshop_angle**: an objection, theme, or pattern that came up multiple times — useful as a workshop section
