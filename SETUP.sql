-- Run this in your Supabase SQL editor before deploying
-- Go to: https://supabase.com/dashboard → your project → SQL Editor

-- CAMPAIGNS
CREATE TABLE IF NOT EXISTS campaigns (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  status TEXT DEFAULT 'draft',
  daily_cap INTEGER DEFAULT 500,
  per_inbox_cap INTEGER DEFAULT 100,
  send_hour_start INTEGER DEFAULT 9,
  send_hour_end INTEGER DEFAULT 17,
  skip_weekends BOOLEAN DEFAULT true,
  timezone TEXT DEFAULT 'America/New_York',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CAMPAIGN STEPS (emails in sequence)
CREATE TABLE IF NOT EXISTS campaign_steps (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  campaign_id UUID REFERENCES campaigns(id) ON DELETE CASCADE,
  step_number INTEGER NOT NULL,
  subject TEXT NOT NULL,
  body TEXT NOT NULL,
  delay_days INTEGER DEFAULT 2,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- CONTACTS
CREATE TABLE IF NOT EXISTS contacts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  campaign_id UUID REFERENCES campaigns(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  first_name TEXT,
  last_name TEXT,
  company TEXT,
  city TEXT,
  phone TEXT,
  custom_fields JSONB DEFAULT '{}',
  status TEXT DEFAULT 'active',
  current_step INTEGER DEFAULT 0,
  assigned_inbox TEXT,
  next_send_at TIMESTAMPTZ,
  enrolled_at TIMESTAMPTZ DEFAULT NOW(),
  finished_at TIMESTAMPTZ,
  UNIQUE(campaign_id, email)
);

-- SEND LOG
CREATE TABLE IF NOT EXISTS sequence_sends (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  campaign_id UUID,
  contact_id UUID,
  email TEXT,
  inbox TEXT,
  step_number INTEGER,
  subject TEXT,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'sent'
);

-- BLACKLIST
CREATE TABLE IF NOT EXISTS blacklist (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- CONTACT STATUSES (replied, bounced etc)
CREATE TABLE IF NOT EXISTS contact_statuses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  status TEXT NOT NULL,
  reason TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- INBOXES
CREATE TABLE IF NOT EXISTS inboxes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  label TEXT,
  active BOOLEAN DEFAULT true,
  daily_cap INTEGER DEFAULT 100,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SETTINGS
CREATE TABLE IF NOT EXISTS settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  webhook_url TEXT,
  daily_cap INTEGER DEFAULT 500,
  per_inbox_cap INTEGER DEFAULT 100,
  send_hour_start INTEGER DEFAULT 9,
  send_hour_end INTEGER DEFAULT 17,
  skip_weekends BOOLEAN DEFAULT true,
  timezone TEXT DEFAULT 'America/New_York',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default settings row
INSERT INTO settings (daily_cap, per_inbox_cap, send_hour_start, send_hour_end, skip_weekends, timezone)
VALUES (500, 100, 9, 17, true, 'America/New_York')
ON CONFLICT DO NOTHING;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_contacts_campaign_status ON contacts(campaign_id, status);
CREATE INDEX IF NOT EXISTS idx_contacts_next_send ON contacts(next_send_at) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_sequence_sends_inbox_date ON sequence_sends(inbox, sent_at);
CREATE INDEX IF NOT EXISTS idx_email_events_campaign ON email_events(campaign);
CREATE INDEX IF NOT EXISTS idx_blacklist_email ON blacklist(email);
