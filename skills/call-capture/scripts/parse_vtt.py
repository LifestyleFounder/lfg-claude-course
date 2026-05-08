"""Parse Zoom VTT transcript files into plain text + timestamp index."""
from __future__ import annotations

import re
from typing import TypedDict


class TimestampEntry(TypedDict):
    start_seconds: int
    end_seconds: int
    text: str


class ParsedVTT(TypedDict):
    text: str
    index: list[TimestampEntry]


CUE_TIMESTAMP_RE = re.compile(
    r"(\d{2}):(\d{2}):(\d{2})\.\d{3}\s*-->\s*(\d{2}):(\d{2}):(\d{2})\.\d{3}"
)


def _to_seconds(h: str, m: str, s: str) -> int:
    return int(h) * 3600 + int(m) * 60 + int(s)


def parse_vtt(vtt_content: str) -> ParsedVTT:
    """Parse VTT cue blocks. Returns plain text + per-cue timestamp index."""
    if not vtt_content.strip():
        return {"text": "", "index": []}

    lines = vtt_content.splitlines()
    index: list[TimestampEntry] = []
    text_parts: list[str] = []

    i = 0
    while i < len(lines):
        line = lines[i].strip()
        match = CUE_TIMESTAMP_RE.match(line)
        if match:
            start = _to_seconds(match.group(1), match.group(2), match.group(3))
            end = _to_seconds(match.group(4), match.group(5), match.group(6))
            cue_text_lines: list[str] = []
            i += 1
            while i < len(lines) and lines[i].strip():
                cue_text_lines.append(lines[i].strip())
                i += 1
            cue_text = " ".join(cue_text_lines)
            if cue_text:
                index.append({"start_seconds": start, "end_seconds": end, "text": cue_text})
                text_parts.append(cue_text)
        i += 1

    return {"text": "\n".join(text_parts), "index": index}
