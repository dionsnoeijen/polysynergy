#!/bin/bash

# PolySynergy Local Development Setup Script
# This script sets up the entire PolySynergy system to run locally with *.polysynergy.dev domains
# Uses Caddy as the reverse proxy with automatic HTTPS

set -e

echo "🚀 Setting up PolySynergy Local Development Environment"
echo "======================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    print_info "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is required. Install Docker Desktop from https://docker.com/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is required. Usually comes with Docker Desktop."
        exit 1
    fi
    
    # Check for Homebrew on macOS for dnsmasq installation
    if [[ "$OSTYPE" == "darwin"* ]] && ! command -v brew &> /dev/null; then
        print_warning "Homebrew not found. Install from https://brew.sh/ for automatic dnsmasq setup."
        print_info "You can still proceed with manual DNS setup."
    fi
    
    print_status "Dependencies checked"
}

# Setup local DNS with dnsmasq for wildcard support
setup_dns() {
    print_info "Setting up local DNS for *.polysynergy.dev..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        setup_dns_macos
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        setup_dns_linux
    else
        print_warning "Unsupported OS. Please manually configure DNS for *.polysynergy.dev -> 127.0.0.1"
        setup_dns_fallback
    fi
}

# Setup DNS on macOS using dnsmasq
setup_dns_macos() {
    print_info "Setting up DNS on macOS..."
    
    read -p "Do you want to set up dnsmasq for proper wildcard DNS support? (Y/n): " setup_dnsmasq
    setup_dnsmasq=${setup_dnsmasq:-Y}
    
    if [[ $setup_dnsmasq =~ ^[Yy]$ ]]; then
        if command -v brew &> /dev/null; then
            print_info "Installing and configuring dnsmasq..."
            
            # Install dnsmasq if not present
            if ! brew list dnsmasq &> /dev/null; then
                brew install dnsmasq
            fi
            
            # Configure dnsmasq for .dev domain
            echo "address=/.polysynergy.dev/127.0.0.1" | sudo tee /usr/local/etc/dnsmasq.conf > /dev/null
            
            # Start dnsmasq service
            sudo brew services start dnsmasq
            
            # Configure macOS to use dnsmasq for .dev domains
            sudo mkdir -p /etc/resolver
            echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/polysynergy.dev > /dev/null
            
            print_status "dnsmasq configured for *.polysynergy.dev"
            print_info "Testing DNS resolution..."
            if nslookup test.polysynergy.dev 127.0.0.1 > /dev/null 2>&1; then
                print_status "Wildcard DNS working! *.polysynergy.dev resolves to 127.0.0.1"
            else
                print_warning "DNS test failed. You may need to restart or check dnsmasq configuration."
            fi
        else
            print_warning "Homebrew not available. Falling back to /etc/hosts method."
            setup_dns_fallback
        fi
    else
        print_info "Skipping dnsmasq setup. Using /etc/hosts fallback."
        setup_dns_fallback
    fi
}

# Setup DNS on Linux using dnsmasq
setup_dns_linux() {
    print_info "Setting up DNS on Linux..."
    
    read -p "Do you want to set up dnsmasq for proper wildcard DNS support? (Y/n): " setup_dnsmasq
    setup_dnsmasq=${setup_dnsmasq:-Y}
    
    if [[ $setup_dnsmasq =~ ^[Yy]$ ]]; then
        # Check if dnsmasq is available
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y dnsmasq
        elif command -v yum &> /dev/null; then
            sudo yum install -y dnsmasq
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y dnsmasq
        else
            print_warning "Could not install dnsmasq automatically. Please install manually."
            setup_dns_fallback
            return
        fi
        
        # Configure dnsmasq
        echo "address=/.polysynergy.dev/127.0.0.1" | sudo tee -a /etc/dnsmasq.conf > /dev/null
        sudo systemctl enable dnsmasq
        sudo systemctl start dnsmasq
        
        # Configure system to use local dnsmasq
        echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf.head > /dev/null
        
        print_status "dnsmasq configured for *.polysynergy.dev"
    else
        setup_dns_fallback
    fi
}

# Fallback DNS setup using /etc/hosts
setup_dns_fallback() {
    print_info "Using /etc/hosts for DNS setup (limited wildcard support)..."
    
    HOSTS_FILE="/etc/hosts"
    
    # Backup current hosts file
    if [ ! -f "${HOSTS_FILE}.backup.polysynergy" ]; then
        sudo cp "$HOSTS_FILE" "${HOSTS_FILE}.backup.polysynergy"
        print_info "Backed up $HOSTS_FILE to ${HOSTS_FILE}.backup.polysynergy"
    fi
    
    # Add entries to hosts file
    HOSTS_ENTRIES="
# PolySynergy Local Development
127.0.0.1 polysynergy.dev
127.0.0.1 portal.polysynergy.dev
127.0.0.1 api.polysynergy.dev
# Add your project subdomains manually as needed:
127.0.0.1 test-project-mock.polysynergy.dev
127.0.0.1 test-project-dev.polysynergy.dev
127.0.0.1 3ab020fb-d8f0-485e-ad03-9a0cb1f21d74-mock.polysynergy.dev"
    
    # Check if entries already exist
    if ! grep -q "# PolySynergy Local Development" "$HOSTS_FILE"; then
        print_info "Adding DNS entries to $HOSTS_FILE..."
        echo "$HOSTS_ENTRIES" | sudo tee -a "$HOSTS_FILE" > /dev/null
        print_status "Basic DNS entries added to /etc/hosts"
        print_warning "Note: You'll need to manually add new project subdomains to /etc/hosts"
    else
        print_warning "DNS entries already exist in $HOSTS_FILE"
    fi
}

# Create directories if they don't exist
setup_directories() {
    print_info "Setting up directories..."
    mkdir -p local-dev
    print_status "Directories created"
}

# Update environment files with user's AWS credentials
configure_aws_credentials() {
    print_info "AWS Configuration..."
    
    read -p "Do you want to configure AWS credentials now? (y/N): " configure_aws
    
    if [[ $configure_aws =~ ^[Yy]$ ]]; then
        read -p "AWS Access Key ID: " aws_key_id
        read -s -p "AWS Secret Access Key: " aws_secret_key
        echo ""
        read -p "AWS Region (default: eu-central-1): " aws_region
        aws_region=${aws_region:-eu-central-1}
        
        # Update api-local .env.local
        sed -i.bak "s/AWS_ACCESS_KEY_ID=.*/AWS_ACCESS_KEY_ID=$aws_key_id/" ./api-local/.env.local
        sed -i.bak "s/AWS_SECRET_ACCESS_KEY=.*/AWS_SECRET_ACCESS_KEY=$aws_secret_key/" ./api-local/.env.local
        sed -i.bak "s/AWS_REGION=.*/AWS_REGION=$aws_region/" ./api-local/.env.local
        
        # Update router .env.local
        sed -i.bak "s/AWS_ACCESS_KEY_ID=.*/AWS_ACCESS_KEY_ID=$aws_key_id/" ./router/.env.local
        sed -i.bak "s/AWS_SECRET_ACCESS_KEY=.*/AWS_SECRET_ACCESS_KEY=$aws_secret_key/" ./router/.env.local
        sed -i.bak "s/AWS_REGION=.*/AWS_REGION=$aws_region/" ./router/.env.local
        
        # Clean up backup files
        rm -f ./api-local/.env.local.bak ./router/.env.local.bak
        
        print_status "AWS credentials configured"
    else
        print_warning "Skipping AWS configuration. You'll need to manually update .env.local files."
    fi
}

# Create helper scripts
create_helper_scripts() {
    print_info "Creating helper scripts..."
    
    # Start script
    cat > ./start-local-dev.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting PolySynergy Local Development Environment..."

# Build images if they don't exist
docker-compose -f docker-compose.local.yml build

# Start all services
docker-compose -f docker-compose.local.yml up -d

echo ""
echo "✅ Services started!"
echo ""
echo "🌐 Access URLs:"
echo "   Portal:  https://portal.polysynergy.dev"
echo "   API:     https://api.polysynergy.dev"
echo "   Example: https://test-project-mock.polysynergy.dev/your-route"
echo ""
echo "📊 Monitoring:"
echo "   Logs:    ./logs-local-dev.sh"
echo "   Status:  docker-compose -f docker-compose.local.yml ps"
echo ""
echo "🛑 To stop:  ./stop-local-dev.sh"
echo ""
echo "Note: First-time setup might take a few minutes to generate SSL certificates."
echo "      If you see certificate errors, wait a moment and refresh."
EOF
    chmod +x ./start-local-dev.sh
    
    # Stop script
    cat > ./stop-local-dev.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping PolySynergy Local Development Environment..."
docker-compose -f docker-compose.local.yml down
echo "✅ Services stopped!"
EOF
    chmod +x ./stop-local-dev.sh
    
    # Logs script
    cat > ./logs-local-dev.sh << 'EOF'
#!/bin/bash
docker-compose -f docker-compose.local.yml logs -f
EOF
    chmod +x ./logs-local-dev.sh
    
    # Status script
    cat > ./status-local-dev.sh << 'EOF'
#!/bin/bash
echo "📊 PolySynergy Local Development Status"
echo "======================================"
echo ""
docker-compose -f docker-compose.local.yml ps
echo ""
echo "🌐 URLs:"
echo "   Portal:  https://portal.polysynergy.dev"
echo "   API:     https://api.polysynergy.dev"
echo "   Router:  https://{project-id}-{stage}.polysynergy.dev"
EOF
    chmod +x ./status-local-dev.sh
    
    # Restart script
    cat > ./restart-local-dev.sh << 'EOF'
#!/bin/bash
echo "🔄 Restarting PolySynergy Local Development Environment..."
docker-compose -f docker-compose.local.yml restart
echo "✅ Services restarted!"
EOF
    chmod +x ./restart-local-dev.sh
    
    print_status "Helper scripts created"
}

# Main setup function
main() {
    print_info "Starting PolySynergy local development setup..."
    
    check_dependencies
    setup_directories
    setup_dns
    configure_aws_credentials
    create_helper_scripts
    
    echo ""
    echo "🎉 PolySynergy Local Development Setup Complete!"
    echo "================================================="
    echo ""
    print_info "Configuration created:"
    echo "  - ${GREEN}docker-compose.local.yml${NC} - Local services with Caddy"
    echo "  - ${GREEN}local-dev/Caddyfile${NC} - Caddy reverse proxy config"
    echo "  - ${GREEN}api-local/.env.local${NC} - API environment variables"
    echo "  - ${GREEN}router/.env.local${NC} - Router environment variables"
    echo ""
    print_info "Helper scripts:"
    echo "  - ${GREEN}./start-local-dev.sh${NC} - Start all services"
    echo "  - ${GREEN}./stop-local-dev.sh${NC} - Stop all services"
    echo "  - ${GREEN}./logs-local-dev.sh${NC} - View logs"
    echo "  - ${GREEN}./status-local-dev.sh${NC} - Check service status"
    echo "  - ${GREEN}./restart-local-dev.sh${NC} - Restart services"
    echo ""
    print_info "Next steps:"
    echo "1. Review and update the .env.local files with your specific configurations"
    echo "2. Start the services: ${GREEN}./start-local-dev.sh${NC}"
    echo "3. Wait for Caddy to generate SSL certificates (first time only)"
    echo "4. Open your browser to: ${GREEN}https://portal.polysynergy.dev${NC}"
    echo "5. Test routing with: ${GREEN}https://your-project-id-mock.polysynergy.dev/your-route${NC}"
    echo ""
    print_warning "Important notes:"
    echo "- Caddy will automatically generate SSL certificates for *.polysynergy.dev"
    echo "- If you set up dnsmasq, ALL *.polysynergy.dev subdomains will work automatically"
    echo "- If using /etc/hosts fallback, manually add new project subdomains as needed"
    echo "- You may need to set up DynamoDB tables locally or use real AWS"
    echo "- Configure Cognito settings in api-local/.env.local for authentication"
    echo "- The router fix for variable segments has been applied"
    echo ""
    print_info "For logs: ${GREEN}./logs-local-dev.sh${NC}"
    print_info "For status: ${GREEN}./status-local-dev.sh${NC}"
}

# Run main function
main