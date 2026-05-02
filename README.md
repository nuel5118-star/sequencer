# CipherMail Sequencer

Full email sequencing platform. Campaign builder, contact management, scheduling, analytics.

---

## STEP 1 — Supabase Setup

1. Go to https://supabase.com/dashboard
2. Open your project (rgqaptfxmcvuptfuwike)
3. Click **SQL Editor** in the left sidebar
4. Copy everything from `SETUP.sql` and paste it in
5. Click **Run**

That creates all the tables needed.

---

## STEP 2 — Deploy to Railway

1. Create a new GitHub repo (call it `ciphermail-sequencer`)
2. Push all these files to it
3. Go to https://railway.app → New Project → Deploy from GitHub
4. Select your repo
5. Railway will auto-detect and build it

No environment variables needed — Supabase credentials are already in the code.

---

## STEP 3 — First Time Setup in the App

Once deployed, open your Railway URL and:

1. Go to **Inboxes** → Add all 5 of your sending email addresses
2. Go to **Settings** → Paste in your webhook URL (the one that actually sends emails)
3. Click **Test** to confirm the webhook works
4. You're ready to create campaigns

---

## STEP 4 — Create Your First Campaign

1. Click **New Campaign**
2. Give it a name
3. Write your 4 emails (subject + body for each)
4. Use `{{first_name}}`, `{{company}}` etc for personalization
5. Click **Preview** on each email to see how it looks with real contact data
6. Set your delay days between each email (default 2)
7. Click **Create Campaign**

Then:
1. Go to the campaign → click **Import** → upload your CSV
2. CSV needs at minimum: `email` column. Also supports: `first_name`, `last_name`, `company`, `city`, `phone`
3. Once imported, click **Launch Campaign**

---

## How the Scheduler Works

- Runs every 5 minutes automatically
- Checks which contacts are due to receive their next email
- Respects daily caps (500 total, 100 per inbox)
- Sends between your configured hours (default 9am–5pm)
- Skips weekends if enabled
- Fires your webhook with: `{ to, subject, body, inbox }`
- If a contact replied → stops their sequence automatically
- If a contact bounced → blacklists them permanently
- If unsubscribe detected in reply → blacklists them

---

## Webhook Payload

Every time an email is due, the sequencer calls your webhook with:

```json
{
  "to": "john@company.com",
  "subject": "Hey John, quick question",
  "body": "Hi John, I noticed Acme Corp...",
  "inbox": "sender@yourdomain.com",
  "campaign_id": "uuid",
  "contact_id": "uuid",
  "step": 1
}
```

Your webhook just needs to send the email. That's it.

---

## CSV Format

Minimum required:
```
email
john@company.com
jane@business.com
```

Full format:
```
email,first_name,last_name,company,city,phone
john@company.com,John,Smith,Acme Corp,Chicago,312-555-0123
```

---

## Variable Fallbacks

In your emails, use:
- `{{first_name}}` → falls back to "there" if empty → "Hey there"
- `{{company}}` → falls back to "your company"
- `{{city}}` → falls back to "your area"
- `{{first_name | "friend"}}` → custom fallback

---

## Fixing the Event Cap in Your Existing Tracker

In your existing tracker code, the stats query fetches without a limit but Supabase 
defaults to 1000 rows. To fix it, change this line:

```js
let statsQuery = supabase.from('email_events').select('type, inbox');
```

To this:

```js
let statsQuery = supabase.from('email_events').select('type, inbox', { count: 'exact' });
```

And add `.limit(null)` — or better, use an RPC function that does a COUNT query 
instead of fetching all rows.
