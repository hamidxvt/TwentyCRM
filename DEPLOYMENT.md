# Twenty CRM Deployment Guide

This guide covers deploying Twenty CRM for Tryverse in various environments.

## Prerequisites

- Docker & Docker Compose (v2.10+)
- Git
- At least 4GB RAM available for Docker
- 20GB free disk space for database and volumes

## Deployment Environments

### 1. Local Development

**Best for:** Development and testing

```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up

# Services:
# - Frontend: http://localhost:3000
# - API: http://localhost:3001
# - Mautic: http://localhost:8080
# - PgAdmin: http://localhost:5050
# - Mailhog: http://localhost:8025
```

### 2. Staging Environment

**Best for:** Pre-production testing with realistic data

Create `docker-compose.staging.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: twenty
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - /data/postgres:/var/lib/postgresql/data
    restart: always

  redis:
    image: redis:7-alpine
    volumes:
      - /data/redis:/data
    restart: always

  twenty-server:
    image: twentyhq/twenty:staging
    environment:
      DATABASE_URL: postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/twenty
      NODE_ENV: staging
    depends_on:
      - postgres
    restart: always

  twenty-front:
    image: twentyhq/twenty-front:staging
    ports:
      - "3000:3000"
    restart: always

  mautic:
    image: mautic/mautic:latest
    ports:
      - "8080:80"
    environment:
      MAUTIC_DB_HOST: postgres
      MAUTIC_DB_NAME: mautic
    restart: always

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/postgres

  redis_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/redis
```

### 3. Production Environment

**Best for:** Live deployment with high availability

#### Architecture Overview

```
                          Load Balancer (nginx)
                                 |
                    _____________|_____________
                   |             |             |
              Server-1      Server-2      Server-3
            (K8s Node)     (K8s Node)    (K8s Node)
                   |             |             |
              _____|_____________|_____________
                        |
                    Database Cluster
                   (PostgreSQL HA)
                        |
                   Backup Storage
                   (AWS S3/GCS)
```

#### Production Checklist

- [ ] Use managed database (AWS RDS, GCP Cloud SQL, or PostgreSQL cluster)
- [ ] Set up Redis cluster for caching
- [ ] Configure SSL/TLS certificates
- [ ] Enable backup and disaster recovery
- [ ] Set up monitoring and alerting
- [ ] Configure CDN for static assets
- [ ] Set up log aggregation
- [ ] Configure email service (SendGrid, AWS SES, etc.)
- [ ] Implement API rate limiting
- [ ] Set up DDoS protection

#### Kubernetes Deployment

For production on Kubernetes, create `k8s/` directory with manifests:

```
k8s/
├── namespace.yaml
├── configmap.yaml
├── secrets.yaml
├── postgres-statefulset.yaml
├── redis-statefulset.yaml
├── server-deployment.yaml
├── frontend-deployment.yaml
├── mautic-deployment.yaml
├── service.yaml
├── ingress.yaml
└── hpa.yaml (Horizontal Pod Autoscaler)
```

Example deployment:

```bash
# Create namespace
kubectl create namespace twenty

# Create secrets
kubectl create secret generic twenty-secrets \
  --from-literal=database-password=<password> \
  --from-literal=jwt-secret=<jwt-secret> \
  -n twenty

# Deploy
kubectl apply -f k8s/ -n twenty

# Check status
kubectl get pods -n twenty
kubectl logs -n twenty -f deployment/twenty-server
```

#### Environment Variables for Production

```bash
# Database
DATABASE_URL=postgresql://user:password@db.example.com:5432/twenty
REDIS_URL=redis://redis.example.com:6379

# Security
JWT_SECRET=<secure-random-32-char-string>
API_KEY=<generate-secure-key>

# URLs
API_URL=https://api.tryverse.com
FRONTEND_URL=https://crm.tryverse.com

# Email
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=<sendgrid-api-key>

# Monitoring
SENTRY_DSN=https://examplePublicKey@exampleDomain.ingest.sentry.io/exampleProjectId
DATADOG_API_KEY=<datadog-key>

# Feature Flags
ENABLE_SIGNUP=false
MAX_USERS=1000
```

## Installation Steps

### Step 1: Copy Environment

```bash
cp .env.example .env
# Edit .env with production values
```

### Step 2: Initialize Database

```bash
# Create database and run migrations
docker-compose exec twenty-server npm run migrations:run

# Seed initial data (optional)
docker-compose exec twenty-server npm run seed:prod
```

### Step 3: Configure SSL/TLS

Use certbot with nginx:

```bash
docker run --rm -v $(pwd)/certs:/etc/letsencrypt \
  certbot/certbot certonly --standalone \
  -d crm.tryverse.com \
  -d api.tryverse.com
```

### Step 4: Setup Reverse Proxy

Example nginx configuration:

```nginx
upstream twenty_frontend {
    server twenty-front:3000;
}

upstream twenty_api {
    server twenty-server:3001;
}

server {
    listen 443 ssl http2;
    server_name crm.tryverse.com;

    ssl_certificate /etc/letsencrypt/live/crm.tryverse.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/crm.tryverse.com/privkey.pem;

    location / {
        proxy_pass http://twenty_frontend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }

    location /graphql {
        proxy_pass http://twenty_api;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

### Step 5: Backup Strategy

Daily automated backups:

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# PostgreSQL backup
docker-compose exec -T postgres pg_dump -U twenty twenty \
    | gzip > $BACKUP_DIR/postgres_$DATE.sql.gz

# Upload to S3
aws s3 cp $BACKUP_DIR/postgres_$DATE.sql.gz \
    s3://your-backup-bucket/twenty/

# Keep only last 30 days
find $BACKUP_DIR -name "postgres_*.sql.gz" -mtime +30 -delete
```

Schedule with cron:

```bash
0 2 * * * /path/to/backup.sh
```

## Monitoring & Logging

### Health Checks

```bash
# API health
curl http://localhost:3001/health

# Frontend health
curl http://localhost:3000/health

# Database connectivity
docker-compose exec postgres pg_isready
```

### Log Aggregation

Use ELK Stack or similar:

```bash
# View logs
docker-compose logs -f

# Export logs
docker-compose logs --timestamps > twenty_logs_$(date +%Y%m%d).log
```

### Performance Monitoring

Monitor these metrics:

- API response time (target: <200ms)
- Database query performance
- Memory usage
- CPU usage
- Disk I/O
- Network bandwidth

## Scaling

### Horizontal Scaling

For high load, run multiple instances:

```yaml
services:
  twenty-server-1:
    image: twentyhq/twenty:latest
    environment:
      INSTANCE_ID: server-1

  twenty-server-2:
    image: twentyhq/twenty:latest
    environment:
      INSTANCE_ID: server-2

  nginx:
    image: nginx:latest
    ports:
      - "3001:3001"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
```

### Database Optimization

- Add indexes on frequently queried fields
- Implement connection pooling (PgBouncer)
- Archive old data to separate storage
- Use read replicas for reporting

## Disaster Recovery

### Backup & Restore

```bash
# Create backup
docker-compose exec postgres pg_dump -U twenty twenty > backup.sql

# Restore from backup
docker-compose exec -T postgres psql -U twenty twenty < backup.sql
```

### Recovery Time Objectives (RTO) & Recovery Point Objectives (RPO)

- RTO: < 1 hour
- RPO: < 15 minutes

Implement automated backup restoration testing:

```bash
# Weekly backup test
0 3 * * 0 /path/to/test_restore.sh
```

## Security Hardening

### Firewall Rules

- Restrict API access to known IPs
- Allow port 3000 (frontend) and 3001 (API) only to load balancer
- Restrict database access to application servers only
- Block public access to admin endpoints

### API Security

```bash
# Rate limiting
RATE_LIMIT=100  # requests per minute per IP

# CORS configuration
CORS_ORIGIN=https://tryverse.com

# API key rotation
# Rotate keys every 90 days
```

## Update & Maintenance

### Rolling Updates

```bash
# Update Twenty to latest version
docker-compose pull
docker-compose up -d

# Automatic rollback on failure
docker-compose up -d || docker-compose up -d --remove-orphans
```

### Maintenance Windows

- Schedule updates during low-traffic periods
- Use blue-green deployment for zero downtime
- Communicate maintenance windows to users 48 hours prior

## Troubleshooting Deployment

### Common Issues

**Issue: High memory usage**
- Increase Docker memory limit
- Optimize database queries
- Clear Redis cache

**Issue: Database connection pool exhausted**
- Increase max_connections in PostgreSQL
- Reduce query duration
- Implement connection pooling

**Issue: Slow API response**
- Check database slow query log
- Verify indexes are present
- Monitor CPU usage

## Support

For deployment issues:
1. Check logs: `docker-compose logs twenty-server`
2. Verify database connection: `psql $DATABASE_URL`
3. Review [Twenty Docs](https://docs.twenty.com)
4. Open issue on [GitHub](https://github.com/twentyhq/twenty/issues)

---

Last Updated: July 23, 2026
