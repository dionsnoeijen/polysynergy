#!/bin/bash

# Docker Swarm Deployment Script for Polysynergy
# Usage: ./deploy-swarm.sh [init|update|rollback]

set -e

# Configuration
STACK_NAME="polysynergy"
DEPLOY_DIR="/opt/polysynergy-orchestrator"
ENVIRONMENT="production"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Update code from git
update_code() {
    echo_info "Updating code from git..."
    cd $DEPLOY_DIR

    # Stash any local changes
    git stash

    # Pull latest changes
    git pull origin main

    # Update submodules to latest versions (not pinned commits)
    echo_info "Updating submodules to latest versions..."
    git submodule update --init --recursive --remote

    # Show what was updated
    echo_info "Submodule status:"
    git submodule status

    echo_info "Code updated successfully"
}

# Initialize Swarm mode
init_swarm() {
    echo_info "Initializing Docker Swarm..."

    if docker info --format '{{.Swarm.LocalNodeState}}' | grep -q "active"; then
        echo_warn "Swarm is already initialized"
    else
        docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')
        echo_info "Swarm initialized successfully"
    fi

    echo_info "Creating secrets..."
    create_secrets

    echo_info "Building images..."
    build_local_images
}

# Create Docker secrets
create_secrets() {
    # Check if secrets exist, create if not
    secrets=(
        "postgres_password"
        "agno_postgres_password"
        "aws_access_key_id"
        "aws_secret_access_key"
    )

    for secret in "${secrets[@]}"; do
        if ! docker secret ls | grep -q "$secret"; then
            echo_warn "Creating secret: $secret"
            echo_warn "Please enter value for $secret:"
            read -s secret_value
            echo "$secret_value" | docker secret create "$secret" -
            echo
        else
            echo_info "Secret $secret already exists"
        fi
    done
}

# Build images locally using docker-compose
build_local_images() {
    echo_info "Building images locally..."
    cd $DEPLOY_DIR

    # Build all images using docker-compose (no cache to ensure fresh builds)
    docker compose -f docker-compose.build.yml build --no-cache

    echo_info "All images built successfully"
}

# Deploy or update the stack
deploy_stack() {
    echo_info "Deploying stack: $STACK_NAME"
    cd $DEPLOY_DIR

    docker stack deploy -c docker-stack.yml $STACK_NAME

    echo_info "Stack deployed successfully"
    echo_info "Forcing API restart to reload dependencies..."
    sleep 5
    docker service update --force polysynergy_api_local

    echo_info "Checking services..."
    sleep 5
    docker stack services $STACK_NAME
}

# Update specific service
update_service() {
    SERVICE=$1

    if [ -z "$SERVICE" ]; then
        echo_error "Service name required"
        exit 1
    fi

    echo_info "Updating service: ${STACK_NAME}_${SERVICE}"

    # First build the new image
    case $SERVICE in
        api|api_local)
            docker compose -f docker-compose.build.yml build api_local
            docker service update --force ${STACK_NAME}_api_local
            echo_info "API updated - dependencies refreshed automatically"
            ;;
        portal)
            docker compose -f docker-compose.build.yml build portal
            docker service update --force ${STACK_NAME}_portal
            ;;
        router)
            docker compose -f docker-compose.build.yml build router
            docker service update --force ${STACK_NAME}_router
            ;;
        caddy)
            docker compose -f docker-compose.build.yml build caddy
            docker service update --force ${STACK_NAME}_caddy
            ;;
        *)
            echo_error "Unknown service: $SERVICE"
            exit 1
            ;;
    esac

    echo_info "Service updated successfully"
}

# Rollback service to previous version
rollback_service() {
    SERVICE=$1

    if [ -z "$SERVICE" ]; then
        echo_error "Service name required"
        exit 1
    fi

    echo_warn "Rolling back service: ${STACK_NAME}_${SERVICE}"
    docker service rollback ${STACK_NAME}_${SERVICE}

    echo_info "Rollback completed"
}

# Check stack status
check_status() {
    echo_info "Stack services:"
    docker stack services $STACK_NAME

    echo_info "\nService logs (last 10 lines):"
    for service in $(docker stack services $STACK_NAME --format "{{.Name}}"); do
        echo_info "Logs for $service:"
        docker service logs $service --tail 10
    done
}

# Remove stack
remove_stack() {
    echo_warn "Removing stack: $STACK_NAME"
    docker stack rm $STACK_NAME

    echo_info "Waiting for stack to be removed..."
    sleep 10

    echo_info "Stack removed"
}

# Main script logic
case "$1" in
    init)
        init_swarm
        deploy_stack
        ;;
    deploy)
        update_code
        build_local_images
        deploy_stack
        ;;
    update)
        update_code
        if [ -n "$2" ]; then
            update_service $2
        else
            build_local_images
            deploy_stack
        fi
        ;;
    rollback)
        rollback_service $2
        ;;
    status)
        check_status
        ;;
    remove)
        remove_stack
        ;;
    *)
        echo "Usage: $0 {init|deploy|update [service]|rollback [service]|status|remove}"
        echo ""
        echo "Commands:"
        echo "  init     - Initialize swarm and deploy stack"
        echo "  deploy   - Git pull, build images and deploy entire stack"
        echo "  update   - Git pull and update specific service or entire stack"
        echo "  rollback - Rollback specific service"
        echo "  status   - Show stack status"
        echo "  remove   - Remove entire stack"
        echo ""
        echo "Examples:"
        echo "  $0 init                    # First time setup"
        echo "  $0 deploy                  # Full deployment with git pull"
        echo "  $0 update api              # Update only API service"
        echo "  $0 rollback api            # Rollback API to previous version"
        exit 1
        ;;
esac