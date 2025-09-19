# Webhook Setup Guide

## 1. Server Setup

### Install webhook server
```bash
# Op je Hetzner server
cd /opt/polysynergy

# Kopieer de webhook files
cp webhook-server.py /opt/polysynergy/
cp webhook.service /etc/systemd/system/

# Edit service file met je webhook secret
sudo nano /etc/systemd/system/webhook.service
# Vervang: Environment=WEBHOOK_SECRET=your-webhook-secret-here

# Start service
sudo systemctl daemon-reload
sudo systemctl enable webhook
sudo systemctl start webhook

# Check status
sudo systemctl status webhook
sudo journalctl -f -u webhook
```

### Open firewall
```bash
# Als je ufw gebruikt
sudo ufw allow 9000

# Of iptables
sudo iptables -A INPUT -p tcp --dport 9000 -j ACCEPT
```

## 2. GitHub Setup

### A. Hoofdrepo (orchestrator)

Voeg deze secrets toe in GitHub → Settings → Secrets:
- `WEBHOOK_SECRET`: Hetzelfde als in webhook.service
- `WEBHOOK_URL`: `http://jouw-server-ip:9000`

### B. Subrepo's (api-local, portal, router, nodes, etc.)

In elke subrepo:

1. **Maak `.github/workflows/trigger-deployment.yml`:**
```yaml
name: Trigger Main Deployment

on:
  push:
    branches:
      - main

jobs:
  trigger-deployment:
    runs-on: ubuntu-latest

    steps:
    - name: Trigger Main Repo Webhook
      run: |
        curl -X POST \
          -H "Content-Type: application/json" \
          -H "X-GitHub-Event: push" \
          -H "X-Hub-Signature-256: sha256=$(echo -n '{"repository":{"name":"${{ github.repository }}"}}' | openssl dgst -sha256 -hmac '${{ secrets.WEBHOOK_SECRET }}' -binary | xxd -p)" \
          -d '{"repository":{"name":"${{ github.repository }}"}, "ref": "refs/heads/main"}' \
          ${{ secrets.WEBHOOK_URL }}/webhook
```

2. **Voeg secrets toe:**
   - `WEBHOOK_SECRET`: Hetzelfde als hoofdrepo
   - `WEBHOOK_URL`: `http://jouw-server-ip:9000`

## 3. Workflow

### Nu werkt het zo:

**Push naar hoofdrepo** → Webhook → Deploy script → Git pull alle submodules → Build → Deploy

**Push naar subrepo** → Webhook → Deploy script → Git pull alle submodules → Build → Deploy

### Commands op server:
```bash
# Manual deployment
./deploy-swarm.sh deploy

# Check webhook logs
sudo journalctl -f -u webhook

# Check deployment
docker stack services polysynergy
```

## 4. Testing

```bash
# Test webhook manually
curl -X POST http://jouw-server-ip:9000/webhook \
  -H "Content-Type: application/json" \
  -d '{"ref": "refs/heads/main", "repository": {"name": "test"}}'

# Health check
curl http://jouw-server-ip:9000/health
```

## 5. Security

- Webhook draait alleen op poort 9000
- Signature verification met WEBHOOK_SECRET
- Logs naar systemd journal
- Automatic restarts bij crashes