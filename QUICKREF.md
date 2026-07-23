# Twenty CRM Quick Reference

## Getting Started

### 1. Initial Setup (First Time)

```bash
# Clone the repository (if not already done)
git clone https://github.com/twentyhq/twenty
cd twenty

# Copy environment template
cp .env.example .env

# Start services
docker-compose up -d
```

### 2. Access Services

- **Frontend**: http://localhost:3000
- **GraphQL API**: http://localhost:3001/graphql
- **Mautic (Email)**: http://localhost:8080
- **Database**: postgres://localhost:5432/twenty

### 3. Create Your First Account

1. Go to http://localhost:3000
2. Sign up with your email
3. Set up your workspace
4. Start creating contacts and deals

## Common Commands

### Docker Management

```bash
# Start all services
docker-compose up -d

# Stop services (data preserved)
docker-compose stop

# Stop and remove containers (data preserved)
docker-compose down

# Full reset (destroys all data!)
docker-compose down -v

# View logs
docker-compose logs -f [service-name]

# View all services
docker-compose ps

# Rebuild and start
docker-compose up --build -d
```

### Database Commands

```bash
# Connect to database
docker-compose exec postgres psql -U twenty -d twenty

# Backup database
docker-compose exec postgres pg_dump -U twenty twenty > backup.sql

# Restore from backup
docker-compose exec -T postgres psql -U twenty twenty < backup.sql

# View connections
docker-compose exec postgres psql -U twenty -c "SELECT * FROM pg_stat_activity;"
```

### Development

```bash
# View live logs
docker-compose logs -f twenty-server

# Restart a service
docker-compose restart twenty-server

# Run migrations
docker-compose exec twenty-server npm run migrations:run

# Seed test data
docker-compose exec twenty-server npm run seed:dev
```

## Customization for Tryverse

### Quick Customization Checklist

1. **Add Custom Fields**
   - Go to Settings → Data Model
   - Add Tryverse-specific fields
   - See CUSTOMIZATION.md for field list

2. **Configure Email**
   - Access Mautic at http://localhost:8080
   - Set up email templates
   - Configure SMTP in Twenty

3. **Create User Roles**
   - Admin, Sales Manager, Creator Manager, Brand Manager
   - Set permissions per role

4. **Add Webhooks**
   - Configure webhooks for deal creation
   - Set up Mautic integration

5. **Create Dashboards**
   - Dashboard for sales pipeline
   - Dashboard for creators
   - Dashboard for brands

### Key Files to Customize

```
/Users/apple/TwentyCRM/
├── .env                     # Environment variables
├── docker-compose.yml       # Service definitions
├── CUSTOMIZATION.md         # Detailed customization guide
└── README.md               # Overview
```

## Troubleshooting

### Port Already in Use

```bash
# Find what's using the port
lsof -i :3000
lsof -i :3001

# Kill the process
kill -9 <PID>

# Or change port in docker-compose.yml
# Change "3000:3000" to "3001:3000" for example
```

### Database Connection Issues

```bash
# Check database health
docker-compose exec postgres pg_isready

# Check connection settings in .env
cat .env | grep DATABASE_URL

# View database logs
docker-compose logs postgres
```

### Services Won't Start

```bash
# Check Docker daemon
docker ps

# Rebuild images
docker-compose build --no-cache

# View service logs
docker-compose logs [service-name]

# Check resource limits
docker stats
```

### Slow Performance

```bash
# Check resource usage
docker stats

# Clear Redis cache
docker-compose exec redis redis-cli FLUSHALL

# Restart services
docker-compose restart

# Check database slow queries
docker-compose exec postgres psql -U twenty -c "SELECT * FROM pg_stat_statements WHERE mean_time > 1000;"
```

## File Structure

```
/Users/apple/TwentyCRM/
├── README.md                    # Main documentation
├── CUSTOMIZATION.md             # How to customize for Tryverse
├── DEPLOYMENT.md                # Deployment guides
├── .env.example                 # Environment template
├── setup.sh                      # Setup automation script
├── docker-compose.yml           # Production compose file
├── docker-compose.dev.yml       # Development compose file
├── docker-compose.full.yml      # Full stack with Mautic
└── twenty/                      # Twenty CRM repository
    ├── packages/
    │   ├── twenty-server/       # GraphQL API
    │   ├── twenty-front/        # React frontend
    │   └── ...
    ├── docker-compose.yml
    └── ...
```

## Useful GraphQL Queries

### List all contacts

```graphql
query {
  people(first: 10) {
    edges {
      node {
        id
        firstName
        lastName
        email
      }
    }
  }
}
```

### Create a contact

```graphql
mutation {
  createPerson(
    input: {
      firstName: "John"
      lastName: "Doe"
      email: "john@example.com"
    }
  ) {
    id
    name
  }
}
```

### Get recent deals

```graphql
query {
  opportunities(
    first: 20
    filter: { status: { eq: "active" } }
  ) {
    edges {
      node {
        id
        name
        amount
        status
      }
    }
  }
}
```

## Performance Tips

1. **Database**: Add indexes on frequently queried fields
2. **Cache**: Use Redis for session management
3. **API**: Implement pagination in list queries
4. **Frontend**: Enable browser caching
5. **Images**: Use CDN for static assets

## Backup Strategy

### Daily Backup

```bash
# Automatic backup script
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
docker-compose exec -T postgres pg_dump -U twenty twenty | \
    gzip > backups/twenty_$TIMESTAMP.sql.gz
```

Add to crontab for daily backups:

```bash
0 2 * * * cd /Users/apple/TwentyCRM && bash scripts/backup.sh
```

## Integration Checklist

- [ ] Mautic email setup
- [ ] Webhook configuration
- [ ] API keys generated
- [ ] Custom fields created
- [ ] User roles configured
- [ ] Email templates created
- [ ] Integrations configured
- [ ] Backup system running
- [ ] Monitoring set up
- [ ] Documentation updated

## Next Steps

1. **Run setup**: `bash setup.sh`
2. **Access frontend**: http://localhost:3000
3. **Create account**: Sign up with email
4. **Customize**: Follow CUSTOMIZATION.md
5. **Deploy**: Follow DEPLOYMENT.md for production

## Support Resources

- **Twenty Docs**: https://docs.twenty.com
- **GitHub Issues**: https://github.com/twentyhq/twenty/issues
- **Mautic Docs**: https://docs.mautic.org
- **GraphQL API Docs**: https://docs.twenty.com/developers/graphql-api

## Quick Links

| Resource | URL |
|----------|-----|
| Frontend | http://localhost:3000 |
| API | http://localhost:3001 |
| GraphQL Playground | http://localhost:3001/graphql |
| Mautic | http://localhost:8080 |
| PgAdmin | http://localhost:5050 |
| Mailhog | http://localhost:8025 |
| Database | localhost:5432 |
| Redis | localhost:6379 |

---

Last Updated: July 23, 2026

For Tryverse-specific questions, refer to the internal CRM documentation.
