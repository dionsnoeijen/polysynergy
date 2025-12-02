#!/bin/bash
# Quick health check for all PolySynergy services

echo "════════════════════════════════════════════════════════════"
echo "  PolySynergy Services Status Check"
echo "════════════════════════════════════════════════════════════"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_service() {
    local name=$1
    local url=$2
    local expected=$3

    if curl -s -f "$url" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ $name${NC} - $url"
        return 0
    else
        echo -e "  ${RED}❌ $name${NC} - $url (not responding)"
        return 1
    fi
}

check_docker_service() {
    local name=$1
    local container=$2

    if docker-compose ps | grep -q "$container.*Up"; then
        echo -e "  ${GREEN}✅ $name${NC} - Container running"
        return 0
    else
        echo -e "  ${RED}❌ $name${NC} - Container not running"
        return 1
    fi
}

echo "🐳 Docker Services:"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_docker_service "PostgreSQL (main)" "db"
check_docker_service "PostgreSQL (agno)" "agno_session_db"
check_docker_service "PostgreSQL (sections)" "sections_db"
check_docker_service "Redis" "redis"
check_docker_service "DynamoDB Local" "dynamodb-local"
check_docker_service "DynamoDB Admin" "dynamodb-admin"
check_docker_service "MinIO" "minio-local"
check_docker_service "API" "api_local"
check_docker_service "Router" "router-service"
check_docker_service "Portal" "portal"

echo ""
echo "🌐 HTTP Services:"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_service "API (Health)" "http://localhost:8090/health"
check_service "Portal" "http://localhost:4000"
check_service "Router" "http://localhost:8080"
check_service "MinIO (Health)" "http://localhost:9000/minio/health/live"
check_service "MinIO Console" "http://localhost:9001"
check_service "DynamoDB Local" "http://localhost:8001"
check_service "DynamoDB Admin UI" "http://localhost:8002"

echo ""
echo "📊 DynamoDB Local Tables:"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check DynamoDB tables
if command -v aws &> /dev/null; then
    TABLES=$(aws dynamodb list-tables \
        --endpoint-url http://localhost:8001 \
        --region eu-central-1 \
        --no-sign-request \
        --output text 2>/dev/null)

    if [ $? -eq 0 ]; then
        if echo "$TABLES" | grep -q "polysynergy_env_vars"; then
            echo -e "  ${GREEN}✅ polysynergy_env_vars${NC}"
        else
            echo -e "  ${RED}❌ polysynergy_env_vars${NC}"
        fi

        if echo "$TABLES" | grep -q "project_secrets"; then
            echo -e "  ${GREEN}✅ project_secrets${NC}"
        else
            echo -e "  ${RED}❌ project_secrets${NC}"
        fi

        if echo "$TABLES" | grep -q "polysynergy_routes"; then
            echo -e "  ${GREEN}✅ polysynergy_routes${NC}"
        else
            echo -e "  ${RED}❌ polysynergy_routes${NC}"
        fi
    else
        echo -e "  ${YELLOW}⚠️  Could not check tables (DynamoDB Local may not be responding)${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠️  AWS CLI not installed, skipping table check${NC}"
    echo "     Install: brew install awscli"
fi

echo ""
echo "📦 MinIO Buckets:"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check MinIO buckets (requires mc cli)
if command -v mc &> /dev/null; then
    # Configure mc alias if not exists
    mc alias set local http://localhost:9000 minioadmin minioadmin > /dev/null 2>&1

    BUCKETS=$(mc ls local 2>/dev/null)
    if [ $? -eq 0 ]; then
        if echo "$BUCKETS" | grep -q "polysynergy-public-dev"; then
            echo -e "  ${GREEN}✅ polysynergy-public-dev${NC}"
        else
            echo -e "  ${RED}❌ polysynergy-public-dev${NC}"
        fi

        if echo "$BUCKETS" | grep -q "polysynergy-private-dev"; then
            echo -e "  ${GREEN}✅ polysynergy-private-dev${NC}"
        else
            echo -e "  ${RED}❌ polysynergy-private-dev${NC}"
        fi
    else
        echo -e "  ${YELLOW}⚠️  Could not check buckets (MinIO may not be responding)${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠️  MinIO CLI (mc) not installed, skipping bucket check${NC}"
    echo "     Install: brew install minio/stable/mc"
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Quick Actions:"
echo "════════════════════════════════════════════════════════════"
echo "  View logs:           docker-compose logs -f"
echo "  Restart all:         docker-compose restart"
echo "  Stop all:            docker-compose down"
echo "  Init DynamoDB:       cd api-local && poetry run python scripts/init_dynamodb_local.py"
echo "  Init MinIO:          cd api-local && poetry run python scripts/init_minio.py"
echo ""
