#!/usr/bin/env python3
"""
Simple webhook server for automatic deployments
Listens for GitHub webhook events and triggers deployments
"""

import hashlib
import hmac
import json
import os
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
import logging

# Configuration
WEBHOOK_SECRET = os.getenv('WEBHOOK_SECRET', '')
DEPLOY_SCRIPT = '/opt/polysynergy/deploy-swarm.sh'
PORT = int(os.getenv('WEBHOOK_PORT', 9000))

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class WebhookHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        """Override to use our logger"""
        logger.info(format % args)

    def do_POST(self):
        """Handle POST requests (webhooks)"""
        if self.path != '/webhook':
            self.send_response(404)
            self.end_headers()
            return

        # Get content length
        content_length = int(self.headers.get('Content-Length', 0))
        if content_length == 0:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b'No content')
            return

        # Read the request body
        post_data = self.rfile.read(content_length)

        # Verify webhook signature if secret is set
        if WEBHOOK_SECRET:
            signature = self.headers.get('X-Hub-Signature-256')
            if not signature:
                logger.warning('No signature provided')
                self.send_response(401)
                self.end_headers()
                self.wfile.write(b'No signature')
                return

            # Verify signature
            expected_signature = 'sha256=' + hmac.new(
                WEBHOOK_SECRET.encode(),
                post_data,
                hashlib.sha256
            ).hexdigest()

            if not hmac.compare_digest(signature, expected_signature):
                logger.warning('Invalid signature')
                self.send_response(401)
                self.end_headers()
                self.wfile.write(b'Invalid signature')
                return

        # Parse JSON payload
        try:
            payload = json.loads(post_data.decode('utf-8'))
        except json.JSONDecodeError:
            logger.error('Invalid JSON payload')
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b'Invalid JSON')
            return

        # Handle the webhook
        self.handle_webhook(payload)

    def handle_webhook(self, payload):
        """Process the webhook payload"""
        event_type = self.headers.get('X-GitHub-Event')

        logger.info(f'Received {event_type} event')

        if event_type == 'push':
            self.handle_push(payload)
        elif event_type == 'ping':
            self.handle_ping(payload)
        else:
            logger.info(f'Ignored event type: {event_type}')
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'Event ignored')

    def handle_ping(self, payload):
        """Handle ping events (webhook test)"""
        logger.info('Ping received - webhook is working!')
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Pong! Webhook is working.')

    def handle_push(self, payload):
        """Handle push events"""
        ref = payload.get('ref', '')
        repo_name = payload.get('repository', {}).get('name', 'unknown')

        # Only deploy on pushes to main branch
        if ref != 'refs/heads/main':
            logger.info(f'Ignoring push to {ref} (not main branch)')
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'Ignored: not main branch')
            return

        # Check which files were changed to determine what to deploy
        commits = payload.get('commits', [])
        changed_files = set()

        for commit in commits:
            changed_files.update(commit.get('added', []))
            changed_files.update(commit.get('modified', []))
            changed_files.update(commit.get('removed', []))

        logger.info(f'Changed files: {changed_files}')

        # Determine what services to update
        services_to_update = self.get_services_to_update(changed_files)

        if not services_to_update:
            logger.info('No relevant changes detected')
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'No deployment needed')
            return

        # Trigger deployment
        self.trigger_deployment(services_to_update)

    def get_services_to_update(self, changed_files):
        """Determine which services need updating based on changed files"""
        services = set()

        for file_path in changed_files:
            if file_path.startswith('api-local/') or file_path.startswith('nodes') or file_path.startswith('node_runner'):
                services.add('api')
            elif file_path.startswith('portal/'):
                services.add('portal')
            elif file_path.startswith('router/'):
                services.add('router')
            elif file_path.startswith('caddy/'):
                services.add('caddy')
            elif file_path in ['docker-stack.yml', 'deploy-swarm.sh']:
                services.add('all')

        return list(services)

    def trigger_deployment(self, services):
        """Trigger the actual deployment"""
        logger.info(f'Triggering deployment for services: {services}')

        try:
            if 'all' in services:
                # Full deployment
                cmd = [DEPLOY_SCRIPT, 'deploy']
                logger.info('Running full deployment')
            else:
                # Update specific services
                for service in services:
                    cmd = [DEPLOY_SCRIPT, 'update', service]
                    logger.info(f'Updating service: {service}')

                    result = subprocess.run(
                        cmd,
                        cwd='/opt/polysynergy',
                        capture_output=True,
                        text=True,
                        timeout=600  # 10 minutes timeout
                    )

                    if result.returncode != 0:
                        logger.error(f'Deployment failed for {service}: {result.stderr}')
                        self.send_response(500)
                        self.end_headers()
                        self.wfile.write(f'Deployment failed for {service}'.encode())
                        return

            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'Deployment triggered successfully')
            logger.info('Deployment completed successfully')

        except subprocess.TimeoutExpired:
            logger.error('Deployment timed out')
            self.send_response(500)
            self.end_headers()
            self.wfile.write(b'Deployment timed out')
        except Exception as e:
            logger.error(f'Deployment error: {e}')
            self.send_response(500)
            self.end_headers()
            self.wfile.write(f'Deployment error: {e}'.encode())

    def do_GET(self):
        """Handle GET requests (health check)"""
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({
                'status': 'healthy',
                'webhook_secret_configured': bool(WEBHOOK_SECRET)
            }).encode())
        else:
            self.send_response(404)
            self.end_headers()

def main():
    """Main function"""
    if not WEBHOOK_SECRET:
        logger.warning('WEBHOOK_SECRET not set - webhooks will not be verified!')

    server = HTTPServer(('0.0.0.0', PORT), WebhookHandler)
    logger.info(f'Webhook server starting on port {PORT}')

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info('Shutting down webhook server')
        server.shutdown()

if __name__ == '__main__':
    main()