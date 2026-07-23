# TwentyCRM Project Structure

## Directory Overview

```
TwentyCRM/
│
├── README.md                    ⭐ Start here - Main documentation
├── QUICKREF.md                  ⚡ Quick reference for common tasks
├── CUSTOMIZATION.md             🎨 How to customize for Tryverse
├── DEPLOYMENT.md                🚀 Deployment guides (dev/staging/prod)
├── PROJECT_STRUCTURE.md         📁 This file
│
├── .env.example                 📋 Environment variables template
├── setup.sh                      🔧 Automated setup script
│
├── docker-compose.yml           🐳 Production Docker Compose (from Twenty)
├── docker-compose.dev.yml       🛠️ Development Docker Compose
├── docker-compose.full.yml      📦 Full stack with Mautic reference
│
├── twenty/                       📦 Twenty CRM Repository
│   ├── .git/
│   ├── packages/
│   │   ├── twenty-server/       🔌 GraphQL API backend
│   │   ├── twenty-front/        💻 React frontend
│   │   ├── twenty-database/     🗄️ Database migrations
│   │   └── ...
│   ├── docker-compose.yml       🐳 Original Twenty compose
│   ├── .env.example             📋 Twenty's env template
│   └── ...
│
├── scripts/                      📜 Helper scripts (optional)
│   ├── backup.sh
│   ├── restore.sh
│   └── ...
│
└── data/                         💾 Docker volumes (created by docker-compose)
    ├── postgres/                 🗄️ PostgreSQL data
    ├── redis/                    🔴 Redis data
    └── mautic/                   📧 Mautic data
```

## Key Files Explained

### Documentation Files

| File | Purpose | Audience |
|------|---------|----------|
| `README.md` | Overview and quick start | Everyone |
| `QUICKREF.md` | Common commands and tasks | Developers |
| `CUSTOMIZATION.md` | How to customize for Tryverse | Product/CRM team |
| `DEPLOYMENT.md` | Deployment strategies | DevOps/Infra |
| `PROJECT_STRUCTURE.md` | This file - project layout | Project leads |

### Configuration Files

| File | Purpose |
|------|---------|
| `.env.example` | Template for environment variables |
| `docker-compose.dev.yml` | Development environment with hot-reload |
| `docker-compose.full.yml` | Reference with Mautic included |
| `setup.sh` | Automated setup script |

### Source Code (in `twenty/`)

The `twenty/` directory contains the full Twenty CRM source code:

```
twenty/
├── packages/
│   ├── twenty-server/           # GraphQL API
│   │   ├── src/
│   │   │   ├── database/
│   │   │   ├── graphql/
│   │   │   ├── integrations/
│   │   │   └── ...
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── twenty-front/            # React Frontend
│   │   ├── src/
│   │   │   ├── components/
│   │   │   ├── pages/
│   │   │   ├── hooks/
│   │   │   └── ...
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── twenty-database/         # Database schemas & migrations
│   │   ├── migrations/
│   │   └── seeds/
│   │
│   └── ...
│
├── docker-compose.yml
├── .env.example
└── package.json                 # Monorepo root
```

## Usage Paths

### For Different Roles

**👨‍💼 CRM Administrator**
1. Start with `README.md`
2. Follow `QUICKREF.md` for common tasks
3. Refer to `CUSTOMIZATION.md` for setup

**👨‍💻 Developer**
1. Read `README.md` for overview
2. Use `QUICKREF.md` for Docker commands
3. Check `twenty/packages/twenty-server` for backend
4. Check `twenty/packages/twenty-front` for frontend

**🚀 DevOps/Infrastructure**
1. Read `DEPLOYMENT.md` thoroughly
2. Use `docker-compose.yml` files
3. Implement backup strategy from `DEPLOYMENT.md`

**📊 Product Manager**
1. Start with `CUSTOMIZATION.md`
2. Review custom fields for Tryverse
3. Understand workflows and integrations

## Getting Started Workflow

### Step 1: Initial Setup
```bash
# Clone repo (already done)
cd /Users/apple/TwentyCRM

# Copy environment
cp .env.example .env

# Review and edit .env if needed
# nano .env  # or your editor
```

### Step 2: Start Services
```bash
# Option A: Quick start (uses Twenty's docker-compose)
cd twenty
docker-compose up -d

# Option B: Development with hot-reload
cd ..
docker-compose -f docker-compose.dev.yml up -d

# Option C: Full stack with Mautic (reference - may need adjustments)
docker-compose -f docker-compose.full.yml up -d
```

### Step 3: Access & Configure
```bash
# Frontend: http://localhost:3000
# API: http://localhost:3001/graphql
# Mautic: http://localhost:8080
```

### Step 4: Customize for Tryverse
- Follow `CUSTOMIZATION.md`
- Add custom fields
- Set up workflows
- Configure integrations

## File Organization Best Practices

When adding new files:

```
TwentyCRM/
├── docs/                        📚 Additional documentation
│   ├── api-guide.md
│   ├── integration-guide.md
│   └── troubleshooting.md
│
├── scripts/                      📜 Automation scripts
│   ├── backup.sh
│   ├── deploy.sh
│   └── setup-production.sh
│
├── config/                       ⚙️ Configuration files
│   ├── nginx.conf
│   ├── postgres.conf
│   └── redis.conf
│
├── templates/                    🎨 Email/report templates
│   └── email/
│
└── twenty/                       📦 Twenty source (don't modify)
    └── ... (as is)
```

## Important Notes

### ⚠️ Do Not Modify
- `twenty/` directory (upstream from Twenty repository)
- Keep it pristine for easy updates from upstream

### ✏️ Safe to Modify
- `.env` - your environment configuration
- Configuration files in `config/`
- Scripts in `scripts/`
- Documentation

### 🔄 Keeping Updated
To update Twenty to the latest version:
```bash
cd twenty
git pull origin master
cd ..
docker-compose -f docker-compose.dev.yml up --build
```

## Integration Points

### With Tryverse
- **Custom Fields**: Defined in `CUSTOMIZATION.md`
- **API Integration**: Via GraphQL at `http://localhost:3001/graphql`
- **Webhooks**: Configured in Twenty settings
- **Email**: Through Mautic integration

### With External Services
- **Email**: Mautic (local) or SendGrid/AWS SES (production)
- **Analytics**: Sentry, DataDog (optional)
- **Storage**: S3, GCS for backups
- **Authentication**: OAuth via Twenty's built-in auth

## Quick Commands Reference

```bash
# View all containers
docker-compose ps

# View logs
docker-compose logs -f [service]

# Stop services
docker-compose stop

# Start services
docker-compose start

# Rebuild and restart
docker-compose up --build -d

# Remove everything (keep volumes)
docker-compose down

# Remove everything (delete all data!)
docker-compose down -v

# Backup database
docker-compose exec postgres pg_dump -U twenty twenty > backup.sql

# Access database
docker-compose exec postgres psql -U twenty twenty

# View logs of specific service
docker-compose logs -f twenty-server
```

## Support & Resources

- **Twenty Documentation**: https://docs.twenty.com
- **GitHub Repository**: https://github.com/twentyhq/twenty
- **Mautic Docs**: https://docs.mautic.org
- **GraphQL API**: https://docs.twenty.com/developers/graphql-api

---

**Last Updated**: July 23, 2026
**For Tryverse CRM setup only**
