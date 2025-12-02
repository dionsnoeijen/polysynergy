#!/bin/bash
# PolySynergy Local Development Setup
# One-command setup for fully local development environment

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "════════════════════════════════════════════════════════════"
echo "  PolySynergy Local Development Setup"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running!${NC}"
    echo "Please start Docker Desktop and try again."
    exit 1
fi
echo -e "${GREEN}✅ Docker is running${NC}"

# Check for .env files
echo ""
echo "Checking environment files..."
if [ ! -f "api-local/.env" ]; then
    echo -e "${YELLOW}⚠️  api-local/.env not found${NC}"
    echo "Copying from .env.example..."
    cp api-local/.env.example api-local/.env
    echo -e "${YELLOW}📝 Please edit api-local/.env with your configuration${NC}"
fi

if [ ! -f "router/.env" ]; then
    echo -e "${YELLOW}⚠️  router/.env not found${NC}"
    echo "Copying from .env-example..."
    cp router/.env-example router/.env
fi

echo -e "${GREEN}✅ Environment files ready${NC}"

# Start Docker containers
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Starting Docker containers..."
echo "════════════════════════════════════════════════════════════"
docker-compose up -d

# Wait for services to be healthy
echo ""
echo "Waiting for services to start..."
sleep 10

# Check service health
echo ""
echo "Checking service health..."

# Check PostgreSQL
if docker-compose exec -T db pg_isready -U polysynergy_user > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PostgreSQL (main DB) is ready${NC}"
else
    echo -e "${RED}❌ PostgreSQL (main DB) not responding${NC}"
fi

# Check Redis
if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Redis is ready${NC}"
else
    echo -e "${RED}❌ Redis not responding${NC}"
fi

# Check DynamoDB Local
if curl -s http://localhost:8001 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ DynamoDB Local is ready${NC}"
else
    echo -e "${YELLOW}⚠️  DynamoDB Local not responding yet...${NC}"
fi

# Check MinIO
if curl -s http://localhost:9000/minio/health/live > /dev/null 2>&1; then
    echo -e "${GREEN}✅ MinIO is ready${NC}"
else
    echo -e "${YELLOW}⚠️  MinIO not responding yet...${NC}"
fi

# Initialize DynamoDB tables
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Initializing DynamoDB Local..."
echo "════════════════════════════════════════════════════════════"
cd api-local
if command -v poetry &> /dev/null; then
    poetry run python scripts/init_dynamodb_local.py
else
    python3 scripts/init_dynamodb_local.py
fi
cd ..

# Initialize MinIO buckets
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Initializing MinIO buckets..."
echo "════════════════════════════════════════════════════════════"
cd api-local
if command -v poetry &> /dev/null; then
    poetry run python scripts/init_minio.py
else
    python3 scripts/init_minio.py
fi
cd ..

# Print success message and access info
echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "  ${GREEN}✅ LOCAL DEVELOPMENT ENVIRONMENT READY!${NC}"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📍 Service Access URLs:"
echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "   ${BLUE}API (Orchestrator):${NC}  http://localhost:8090"
echo -e "   ${BLUE}Portal (Frontend):${NC}   http://localhost:4000"
echo -e "   ${BLUE}Router Service:${NC}      http://localhost:8080"
echo ""
echo "📦 Data Storage:"
echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "   ${BLUE}MinIO Console:${NC}       http://localhost:9001"
echo "                          User: minioadmin"
echo "                          Pass: minioadmin"
echo ""
echo -e "   ${BLUE}DynamoDB Local:${NC}      http://localhost:8001"
echo "                          (No console, use AWS CLI)"
echo ""
echo "🔧 Development Commands:"
echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   View logs:           docker-compose logs -f"
echo "   Stop services:       docker-compose down"
echo "   Restart service:     docker-compose restart <service>"
echo ""
echo "📖 Documentation:"
echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Local setup guide:   api-local/LOCAL_DEVELOPMENT.md"
echo "   DynamoDB setup:      api-local/DYNAMODB_LOCAL_SETUP.md"
echo ""
echo "🚀 Next Steps:"
echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   1. Open Portal:      http://localhost:4000"
echo "   2. Create a project"
echo "   3. Create routes (accessible via router)"
echo "   4. Test routing:"
echo "      • Subdomain:      http://myproject-dev.localhost:8080/api/test"
echo "      • Path-based:     http://localhost:8080/myproject/dev/api/test"
echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "${GREEN}Happy coding! 🎉${NC}"
echo "════════════════════════════════════════════════════════════"
