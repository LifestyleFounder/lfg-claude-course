# Call Transcript Extraction Prompt

> Edit this file to tune the extraction for **your** voice and business. The `call-capture` skill reads this file as guidance when running `/process-calls` — your edits take effect immediately, no restart needed.

You are analyzing a transcript of a coaching, sales, workshop, or group call. Extract structured information.

## Inputs

- `call_type`: one of `Sales`, `Coaching`, `Workshop`, `Group`, `Discovery`, `Other` (already classified)
- `host_name`: the name of the person who runs the business (the owner — usually the user)
- `transcript`: full call transcript with speaker labels and approximate timestamps

## Output: strict JSON, no markdown

```json
{
  "summary": "3-5 sentence summary covering: who attended, what was discussed, outcome",
  "client_name": "the primary attendee who is NOT the host (single name string, or null if unclear)",
  "action_items": [
    {
      "task": "what needs to be done (imperative, specific)",
      "owner_type": "mine | theirs",
      "owner_name": "the actual person's name (use host_name if owner_type=mine, else attendee name)",
      "deadline": "natural language date or null",
      "source_quote": "the line from transcript that established this commitment"
    }
  ],
  "key_quotes": [
    {
      "quote": "verbatim line from a non-host attendee — the kind of thing you'd want to remember",
      "speaker": "name of the speaker (the client/attendee)",
      "timestamp_seconds": 0,
      "why_it_matters": "1-line note: pain language, breakthrough moment, objection, language pattern, etc."
    }
  ],
  "content_ideas": [
    {
      "format": "reel | carousel | email | workshop_angle",
      "angle": "1-sentence pitch — what's the story or insight",
      "hook": "suggested opening line — short, punchy, and matches the host's voice",
      "source_quote": "line from transcript",
      "timestamp_seconds": 0
    }
  ]
}
```

## Rules

- **Action items must be explicit commitments** — "I'll send X by Friday", "you should book the doctor by Tuesday." Skip vague intentions ("we should think about that").
- **owner_type matters**: `mine` = the host committed to it. `theirs` = the attendee/client committed to it. Use the host's name from config to disambiguate.
- **client_name** is the primary non-host attendee. For 1:1 calls this is obvious. For group/workshop calls, return `null`.
- **Key quotes** capture the things you'd want to remember from the call — the client's exact pain phrasing, a breakthrough moment, an objection, a recurring language pattern. 4–8 quotes max. Skip if it's just admin chat.
- **Content ideas** should match the host's voice and audience. Skip generic platitudes. Cap at 5 — pick the highest-leverage moments.
- Return empty arrays if nothing qualifies. Never fabricate.
- `timestamp_seconds` should match the source quote's approximate position.

## Voice notes (CUSTOMIZE THIS SECTION)

Replace the description below with how you want the AI to write hooks for you:

> Direct, conversational, contrarian. Specific numbers over generic claims. Pattern: lead with a tension, follow with a reframe.

Examples of voices to define here:
- **Anti-bro coach:** "Anti-hustle. Systems over grind. Frank Kern meets Pete Holmes. Spirituality + psychology + comedy + marketing."
- **Tactical operator:** "Numbers-first, no fluff. Short sentences. Sounds like Alex Hormozi."
- **Warm storyteller:** "Personal stories, vulnerable, supportive. Lots of 'I used to think X, but now I know Y' framings."
