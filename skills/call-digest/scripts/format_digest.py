"""Format Supabase call rows into a daily digest string."""
from __future__ import annotations


def _format_timestamp(seconds: int) -> str:
    h = seconds // 3600
    m = (seconds % 3600) // 60
    s = seconds % 60
    return f"{h}:{m:02d}:{s:02d}"


def _format_time(iso_str: str) -> str:
    """Extract HH:MMam/pm from an ISO timestamp like '2026-05-04T11:00:00-07:00'."""
    time_part = iso_str.split("T")[1][:5]
    h, m = time_part.split(":")
    h_int = int(h)
    suffix = "am" if h_int < 12 else "pm"
    h12 = h_int if h_int <= 12 else h_int - 12
    if h12 == 0:
        h12 = 12
    return f"{h12}:{m}{suffix}"


def format_digest(calls: list[dict], date: str) -> str:
    """Build the human-readable digest string from a list of call dicts."""
    if not calls:
        return f"CALL DIGEST — {date}\n\nNo calls today.\n"

    unknown_calls = [c for c in calls if c["call_type"] == "unknown"]
    sections: list[str] = []

    sections.append("═══════════════════════════════════════════")
    sections.append(f"CALL DIGEST — {date}")
    sections.append("═══════════════════════════════════════════\n")

    if unknown_calls:
        sections.append("⚠️ UNTAGGED CALLS — needs your tag")
        for c in unknown_calls:
            sections.append(f"  • {_format_time(c['call_date'])} — {c['topic']} ({c['duration_minutes']} min)")
        sections.append("")

    sections.append(f"📊 TODAY'S CALLS ({len(calls)})")
    for c in calls:
        sections.append(
            f"  • {_format_time(c['call_date'])} — {c['topic']} "
            f"({c['call_type']}, {c['duration_minutes']} min)"
        )
    sections.append("")

    all_actions = [(c, a) for c in calls for a in c.get("action_items", [])]
    sections.append(f"✅ ACTION ITEMS ({len(all_actions)})")
    for call, action in all_actions:
        deadline = f" by {action['deadline']}" if action.get("deadline") else ""
        sections.append(f"  • {action['task']}{deadline} [from {call['call_type']}]")
    sections.append("")

    all_ideas = [(c, i) for c in calls for i in c.get("content_ideas", [])]
    sections.append(f"💡 CONTENT IDEAS ({len(all_ideas)})")
    for call, idea in all_ideas:
        ts = _format_timestamp(idea.get("timestamp_seconds", 0))
        sections.append(
            f"  • [{idea['format']}] {idea['angle']} "
            f"[{call['call_type']}, {ts}]"
        )
        if idea.get("hook"):
            sections.append(f"      Hook: \"{idea['hook']}\"")
    sections.append("")

    sections.append("📝 SUMMARIES")
    for c in calls:
        if c.get("summary"):
            sections.append(f"  • {c['topic']}: {c['summary']}")
    sections.append("")

    return "\n".join(sections)
