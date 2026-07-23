# Twenty CRM Customization for Tryverse

This document outlines how to customize Twenty CRM specifically for Tryverse's use case.

## Custom Fields Setup

### Core Tryverse Fields

After logging into Twenty, navigate to **Settings → Data Model** to add these custom fields:

#### Contact Fields
- `tryverse_member_id` (Text) - Unique Tryverse member identifier
- `creator_tier` (Dropdown) - Creator tier level
- `creator_niche` (Dropdown) - Creator's niche/category
- `content_performance` (Number) - Average engagement rate
- `verified_status` (Checkbox) - Whether account is verified on Tryverse
- `social_links` (URL) - Links to creator's social profiles
- `preferred_brand_partners` (Text) - List of brand partners of interest
- `collaboration_history` (Text Long) - Past collaboration notes

#### Company Fields
- `brand_category` (Dropdown) - Brand's industry/category
- `campaign_budget` (Currency) - Average campaign budget
- `preferred_creator_tiers` (Multi-select) - Preferred creator tiers to work with
- `brand_verification` (Checkbox) - Official brand account status
- `integration_status` (Dropdown) - Integration status with Tryverse
- `past_campaigns` (Number) - Number of campaigns ran on platform
- `api_key` (Text Encrypted) - Brand's API key for integrations

#### Deal Fields
- `deal_type` (Dropdown) - Sponsorship/Partnership/Affiliate/Other
- `content_deliverables` (Text Long) - What content will be delivered
- `posting_schedule` (Text) - Timeline for content posting
- `performance_metrics` (Text Long) - Key metrics to track
- `brand_guidelines` (Text Long) - Brand guidelines and requirements
- `creator_compensation` (Currency) - How much the creator is compensated
- `affiliate_commission` (Percentage) - Affiliate commission rate

## Workflow Automation

### Email Notification Workflow

```
Trigger: New Deal Created
→ Send email to creator with deal details
→ Send email to brand with creator info
→ Log event in activity feed
```

### Follow-up Workflow

```
Trigger: Deal Status = Pending for 7 days
→ Send reminder email
→ Create task for sales team
→ Update opportunity forecast
```

## GraphQL API Integration Examples

### Query Recent Deals

```graphql
query GetRecentDeals {
  deals(
    first: 10
    filter: { 
      status: "active" 
      createdAt: { gte: "2024-01-01" }
    }
  ) {
    edges {
      node {
        id
        name
        amount
        customFields {
          deal_type
          content_deliverables
          posting_schedule
        }
      }
    }
  }
}
```

### Create New Creator Contact

```graphql
mutation CreateCreatorContact {
  createContact(
    input: {
      firstName: "John"
      lastName: "Creator"
      email: "john@example.com"
      customFields: {
        tryverse_member_id: "tv_123456"
        creator_tier: "gold"
        creator_niche: "tech"
        verified_status: true
      }
    }
  ) {
    id
    name
    email
  }
}
```

## Integration Setup

### 1. Mautic Email Campaign Integration

Connect Mautic to send branded emails for:
- Creator outreach campaigns
- Brand partnership announcements
- Deal follow-ups
- Performance reports

**Steps:**
1. Get Mautic API credentials from http://localhost:8080
2. Go to Twenty Settings → Integrations
3. Add Mautic webhook
4. Create email templates in Mautic
5. Set up automation triggers

### 2. Webhook Setup

Enable webhooks for:
- New deals created
- Contact status changes
- Deal status updates
- Interaction logging

**Example Webhook Payload:**

```json
{
  "event": "deal.created",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "id": "deal_xyz",
    "dealType": "sponsorship",
    "creator": { "id": "contact_123", "name": "John Creator" },
    "brand": { "id": "company_456", "name": "Cool Brand" },
    "amount": 5000,
    "status": "negotiation"
  }
}
```

### 3. API Key Management

Store API keys securely:
1. Generate API key in Twenty account settings
2. Use for programmatic access to GraphQL API
3. Implement request signing for webhook verification

## Admin Configuration

### User Roles for Tryverse

Configure these roles in Twenty:

- **Admin** - Full access to all features
- **Sales Manager** - Create/edit deals, manage contacts
- **Creator Manager** - View creator contacts, manage creator relationships
- **Brand Manager** - Manage brand accounts and campaigns
- **Analytics** - View-only access to reports and dashboards

### Permission Groups

```
Creator Management:
  - Create/Edit/Delete contacts (creators)
  - View creator performance metrics
  - Access creator communication history

Brand Management:
  - Create/Edit/Delete company (brands)
  - Manage brand accounts
  - View brand campaign history

Deal Management:
  - Create/Edit/Delete deals
  - Update deal status
  - View deal metrics and ROI

Analytics:
  - View all dashboards
  - Export reports
  - No data modification
```

## Custom Dashboards

### Executive Dashboard

- Total active deals by month
- Creator participation rate
- Brand engagement metrics
- Revenue forecast
- Top performing creators
- Top partner brands

### Sales Dashboard

- Pipeline by stage
- Deals by creator tier
- Deals by brand category
- Won/Lost analysis
- Average deal size

### Creator Dashboard (View-only for creators)

- My active deals
- Earnings summary
- Performance metrics
- Upcoming deliverables
- Payment history

## Reporting

### Generate Reports

**Monthly Creator Report:**
```
- Total creators engaged
- Creator tier distribution
- Average earnings per creator
- Top performer recognition
- Churn rate
```

**Monthly Brand Report:**
```
- Total brands active
- Campaign performance
- ROI analysis
- Cost per acquisition
- Brand satisfaction scores
```

## Data Synchronization

### Sync with External Systems

Use webhooks to keep Tryverse data in sync:

1. **Sync to Analytics Platform**
   - Send deal metrics to your analytics service
   - Track creator performance over time

2. **Sync to Payment System**
   - Export payment information for creators
   - Track payouts and reconciliation

3. **Sync to Communication Platform**
   - Create Slack notifications for new deals
   - Send SMS reminders for deliverables

## Security Considerations

### Data Protection

- Enable two-factor authentication for all users
- Use encrypted connection strings for database
- Implement API rate limiting
- Regular backups to secure storage
- Audit logs for all data modifications

### Compliance

- GDPR compliance for EU users
- Data retention policies
- User data export capabilities
- Right to deletion implementation

## Backup & Recovery

### Automated Backups

Add to your deployment pipeline:

```bash
# Daily PostgreSQL backup
docker-compose exec postgres pg_dump -U twenty twenty > backup_$(date +%Y%m%d).sql

# Restore from backup
docker-compose exec postgres psql -U twenty twenty < backup_YYYYMMDD.sql
```

## Troubleshooting

### Common Issues

**Issue:** Custom fields not appearing in deals
- Solution: Refresh browser cache (Cmd+Shift+R)
- Clear browser local storage

**Issue:** Webhooks not firing
- Check webhook URL is accessible
- Verify webhook payload signature
- Check Mautic is running and healthy

**Issue:** GraphQL queries slow
- Add database indexes for frequently queried fields
- Implement caching layer with Redis
- Optimize N+1 queries

## Support & Resources

- Internal Tryverse CRM Documentation: [TBD]
- Twenty Docs: https://docs.twenty.com
- Mautic Docs: https://docs.mautic.org
- API Explorer: http://localhost:3001/graphql (when running)

---

For Tryverse-specific questions about CRM setup, contact the Platform team.
