# Complete Drip Campaign Setup - 3 Minutes, Zero Manual Work

## What you get:
- ✅ Auto-import leads (CSV, API, or Webhook)
- ✅ Auto-send welcome email (Day 0)
- ✅ Auto-send Day 1, Day 3, Day 7 emails
- ✅ Auto-send weekly emails for 6 months
- ✅ Auto-send monthly reports
- ✅ Auto-track opens, clicks, replies
- ✅ Auto-notify when leads reply
- ✅ Auto-move hot leads to sales

---

## Step 1: Get Your API Token (1 minute)

1. Open http://localhost:3000
2. Sign up / Login
3. Go to **Settings → API Tokens**
4. Click **+ Generate Token**
5. Copy the token

---

## Step 2: Set Environment Variable (30 seconds)

```bash
export TWENTY_API_TOKEN=your_token_here
export TWENTY_API_URL=http://localhost:3000/graphql
```

---

## Step 3: Run Auto-Setup (30 seconds)

```bash
cd /Users/apple/TwentyCRM
bash auto-setup-drip.sh $TWENTY_API_TOKEN
```

Done! All workflows created automatically.

---

## Step 4: Import Your Leads (1 minute)

### Option A: Use the sample CSV (10 leads)
```bash
node auto-import-leads.js csv leads.csv
```

### Option B: Add your own leads (replace leads.csv)
```
email,firstName,lastName,company,position
your@email.com,First,Last,Company,Title
...
```

Then run:
```bash
node auto-import-leads.js csv leads.csv
```

### Option C: Webhook (auto-import leads continuously)
```bash
node auto-import-leads.js webhook
# Listens on http://localhost:3001/webhook/import-lead
# Send POST requests with lead data
```

---

## That's it. Drip campaign is running.

### What happens automatically:

**Lead imported:**
- Day 0: Welcome email sent ✅
- Day 1: Tip email sent ✅
- Day 3: Check-in email sent ✅
- Day 7: Offer email sent ✅
- Every Monday: Weekly email sent ✅
- Every 1st of month: Monthly report sent ✅

**If lead replies:**
- Email logged to their record ✅
- Status updated to "Warm" ✅
- Slack notification sent ✅
- Task created for follow-up ✅

**Dashboard shows:**
- Total emails sent
- Open rate
- Click rate
- Reply rate
- Hot leads (auto-detected)

---

## Monitor

Go to http://localhost:3000 → **People** → Click any lead

See entire email history, replies, engagement score, everything.

---

## No more manual work. Done.
