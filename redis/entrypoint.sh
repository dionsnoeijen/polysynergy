#!/bin/sh
set -e

# Read Redis password from Docker secret
if [ -f /run/secrets/redis_password ]; then
    REDIS_PASSWORD=$(cat /run/secrets/redis_password)
    echo "✓ Redis password loaded from Docker secret"
else
    echo "✗ ERROR: Redis password secret not found at /run/secrets/redis_password"
    exit 1
fi

# Generate Redis configuration with secret password
cat > /tmp/redis-runtime.conf <<EOF
# Base configuration
bind 0.0.0.0
protected-mode yes
port 6379

# Authentication
requirepass ${REDIS_PASSWORD}

# Persistence
save 900 1
save 300 10
save 60 10000

# Logging
loglevel notice
EOF

echo "✓ Redis configuration generated"

# Start Redis with generated config
echo "Starting Redis server..."
exec redis-server /tmp/redis-runtime.conf
