"""Mine a call transcript for content ideas using Claude Sonnet 4.5."""
from __future__ import annotations

import json
import os
import re
from pathlib import Path

import anthropic

PROMPT_PATH = Path(__file__).parent.parent / "references" / "hook-prompt.md"
MODEL = "claude-sonnet-4-5"  # Sonnet for hook quality (vs Haiku in extract.py)

# Lazy-instantiated module-level client. Tests patch this directly.
_anthropic_client = None


def _get_client():
    global _anthropic_client
    if _anthropic_client is None:
        _anthropic_client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    return _anthropic_client


def _strip_code_fences(text: str) -> str:
    """Claude occasionally wraps JSON in ```json fences. Strip them."""
    text = text.strip()
    fence_match = re.match(r"^```(?:json)?\s*\n(.*?)\n```$", text, re.DOTALL)
    if fence_match:
        return fence_match.group(1)
    return text


def mine_call(call_type: str, transcript: str, timestamp_index: list = None) -> dict:
    """Send transcript to Sonnet 4.5 and return structured content ideas.

    Args:
        call_type: coaching | sales | workshop | group | unknown
        transcript: full call transcript text (with speaker labels)
        timestamp_index: optional list of {start_seconds, text} from VTT parser
                         (helps Claude pick accurate timestamp_seconds)

    Returns:
        {"ideas": [{format, hook, angle, source_quote, timestamp_seconds}]}
    """
    prompt_template = PROMPT_PATH.read_text()

    user_parts = [f"call_type: {call_type}\n"]
    if timestamp_index:
        # Compress index into a compact reference for Claude
        idx_lines = [
            f"[{e['start_seconds']}s] {e['text']}"
            for e in timestamp_index[:200]  # cap to keep prompt size sane
        ]
        user_parts.append("timestamp_index (use to pick timestamp_seconds):\n" + "\n".join(idx_lines))
    user_parts.append(f"transcript:\n{transcript}")
    user_parts.append("Return only the JSON object as specified in the system prompt.")

    response = _get_client().messages.create(
        model=MODEL,
        max_tokens=4096,
        system=prompt_template,
        messages=[{"role": "user", "content": "\n\n".join(user_parts)}],
    )

    raw_text = response.content[0].text
    cleaned = _strip_code_fences(raw_text)
    return json.loads(cleaned)
