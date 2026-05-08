#!/usr/bin/env python3
"""Time-spent audit — queries ActivityWatch, categorizes activity, prints clean summary.

Usage:
  audit.py                          # today (since midnight local) → now
  audit.py today
  audit.py morning                  # 9:00am → 12:00pm today
  audit.py afternoon                # 12:00pm → 4:00pm today
  audit.py "last 2h"                # last 2 hours
  audit.py yesterday
  audit.py 09:00-12:30              # explicit window today
"""

import json
import sys
import re
import urllib.request
import urllib.parse
from datetime import datetime, timedelta, timezone
from pathlib import Path
from collections import defaultdict

AW_BASE = "http://localhost:5600/api/0"
SKILL_DIR = Path(__file__).parent
CATEGORIES = json.loads((SKILL_DIR / "categories.json").read_text())["categories"]
LOCAL_TZ = datetime.now().astimezone().tzinfo


def aw_get(path):
    with urllib.request.urlopen(f"{AW_BASE}{path}", timeout=5) as r:
        return json.loads(r.read())


def parse_range(arg):
    """Return (start_local, end_local) as tz-aware datetimes."""
    now = datetime.now(LOCAL_TZ)
    today_midnight = now.replace(hour=0, minute=0, second=0, microsecond=0)

    if not arg or arg == "today":
        return today_midnight, now
    if arg == "yesterday":
        y = today_midnight - timedelta(days=1)
        return y, today_midnight
    if arg == "morning":
        return today_midnight.replace(hour=9), today_midnight.replace(hour=12)
    if arg == "afternoon":
        return today_midnight.replace(hour=12), today_midnight.replace(hour=16)
    if arg == "evening":
        return today_midnight.replace(hour=16), today_midnight.replace(hour=21)

    m = re.match(r"last\s+(\d+)\s*h(ours?)?", arg.strip(), re.I)
    if m:
        return now - timedelta(hours=int(m.group(1))), now

    m = re.match(r"(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})", arg.strip())
    if m:
        s = today_midnight.replace(hour=int(m.group(1)), minute=int(m.group(2)))
        e = today_midnight.replace(hour=int(m.group(3)), minute=int(m.group(4)))
        return s, e

    raise SystemExit(f"Couldn't parse time range: {arg!r}. Try 'today', 'morning', 'last 2h', or '09:00-12:30'.")


def fetch_events(bucket_id, start, end):
    qs = urllib.parse.urlencode({
        "start": start.astimezone(timezone.utc).isoformat(),
        "end": end.astimezone(timezone.utc).isoformat(),
        "limit": 50000,
    })
    return aw_get(f"/buckets/{bucket_id}/events?{qs}")


def find_buckets():
    buckets = aw_get("/buckets/")
    window = next((bid for bid in buckets if bid.startswith("aw-watcher-window")), None)
    afk = next((bid for bid in buckets if bid.startswith("aw-watcher-afk")), None)
    web = [bid for bid in buckets if bid.startswith("aw-watcher-web")]
    return window, afk, web


def afk_intervals(afk_events):
    """Return list of (start_iso, end_iso) for AFK ranges."""
    intervals = []
    for ev in afk_events:
        if ev["data"].get("status") != "afk":
            continue
        start = datetime.fromisoformat(ev["timestamp"].replace("Z", "+00:00"))
        intervals.append((start.timestamp(), start.timestamp() + ev["duration"]))
    return intervals


def overlaps_afk(ts_start, duration, afk_ranges):
    ts_end = ts_start + duration
    for a, b in afk_ranges:
        if ts_start < b and ts_end > a:
            return min(ts_end, b) - max(ts_start, a)
    return 0


_TITLE_NOISE = re.compile(
    r"\s*-\s*(High memory usage|Audio playing|Camera in use)[^-]*",
    re.I,
)


def clean_title(t):
    if not t:
        return ""
    t = _TITLE_NOISE.sub("", t)
    t = re.sub(r"\s*-\s*\d+(\.\d+)?\s*(MB|GB)\b[^-]*", "", t, flags=re.I)
    return t.strip()


def categorize(app, title, url=""):
    title_l = (title or "").lower()
    url_l = (url or "").lower()
    catchall = None
    for cat in CATEGORIES:
        if cat.get("catchall"):
            catchall = cat
            continue
        for rule in cat.get("rules", []):
            if "app" in rule and rule["app"] == app:
                return cat
            if "title_contains" in rule and rule["title_contains"].lower() in title_l:
                return cat
            if "url_contains" in rule and url_l and rule["url_contains"].lower() in url_l:
                return cat
    return catchall or {"name": "Other", "icon": "❓"}


def fmt_dur(seconds):
    s = int(seconds)
    h, rem = divmod(s, 3600)
    m, _ = divmod(rem, 60)
    if h:
        return f"{h}h {m:>2}m"
    return f"{m}m"


def fmt_time(dt):
    return dt.astimezone(LOCAL_TZ).strftime("%-I:%M%p").lower()


def main():
    arg = " ".join(sys.argv[1:]) or "today"
    start, end = parse_range(arg)

    window_bucket, afk_bucket, web_buckets = find_buckets()
    if not window_bucket:
        raise SystemExit("No aw-watcher-window bucket found. Is ActivityWatch running?")

    win_events = fetch_events(window_bucket, start, end)
    afk_events = fetch_events(afk_bucket, start, end) if afk_bucket else []
    afk_ranges = afk_intervals(afk_events)

    web_events_by_ts = {}
    for wb in web_buckets:
        for ev in fetch_events(wb, start, end):
            ts = datetime.fromisoformat(ev["timestamp"].replace("Z", "+00:00")).timestamp()
            web_events_by_ts[round(ts)] = ev["data"].get("url", "")

    cat_totals = defaultdict(float)
    cat_top_titles = defaultdict(lambda: defaultdict(float))
    total_active = 0.0
    total_afk = 0.0
    timeline = []  # (ts_start, duration, category_name, clean_title) — for switches/blocks

    for ev in win_events:
        ts = datetime.fromisoformat(ev["timestamp"].replace("Z", "+00:00")).timestamp()
        dur = ev["duration"]
        if dur <= 0:
            continue
        afk_overlap = overlaps_afk(ts, dur, afk_ranges)
        active_dur = dur - afk_overlap
        total_afk += afk_overlap
        if active_dur <= 0:
            continue

        app = ev["data"].get("app", "")
        title = ev["data"].get("title", "")
        url = web_events_by_ts.get(round(ts), "")
        cat = categorize(app, title, url)
        ct = clean_title(title)

        cat_totals[cat["name"]] += active_dur
        cat_top_titles[cat["name"]][ct[:60]] += active_dur
        total_active += active_dur
        timeline.append((ts, active_dur, cat["name"], ct))

    # sort by total, but keep "Other" last
    ordered = sorted(cat_totals.items(), key=lambda kv: (-kv[1] if kv[0] != "Other" else 1))

    # Pass 1: smooth out micro-interruptions. If an event is <30s and sits between
    # two events of the same category, reassign its category to match. This absorbs
    # quick alt-tabs (e.g. Canva → 15s Claude → Canva) into one block.
    sorted_tl = sorted(timeline)
    smoothed = []
    for i, (ts, dur, c, t) in enumerate(sorted_tl):
        if dur < 30 and 0 < i < len(sorted_tl) - 1:
            prev_c = sorted_tl[i - 1][2]
            next_c = sorted_tl[i + 1][2]
            if prev_c == next_c and prev_c != c:
                c = prev_c
        smoothed.append((ts, dur, c, t))

    # Pass 2: merge same-category events with gap < 3min into blocks.
    blocks = []
    cur = None
    for ts, dur, c, t in smoothed:
        if cur and cur["cat"] == c and ts - cur["end"] < 180:
            cur["end"] = ts + dur
            cur["dur"] += dur
            cur["titles"][t] += dur
        else:
            if cur:
                blocks.append(cur)
            cur = {"start": ts, "end": ts + dur, "dur": dur, "cat": c,
                   "titles": defaultdict(float)}
            cur["titles"][t] += dur
    if cur:
        blocks.append(cur)

    # For display, only blocks >= 60s. Smaller ones still affect summary totals.
    display_blocks = [b for b in blocks if b["dur"] >= 60]

    # Switches = transitions between display blocks
    switches = max(0, len(display_blocks) - 1)

    # Longest block
    longest_block = max((b["dur"] for b in blocks), default=0.0)
    longest_block_cat = next((b["cat"] for b in blocks if b["dur"] == longest_block), None)

    # render
    icon_for = {c["name"]: c.get("icon", "  ") for c in CATEGORIES}
    print()
    print(f"Time spent: {fmt_time(start)} – {fmt_time(end)} "
          f"({fmt_dur(total_active)} active, {fmt_dur(total_afk)} afk)")
    print("━" * 64)

    # TIMELINE
    print("\n📍 TIMELINE")
    print("─" * 64)
    for b in display_blocks:
        bstart = datetime.fromtimestamp(b["start"], tz=timezone.utc)
        time_label = fmt_time(bstart)
        dur_label = f"({fmt_dur(b['dur'])})"
        icon = icon_for.get(b["cat"], "  ")
        # dominant title for this block
        top_title = max(b["titles"].items(), key=lambda kv: kv[1])[0]
        if top_title and top_title.strip():
            print(f"  {time_label:<8} {dur_label:>7}  {icon} {b['cat']:<26} {top_title[:50]}")
        else:
            print(f"  {time_label:<8} {dur_label:>7}  {icon} {b['cat']}")

    # SUMMARY
    print("\n📊 SUMMARY")
    print("─" * 64)
    for name, secs in ordered:
        if secs < 30:
            continue
        pct = (secs / total_active * 100) if total_active else 0
        icon = icon_for.get(name, "  ")
        print(f"{icon}  {name:<28} {fmt_dur(secs):>8}  ({pct:>4.0f}%)")
        # top 2 specific titles for transparency (skip if catchall)
        if name != "Other":
            top = sorted(cat_top_titles[name].items(), key=lambda kv: -kv[1])[:2]
            for t, ts in top:
                if ts >= 60 and t.strip():
                    print(f"      └ {t}  ({fmt_dur(ts)})")

    print("━" * 64)
    headline_bits = []
    if longest_block >= 600 and longest_block_cat:
        headline_bits.append(f"longest deep block: {fmt_dur(longest_block)} on {longest_block_cat}")
    headline_bits.append(f"{switches} switches")
    if not web_buckets:
        headline_bits.append("⚠ no browser ext (URL detail off)")
    print("  " + " · ".join(headline_bits))
    print()


if __name__ == "__main__":
    main()
