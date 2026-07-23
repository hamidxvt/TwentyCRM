# Twenty CRM for Tryverse

This is a self-hosted CRM setup using Twenty (open-source Salesforce/HubSpot alternative) for the Tryverse project.

## Features

- **Modern React UI** - Beautiful, responsive interface
- **Unlimited Custom Fields** - Fully customizable for your business needs
- **GraphQL API** - Powerful backend for integrations
- **AI Agent Integration** - Ready for AI-powered automation
- **Self-Hosted** - Complete data control and privacy

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Git
- Node.js 18+ (for local development, if needed)

### 1. Environment Setup

```bash
cd twenty
cp .env.example .env
```

Edit `.env` with your configuration (defaults work for local testing).

### 2. Start with Docker Compose

```bash
docker compose up -d
```

This will start:
- Twenty backend API
- PostgreSQL database
- Redis cache
- Frontend application

### 3. Access the Application

- **Frontend**: http://localhost:3000
- **API**: http://localhost:3001/graphql
- **Database**: postgres://localhost:5432/twenty

### 4. Default Credentials

Check the Twenty documentation for initial setup and credentials.

## Project Structure

```
twenty/
├── .env                 # Environment variables
├── docker-compose.yml   # Docker services
├── packages/
│   ├── twenty-server/   # Backend GraphQL API
│   └── twenty-front/    # React frontend
└── ...
```

## Adding Mautic for Email Marketing

Mautic integrates seamlessly with Twenty for advanced email campaigns with rich media support.

### Setup Mautic

1. Install Mautic in a separate container
2. Configure API credentials in Twenty
3. Create email campaigns with images and tracking

### Docker Compose Addition

```yaml
mautic:
  image: mautic/mautic:latest
  ports:
    - "8080:80"
  environment:
    MAUTIC_DB_HOST: postgres
    MAUTIC_DB_NAME: mautic
    MAUTIC_DB_USER: ${POSTGRES_USER}
    MAUTIC_DB_PASSWORD: ${POSTGRES_PASSWORD}
  depends_on:
    - postgres
```

## Common Tasks

### View Logs
```bash
docker compose logs -f twenty
docker compose logs -f postgres
```

### Stop Everything
```bash
docker compose down
```

### Stop with Data Preservation
```bash
docker compose stop
```

### Full Reset (destroys data)
```bash
docker compose down -v
```

## Development

For local development without Docker:

```bash
cd twenty
npm install
npm run dev
```

This starts the development server with hot reload.

## Customization for Tryverse

### Configure Custom Fields

1. Log in to Twenty
2. Go to Settings → Data Model
3. Add custom fields for your specific business needs:
   - Tryverse-specific metadata
   - Integration points
   - Custom workflows

### API Integration

Twenty's GraphQL API allows you to:
- Create custom integrations
- Build automation workflows
- Connect external services
- Build mobile apps

### Security Best Practices

- Use strong passwords for initial setup
- Configure JWT secrets in `.env`
- Use HTTPS in production
- Regular backups of the PostgreSQL database
- Set up proper firewall rules

## Troubleshooting

### Port Already in Use
Change ports in `docker-compose.yml`:
```yaml
ports:
  - "3001:3000"  # Change first number to available port
```

### Database Connection Issues
Ensure PostgreSQL is healthy:
```bash
docker compose exec postgres psql -U postgres -l
```

### Memory Issues
Increase Docker memory allocation in Docker Desktop settings.

## Next Steps

1. Complete initial setup and login
2. Create user accounts and roles
3. Set up custom fields for Tryverse
4. Configure integrations
5. Add Mautic for email campaigns
6. Set up API keys for external integrations

## Resources

- [Twenty Documentation](https://docs.twenty.com)
- [GitHub Repository](https://github.com/twentyhq/twenty)
- [Mautic Documentation](https://docs.mautic.org)
- [GraphQL API Docs](https://docs.twenty.com/developers/graphql-api)

## Support

For issues with Twenty:
- Check [GitHub Issues](https://github.com/twentyhq/twenty/issues)
- Review [Documentation](https://docs.twenty.com)

For Tryverse-specific CRM questions, check internal documentation.

---

*Last Updated: July 23, 2026*
