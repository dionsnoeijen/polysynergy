# PolySynergy Local Development Setup

This guide helps you set up the entire PolySynergy system locally using `*.polysynergy.dev` domains with Caddy as the reverse proxy.

## Quick Start

1. **Run the setup script:**
   ```bash
   ./setup-local-dev.sh
   ```

2. **Start the services:**
   ```bash
   ./start-local-dev.sh
   ```

3. **Access the system:**
   - Portal: https://portal.polysynergy.dev
   - API: https://api.polysynergy.dev  
   - Project routes: https://{project-id}-{stage}.polysynergy.dev/your-route

## Architecture

The local setup includes:

- **Caddy**: Reverse proxy with automatic HTTPS for `*.polysynergy.dev`
- **Portal**: Next.js frontend at `portal.polysynergy.dev`
- **API Local**: FastAPI backend at `api.polysynergy.dev`
- **Router**: Dynamic routing service for project subdomains
- **PostgreSQL**: Database for the API
- **Redis**: Cache and WebSocket support

## DNS Configuration

The setup script offers two DNS configuration options:

### Option 1: dnsmasq (Recommended - True Wildcard Support)
Installs and configures dnsmasq to provide true wildcard DNS resolution for `*.polysynergy.dev`. This means **any** subdomain will automatically resolve to `127.0.0.1`:

- `portal.polysynergy.dev` ✅
- `api.polysynergy.dev` ✅  
- `your-project-id-mock.polysynergy.dev` ✅
- `any-subdomain.polysynergy.dev` ✅

### Option 2: /etc/hosts (Fallback)
Adds specific entries to `/etc/hosts`:

```
127.0.0.1 polysynergy.dev
127.0.0.1 portal.polysynergy.dev
127.0.0.1 api.polysynergy.dev
127.0.0.1 test-project-mock.polysynergy.dev
127.0.0.1 3ab020fb-d8f0-485e-ad03-9a0cb1f21d74-mock.polysynergy.dev
```

⚠️ **Note**: With /etc/hosts, you'll need to manually add each new project subdomain.

## SSL Certificates

Caddy automatically generates and manages SSL certificates for all `*.polysynergy.dev` domains. On first startup, it may take a moment to generate certificates.

## Configuration Files

### docker-compose.local.yml
Main Docker Compose configuration for local development.

### local-dev/Caddyfile
Caddy reverse proxy configuration:
- Routes `portal.polysynergy.dev` to Portal service
- Routes `api.polysynergy.dev` to API service  
- Routes all other `*.polysynergy.dev` to Router service

### Environment Files

**api-local/.env.local:**
- Database connections
- AWS credentials
- Cognito configuration
- WebSocket settings

**router/.env.local:**
- AWS credentials for DynamoDB
- Router-specific settings

## Helper Scripts

- `./start-local-dev.sh` - Start all services
- `./stop-local-dev.sh` - Stop all services
- `./logs-local-dev.sh` - View logs from all services
- `./status-local-dev.sh` - Check service status
- `./restart-local-dev.sh` - Restart all services

## Testing the Router Fix

The router has been fixed to handle variable segments properly. Test with:

```bash
# This should now work (was returning 404 before)
curl https://test-project-mock.polysynergy.dev/segment/12345

# This should also work  
curl https://3ab020fb-d8f0-485e-ad03-9a0cb1f21d74-mock.polysynergy.dev/segment/12345
```

## Troubleshooting

### SSL Certificate Issues
If you see SSL errors:
1. Wait a few minutes for Caddy to generate certificates
2. Check Caddy logs: `docker-compose -f docker-compose.local.yml logs caddy`
3. Restart if needed: `./restart-local-dev.sh`

### DNS Issues
If domains don't resolve:
1. Check that entries were added to `/etc/hosts`
2. Try flushing DNS cache:
   - macOS: `sudo dscacheutil -flushcache`
   - Linux: `sudo systemctl restart systemd-resolved`

### Service Issues
Check service status and logs:
```bash
./status-local-dev.sh
./logs-local-dev.sh
```

### Router 404 Issues
The router fix should resolve variable segment issues, but if you still get 404s:
1. Check that routes are properly stored in DynamoDB
2. Verify the project ID and stage format: `{project-id}-{stage}.polysynergy.dev`
3. Check router logs for pattern matching details

## AWS Configuration

### Option 1: Use Real AWS Services
Update the `.env.local` files with your real AWS credentials:
- DynamoDB for route storage
- Lambda for function execution
- Cognito for authentication

### Option 2: Use LocalStack (Recommended for Development)
Add LocalStack to your docker-compose.local.yml:

```yaml
localstack:
  image: localstack/localstack
  ports:
    - "4566:4566"
  environment:
    - SERVICES=dynamodb,lambda,cognito-idp
    - DEBUG=1
  networks:
    - internal
```

Then update environment files to point to LocalStack.

## Development Workflow

1. **Make code changes** in your local directories
2. **Services auto-reload** due to volume mounts
3. **Test changes** via the `.polysynergy.dev` domains
4. **View logs** with `./logs-local-dev.sh`
5. **Restart if needed** with `./restart-local-dev.sh`

## Production Differences

Local development differs from production in:
- Uses local domains instead of real domains
- Caddy handles SSL instead of AWS ALB
- Services run in containers instead of ECS
- May use LocalStack instead of real AWS services

## Next Steps

After setup:
1. Configure your AWS services or set up LocalStack
2. Create test routes in DynamoDB
3. Configure Cognito for authentication
4. Test the complete workflow from Portal to Lambda execution