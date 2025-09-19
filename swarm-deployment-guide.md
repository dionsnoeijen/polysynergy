# Docker Swarm Deployment Guide

## Initial Setup op Hetzner Server

### 1. Swarm initialiseren
```bash
# SSH naar je server
ssh root@jouw-server-ip

# Clone repository
git clone https://github.com/jouw-repo/orchestrator.git /opt/polysynergy
cd /opt/polysynergy

# Initialize Swarm
./deploy-swarm.sh init
```

### 2. Secrets configureren
Het script vraagt om de volgende secrets:
- `postgres_password`
- `agno_postgres_password`
- `redis_password`
- `aws_access_key_id` (voor Caddy)
- `aws_secret_access_key` (voor Caddy)
- `router_config`

### 3. Registry Setup (optioneel)
Voor private images kun je Docker Hub of een eigen registry gebruiken:
```bash
# Login naar registry
docker login registry.polysynergy.com

# Of gebruik Docker Hub
docker login
```

## Deployment Workflow

### Handmatig deployen
```bash
# Complete stack deployen
./deploy-swarm.sh deploy

# Specifieke service updaten
./deploy-swarm.sh update api v1.2.3

# Rollback bij problemen
./deploy-swarm.sh rollback api

# Status checken
./deploy-swarm.sh status
```

### Automatische CI/CD (GitHub Actions)

1. **GitHub Secrets toevoegen:**
   - `REGISTRY_URL`: Je Docker registry URL
   - `REGISTRY_USERNAME`: Registry username
   - `REGISTRY_PASSWORD`: Registry password
   - `SWARM_HOST`: IP van je Hetzner server
   - `SWARM_USER`: SSH user (meestal root)
   - `SWARM_SSH_KEY`: Private SSH key voor toegang

2. **Deployment triggers:**
   - Push naar `main` branch triggert automatische deployment
   - Services worden alleen geupdate als hun files veranderd zijn
   - Je kunt ook `[api]`, `[portal]`, of `[router]` in je commit message zetten om specifieke services te deployen

3. **Manual trigger:**
   - Ga naar Actions tab in GitHub
   - Kies "Deploy to Production"
   - Run workflow → kies welke service

## Monitoring & Rollback

### Services monitoren
```bash
# Alle services bekijken
docker service ls

# Specifieke service logs
docker service logs polysynergy_api_local --follow

# Service status
docker service ps polysynergy_api_local
```

### Rollback strategie
```bash
# Automatische rollback (naar vorige versie)
docker service rollback polysynergy_api_local

# Of via script
./deploy-swarm.sh rollback api
```

## Scaling

```bash
# API schalen naar 3 replicas
docker service scale polysynergy_api_local=3

# Portal schalen
docker service scale polysynergy_portal=2
```

## Updates zonder downtime

Docker Swarm doet automatisch rolling updates:
1. Start nieuwe container met nieuwe versie
2. Health check wacht tot nieuwe container gezond is
3. Traffic wordt naar nieuwe container gestuurd
4. Oude container wordt gestopt

Dit gebeurt één voor één voor alle replicas.

## Belangrijke punten

1. **Databases:** Blijven op één node (constraint `node.labels.db=true`)
2. **Volumes:** Named volumes worden lokaal opgeslagen. Voor multi-node setup overweeg NFS of GlusterFS
3. **Secrets:** Worden encrypted opgeslagen in Swarm
4. **Load balancing:** Swarm doet automatisch round-robin tussen replicas
5. **Health checks:** Zorgen voor automatic failover bij crashes

## Troubleshooting

```bash
# Service die niet start
docker service ps polysynergy_api_local --no-trunc

# Logs bekijken
docker service logs polysynergy_api_local --tail 100

# Forced update (pull nieuwe image)
docker service update --force polysynergy_api_local

# Complete restart
docker stack rm polysynergy
sleep 10
docker stack deploy -c docker-stack.yml polysynergy
```