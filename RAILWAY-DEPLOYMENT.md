# Deploy Twenty CRM to Railway — Complete Guide

## What you need

- Railway account (free tier works for testing): https://railway.app
- GitHub account with this repo
- 5 minutes

---

## Step 1: Connect GitHub to Railway (2 minutes)

1. Go to https://railway.app/dashboard
2. Click **+ New Project**
3. Select **Deploy from GitHub Repo**
4. Authorize Railway with GitHub
5. Find and select: `hamidxvt/TwentyCRM`
6. Click **Deploy**

Railway will auto-detect `docker-compose.yml` and start building.

---

## Step 2: Configure Environment Variables (2 minutes)

Once deployment starts, go to **Variables** tab and add:

### Critical Variables

```
PG_DATABASE_PASSWORD = (generate strong password)
ENCRYPTION_KEY = (run: openssl rand -base64 32)
APP_SECRET = (run: openssl rand -base64 32)
SERVER_URL = https://your-app-name.railway.app
IS_CONFIG_VARIABLES_IN_DB_ENABLED = false
```

### Email Configuration (for drip campaigns)

```
EMAIL_DRIVER = smtp
EMAIL_FROM_ADDRESS = noreply@tryverse.com
EMAIL_FROM_NAME = Tryverse CRM
EMAIL_SMTP_HOST = smtp.gmail.com
EMAIL_SMTP_PORT = 465
EMAIL_SMTP_USER = your-email@gmail.com
EMAIL_SMTP_PASSWORD = your-app-password
```

**Getting Gmail App Password:**
1. Go to https://myaccount.google.com/security
2. Enable 2FA
3. Go to **App passwords** → Select Mail → Select Device
4. Copy the 16-char password → paste in EMAIL_SMTP_PASSWORD

### Optional: S3 Storage (for production)

```
STORAGE_TYPE = s3
STORAGE_S3_REGION = us-east-1
STORAGE_S3_NAME = your-bucket-name
STORAGE_S3_ENDPOINT = https://s3.amazonaws.com
```

---

## Step 3: Deploy (automatic)

Railway will:
- ✅ Pull images (PostgreSQL, Redis, Twenty)
- ✅ Run migrations
- ✅ Start all services
- ✅ Create public URL

Wait 5-10 minutes for deployment.

---

## Step 4: Access Your CRM

Once deployed, Railway shows a public URL:

```
https://your-app-name.railway.app
```

1. Open that URL
2. Sign up
3. Start using the CRM

---

## Step 5: Configure Drip Campaigns

Get your API token:
1. Go to CRM settings
2. Generate API token
3. Use with auto-import-leads.js

```bash
export TWENTY_API_TOKEN=your_token
export TWENTY_API_URL=https://your-app-name.railway.app/graphql

node auto-import-leads.js csv leads.csv
```

---

## Monitoring

### View Logs

In Railway dashboard:
- Click **Deployments**
- Click **Logs** to see real-time output
- Check for errors or warnings

### Health Checks

CRM automatically:
- Checks database connection
- Verifies Redis is running
- Monitors server health
- Alerts if something fails

---

## Costs

| Service | Usage | Cost |
|---------|-------|------|
| PostgreSQL | 1GB | $7/mo |
| Redis | 256MB | $5/mo |
| Twenty Server | 1 instance | $15/mo |
| Network | Included | Free |
| **Total** | | **~$27/mo** |

Free tier gives $5 credit, so ~$22/month out of pocket for starter.

---

## Scaling

As you grow:

1. **Add more server instances** → Handle more users
2. **Upgrade database** → Store more data
3. **Enable S3 storage** → Unlimited file uploads
4. **Add CDN** → Faster delivery

All in Railway dashboard with 1 click.

---

## Backup & Recovery

Railway auto-backs up PostgreSQL. To manually backup:

```bash
# Download backup
railway connect postgres
pg_dump -U postgres twenty > backup.sql

# Restore
psql -U postgres twenty < backup.sql
```

---

## Troubleshooting

### CRM won't start
- Check logs in Railway dashboard
- Verify all env variables are set
- Ensure database password is strong (no special chars)

### Email not sending
- Verify EMAIL_SMTP credentials
- Check Gmail app password is correct
- Enable "Less secure apps" if not using app password

### Database connection fails
- Verify PG_DATABASE_PASSWORD is set
- Check database is healthy in Railway UI
- Restart database service

### Slow performance
- Scale up server memory/CPU in Railway
- Check database query performance
- Monitor Redis usage

---

## Custom Domain

To use your own domain (optional):

1. Railway dashboard → Settings → Custom Domain
2. Add your domain (e.g., crm.tryverse.com)
3. Update DNS records (Railway shows instructions)
4. Update SERVER_URL variable to use new domain

---

## Next Steps

1. ✅ Deploy to Railway
2. ✅ Set up email (Gmail)
3. ✅ Import first leads
4. ✅ Test drip campaign
5. ✅ Monitor for 1 week
6. ✅ Scale based on needs

---

## Support

Railway Docs: https://docs.railway.app
Twenty Docs: https://docs.twenty.com

Still stuck? Check Railway logs first — they're usually very helpful.

---

**That's it. You're deployed.**
