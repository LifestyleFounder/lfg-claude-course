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
  client_name                 TEXT,
  call_type                   TEXT NOT NULL CHECK (call_type IN ('Sales', 'Coaching', 'Workshop', 'Group', 'Discovery', 'Other')),
  classification_source       TEXT CHECK (classification_source IN ('calendar', 'transcript', 'manual')),
  classification_confidence   NUMERIC,
  attendees                   JSONB NOT NULL DEFAULT '[]'::jsonb,
  recording_url               TEXT,
  transcript_text             TEXT,
  summary                     TEXT,
  key_quotes                  JSONB NOT NULL DEFAULT '[]'::jsonb,
  status                      TEXT NOT NULL DEFAULT 'Processed' CHECK (status IN ('Processed', 'Mined', 'Digested', 'Failed')),
  mined                       BOOLEAN NOT NULL DEFAULT false,
  digested                    BOOLEAN NOT NULL DEFAULT false,
  notion_page_id              TEXT,
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(zoom_meeting_id)
);

CREATE INDEX IF NOT EXISTS idx_calls_call_date ON calls(call_date DESC);
CREATE INDEX IF NOT EXISTS idx_calls_call_type ON calls(call_type);
CREATE INDEX IF NOT EXISTS idx_calls_status ON calls(status);
CREATE INDEX IF NOT EXISTS idx_calls_mined ON calls(mined);
CREATE INDEX IF NOT EXISTS idx_calls_digested ON calls(digested);

-- ============================================================
-- 2. call_action_items — extracted commitments from each call
-- ============================================================

CREATE TABLE IF NOT EXISTS call_action_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  call_id         UUID NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
  task            TEXT NOT NULL,
  owner_type      TEXT NOT NULL CHECK (owner_type IN ('mine', 'theirs')),
  owner_name      TEXT,
  deadline        TEXT,
  source_quote    TEXT,
  done            BOOLEAN NOT NULL DEFAULT false,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_action_items_call_id ON call_action_items(call_id);
CREATE INDEX IF NOT EXISTS idx_action_items_owner_type ON call_action_items(owner_type);

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
