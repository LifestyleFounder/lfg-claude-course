"""Send a call transcript to Claude Haiku 4.5 and extract structured fields."""
from __future__ import annotations

import json
import os
import re
from pathlib import Path
from typing import List, Optional, TypedDict

import anthropic

PROMPT_PATH = Path(__file__).parent.parent / "references" / "extraction-prompt.md"
MODEL = "claude-haiku-4-5"

# Lazy-instantiated module-level client. Tests patch this directly.
_anthropic_client: Optional[anthropic.Anthropic] = None


def _get_client() -> anthropic.Anthropic:
    global _anthropic_client
    if _anthropic_client is None:
        _anthropic_client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    return _anthropic_client


class ActionItem(TypedDict):
    task: str
    owner: str
    deadline: Optional[str]
    source_quote: str


class ContentIdea(TypedDict):
    format: str
    angle: str
    hook: str
    source_quote: str
    timestamp_seconds: int


class Extraction(TypedDict):
    summary: str
    action_items: List[ActionItem]
    content_ideas: List[ContentIdea]


def _strip_code_fences(text: str) -> str:
    """Claude occasionally wraps JSON in ```json fences. Strip them."""
    text = text.strip()
    fence_match = re.match(r"^```(?:json)?\s*\n(.*?)\n```$", text, re.DOTALL)
    if fence_match:
        return fence_match.group(1)
    return text


def extract_from_transcript(call_type: str, transcript: str) -> Extraction:
    """Send transcript to Haiku 4.5 and return structured extraction."""
    prompt_template = PROMPT_PATH.read_text()
    user_message = (
        f"call_type: {call_type}\n\n"
        f"transcript:\n{transcript}\n\n"
        "Return only the JSON object as specified in the system prompt."
    )

    response = _get_client().messages.create(
        model=MODEL,
        max_tokens=4096,
        system=prompt_template,
        messages=[{"role": "user", "content": user_message}],
    )

    raw_text = response.content[0].text
    cleaned = _strip_code_fences(raw_text)
    return json.loads(cleaned)
