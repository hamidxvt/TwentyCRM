#!/bin/bash

# Twenty CRM Setup Script for Tryverse
# This script automates the setup process

set -e

echo "🚀 Setting up Twenty CRM for Tryverse..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed. Please install Git first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites installed${NC}"

# Clone repository if not already cloned
if [ ! -d "twenty" ]; then
    echo -e "${YELLOW}📥 Cloning Twenty repository...${NC}"
    git clone https://github.com/twentyhq/twenty
    echo -e "${GREEN}✅ Repository cloned${NC}"
else
    echo -e "${YELLOW}⚠️  Twenty directory already exists, skipping clone${NC}"
fi

# Setup environment
echo -e "${YELLOW}⚙️  Setting up environment variables...${NC}"

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created${NC}"
    
    # Generate secure JWT secret
    JWT_SECRET=$(openssl rand -base64 32)
    sed -i '' "s/your-super-secret-jwt-key-change-in-production/${JWT_SECRET}/" .env
    
    POSTGRES_PASSWORD=$(openssl rand -base64 16)
    sed -i '' "s/POSTGRES_PASSWORD=change-me-in-production/POSTGRES_PASSWORD=${POSTGRES_PASSWORD}/" .env
    
    echo -e "${YELLOW}⚠️  Updated sensitive credentials in .env${NC}"
else
    echo -e "${YELLOW}⚠️  .env already exists, skipping generation${NC}"
fi

# Create necessary directories
echo -e "${YELLOW}📁 Creating project directories...${NC}"
mkdir -p data/{postgres,redis,mautic}
echo -e "${GREEN}✅ Directories created${NC}"

# Start services
echo -e "${YELLOW}🐳 Starting Docker services...${NC}"
docker-compose -f twenty/docker-compose.yml up -d
echo -e "${GREEN}✅ Services started${NC}"

# Wait for services to be healthy
echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
sleep 30

# Display summary
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Twenty CRM Setup Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Access your services:${NC}"
echo "  📱 Twenty Frontend:    http://localhost:3000"
echo "  🔌 Twenty GraphQL API: http://localhost:3001/graphql"
echo "  📧 Mautic (Email):     http://localhost:8080"
echo "  💾 PostgreSQL:         localhost:5432"
echo "  🔴 Redis:              localhost:6379"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Open http://localhost:3000 in your browser"
echo "  2. Create your first account"
echo "  3. Customize fields for Tryverse"
echo "  4. Configure integrations"
echo "  5. Set up email marketing with Mautic"
echo ""
echo -e "${YELLOW}Useful Commands:${NC}"
echo "  View logs:    docker-compose logs -f"
echo "  Stop:         docker-compose stop"
echo "  Stop & clean: docker-compose down"
echo "  Full reset:   docker-compose down -v"
echo ""
echo -e "${YELLOW}📚 Documentation:${NC}"
echo "  Twenty Docs:  https://docs.twenty.com"
echo "  GitHub:       https://github.com/twentyhq/twenty"
echo "  Mautic Docs:  https://docs.mautic.org"
echo ""
