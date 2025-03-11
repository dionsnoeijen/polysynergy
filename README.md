
# Orchestrator

The **Orchestrator** is a Docker-based setup that integrates multiple services to efficiently manage the project. It includes a backend (API), a frontend (Portal), and a PostgreSQL database.

## **Contents**
- **API:** Django-based backend service.
- **Portal:** Next.js-based frontend service.
- **Database:** PostgreSQL for data storage.

---

## **Getting Started**

1. **Clone the repository with submodules:**
   Make sure to include the submodules when cloning the repository:
   ```bash
   git clone --recurse-submodules <repository-url>
   cd orchestrator
   ```

   If you forgot to include submodules during cloning, you can initialize them afterward:
   ```bash
   git submodule update --init --recursive
   ```

2. **Start the services:**
   Ensure Docker and Docker Compose are installed, then start the containers:
   ```bash
   docker compose up -d
   ```

3. **Access the services:**
   - **API:** [http://localhost:8000](http://localhost:8000)
   - **Portal:** [http://localhost:4000](http://localhost:4000)

4. **Access django admin**
   - **Url:** [http://localhost:8000/admin/](http://localhost:8000/admin/)
   - **Username:** localadmin
   - **Password:** localadmin@polysynergy.com

---

## **Features**
- **Automated setup:** The API automatically applies database migrations and creates a default superuser.
- **Hot-reloading:** The Portal supports hot-reloading during development.
- **Isolated services:** Backend and frontend operate independently and are connected via the database.

---

## **Environment Variables**
Here are the key environment variables used in the project:

### **API**
- `DJANGO_SETTINGS_MODULE`: Django settings module (default: `polysynergy_api.settings`).
- `DATABASE_URL`: Database connection string.

### **Portal**
- `NEXT_PUBLIC_POLYSYNERGY_API`: API URL (default: `http://localhost:8000/api/v1`).

---

## **Common Commands**

### Manage containers
- **Start containers in detached mode:**
  ```bash
  docker compose up -d
  ```

- **Stop containers:**
  ```bash
  docker compose down
  ```

- **Restart containers:**
  ```bash
  docker compose restart
  ```

### View logs
```bash
docker compose logs -f
```

# Infrastructure

Local connection to database is not possible without connecting to the bastion host.

### Connection to bastion host
```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@3.67.184.46
```

### Connect to database
```bash
ssh -i ~/.ssh/id_ed25519 -L 5432:terraform-20250307093612815300000001.cercqw3oenfg.eu-central-1.rds.amazonaws.com:5432 ubuntu@3.67.184.46
```

### Execute command in a container
```bash
aws ecs execute-command \
  --cluster polysynergy-cluster \
  --task $(aws ecs list-tasks --cluster polysynergy-cluster --query "taskArns[0]" --output text) \
  --container api \
  --command "/bin/bash" \
  --interactive
```

### Get ip address of bastion host
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=Bastion Host" \
  --query "Reservations[*].Instances[*].PublicIpAddress" \
  --output text
```

### Show logs
```bash
aws logs tail /ecs/api-task --follow
```