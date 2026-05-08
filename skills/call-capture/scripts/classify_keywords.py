"""Match Google Calendar event title + description to a call type."""
from __future__ import annotations

from typing import Optional, TypedDict


class Classification(TypedDict):
    type: str
    confidence: float
    source: str


def classify_from_calendar(
    event_title: str,
    event_description: str,
    config: dict,
) -> Optional[Classification]:
    """Return classification if any keyword matches, else None.

    Strategy:
    1. Check client_names (whole-word match) -> coaching
    2. Check calendar_keywords (substring match, case insensitive)
    3. Search title first, then description
    """
    haystack = f"{event_title}\n{event_description}".lower()

    # Client name -> coaching
    for name in config.get("client_names", []):
        if name.lower() in haystack:
            return {"type": "coaching", "confidence": 0.95, "source": "calendar"}

    # Keyword map -> type
    keywords = config.get("calendar_keywords", {})
    for call_type, words in keywords.items():
        for word in sorted(words, key=len, reverse=True):
            if word.lower() in haystack:
                return {"type": call_type, "confidence": 0.95, "source": "calendar"}

    return None
