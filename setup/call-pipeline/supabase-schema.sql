-- LFG Call Pipeline — Supabase Schema
-- Paste this entire file into your Supabase project's SQL Editor and run it.
-- Creates 3 tables that power /process-calls, /mine-calls, and /call-digest.

-- ============================================================
-- 1. calls — one row per Zoom recording processed
-- ============================================================

CREATE TABLE IF NOT EXISTS calls (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  zoom_meeting_id             TEXT NOT NULL,
  zoom_recording_id           TEXT,
  call_date                   TIMESTAMPTZ NOT NULL,
  duration_minutes            INTEGER,
  topic                       TEXT,
  call_type                   TEXT NOT NULL CHECK (call_type IN ('coaching', 'sales', 'workshop', 'group', 'unknown')),
  classification_source       TEXT CHECK (classification_source IN ('calendar', 'ai', 'manual')),
  classification_confidence   NUMERIC,
  attendees                   JSONB NOT NULL DEFAULT '[]'::jsonb,
  transcript_url              TEXT,
  transcript_text             TEXT,
  summary                     TEXT,
  notion_page_id              TEXT,
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(zoom_meeting_id)
);

CREATE INDEX IF NOT EXISTS idx_calls_call_date ON calls(call_date DESC);
CREATE INDEX IF NOT EXISTS idx_calls_call_type ON calls(call_type);

-- ============================================================
-- 2. call_action_items — extracted commitments from each call
-- ============================================================

CREATE TABLE IF NOT EXISTS call_action_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  call_id         UUID NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
  task            TEXT NOT NULL,
  owner           TEXT,
  deadline        TEXT,
  source_quote    TEXT,
  done            BOOLEAN NOT NULL DEFAULT false,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_action_items_call_id ON call_action_items(call_id);
CREATE INDEX IF NOT EXISTS idx_action_items_owner ON call_action_items(owner);

-- ============================================================
-- 3. call_content_ideas — content hooks mined from transcripts
-- ============================================================

CREATE TABLE IF NOT EXISTS call_content_ideas (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  call_id             UUID NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
  format              TEXT NOT NULL CHECK (format IN ('reel', 'carousel', 'email', 'workshop_angle')),
  angle               TEXT,
  hook                TEXT NOT NULL,
  source_quote        TEXT,
  timestamp_seconds   INTEGER,
  used                BOOLEAN NOT NULL DEFAULT false,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_content_ideas_call_id ON call_content_ideas(call_id);
CREATE INDEX IF NOT EXISTS idx_content_ideas_used ON call_content_ideas(used);

-- ============================================================
-- Done. Verify the tables exist:
--   SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'call%';
-- ============================================================
