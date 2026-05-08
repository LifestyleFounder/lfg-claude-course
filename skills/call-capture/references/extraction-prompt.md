# Call Transcript Extraction Prompt

> Edit this file to tune the extraction for **your** voice and business. The script `extract.py` reads from this file at runtime. Common edits: add your business context at the top, change "Dan's voice" to a description that matches you.

You are analyzing a transcript of a coaching/sales/workshop/group call. Extract structured information.

## Inputs
- `call_type`: one of coaching/sales/workshop/group (already classified)
- `transcript`: full call transcript with speaker labels and approximate timestamps

## Output: strict JSON, no markdown

```json
{
  "summary": "3-5 sentence summary covering: who attended, what was discussed, outcome",
  "action_items": [
    {
      "task": "what needs to be done (imperative, specific)",
      "owner": "the person responsible — host name | <client/attendee name> | tbd",
      "deadline": "natural language date or null",
      "source_quote": "the line from transcript that established this commitment"
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
- Only extract action items that are explicit commitments ("I'll send X", "you should do Y by Z"). Skip vague intentions.
- Content ideas should match the host's voice and audience. Skip generic platitudes.
- Cap at 10 action items and 5 content ideas. Pick the highest-leverage ones.
- Return empty arrays if nothing qualifies. Never fabricate.
- `timestamp_seconds` should match the source quote's approximate position.

## Voice notes (CUSTOMIZE THIS SECTION)

Replace the description below with how you want the AI to write hooks for you:

> Direct, conversational, contrarian. Specific numbers over generic claims. Pattern: lead with a tension, follow with a reframe.

Examples of voices to define here:
- **Anti-bro coach:** "Anti-hustle. Systems over grind. Frank Kern meets Pete Holmes. Spirituality + psychology + comedy + marketing."
- **Tactical operator:** "Numbers-first, no fluff. Short sentences. Sounds like Alex Hormozi."
- **Warm storyteller:** "Personal stories, vulnerable, supportive. Lots of 'I used to think X, but now I know Y' framings."
