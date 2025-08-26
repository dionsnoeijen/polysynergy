#!/bin/bash

# Helper script to add new subdomains to /etc/hosts for PolySynergy local development
# Only needed if you didn't set up dnsmasq

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 <subdomain>"
    echo ""
    echo "Examples:"
    echo "  $0 my-project-mock"
    echo "  $0 3ab020fb-d8f0-485e-ad03-9a0cb1f21d74-dev"
    echo ""
    echo "This will add: 127.0.0.1 <subdomain>.polysynergy.dev to /etc/hosts"
    exit 1
fi

SUBDOMAIN="$1"
FULL_DOMAIN="${SUBDOMAIN}.polysynergy.dev"
HOSTS_FILE="/etc/hosts"

# Check if entry already exists
if grep -q "$FULL_DOMAIN" "$HOSTS_FILE"; then
    print_warning "$FULL_DOMAIN already exists in $HOSTS_FILE"
    exit 0
fi

# Add the entry
echo "127.0.0.1 $FULL_DOMAIN" | sudo tee -a "$HOSTS_FILE" > /dev/null

if [ $? -eq 0 ]; then
    print_status "Added $FULL_DOMAIN to $HOSTS_FILE"
    echo ""
    echo "You can now access: https://$FULL_DOMAIN"
else
    print_error "Failed to add entry to $HOSTS_FILE"
    exit 1
fi