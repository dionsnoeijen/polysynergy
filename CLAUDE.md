# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Docker Development
- `docker compose up -d` - Start all services in detached mode
- `docker compose down` - Stop all services
- `docker compose restart` - Restart all services
- `docker compose logs -f` - View logs for all services

### API Local (FastAPI)
- `cd api-local && poetry install` - Install dependencies
- `cd api-local && poetry run uvicorn main:app --reload --port 8090` - Start development server
- `cd api-local && poetry run pytest` - Run all tests with coverage
- `cd api-local && poetry run pytest tests/unit/` - Run unit tests only
- `cd api-local && poetry run alembic upgrade head` - Run database migrations
- `cd api-local && poetry run python cli.py run-local-mock --version-id <id> --node-id <id> --project-id <id> --tenant-id <id>` - Run local mock execution

### Portal (Next.js)
- `cd portal && pnpm dev` - Start development server
- `cd portal && next build` - Build for production
- `cd portal && next lint` - Run linter

### Router (FastAPI)
- `cd router && pip install -r requirements.txt` - Install dependencies
- `cd router && uvicorn main:app --host 0.0.0.0 --port 8080 --reload` - Start development server
- `cd router && python run_tests.py` or `cd router && pytest tests/` - Run all tests
- `cd router && python run_tests.py --coverage` - Run tests with coverage

### Node Packages
- `cd node_runner && poetry install && poetry run pytest` - Install and test node runner
- `cd nodes && poetry install` - Install nodes package
- `cd nodes_agno && poetry install` - Install agno nodes package

### Infrastructure (Terraform)
- `cd infrastructure && terraform init` - Initialize Terraform
- `cd infrastructure && terraform plan` - Plan infrastructure changes
- `cd infrastructure && terraform apply` - Apply infrastructure changes

### AWS Operations
- Connect to bastion: `ssh -i ~/.ssh/id_ed25519 ubuntu@3.67.184.46`
- Database tunnel: `ssh -i ~/.ssh/id_ed25519 -L 5432:terraform-20250307093612815300000001.cercqw3oenfg.eu-central-1.rds.amazonaws.com:5432 ubuntu@3.67.184.46`
- ECS exec: `aws ecs execute-command --cluster polysynergy-cluster --task $(aws ecs list-tasks --cluster polysynergy-cluster --query "taskArns[0]" --output text) --container api --command "/bin/bash" --interactive`
- View ECS logs: `aws logs tail /ecs/api-task --follow`

## Architecture Overview

PolySynergy Orchestrator is a **microservices-based automation platform** that enables users to create, manage, and execute node-based workflows. The system combines a visual editor frontend with a distributed backend architecture for scalable workflow execution.

### Core Services Architecture

#### 1. Portal (Next.js Frontend)
- **Technology**: Next.js 15.3.0 with React 19, TypeScript, Tailwind CSS
- **Purpose**: Visual node-based workflow editor with real-time collaboration
- **Key Features**:
  - Canvas-based node editor with Konva.js integration
  - OIDC authentication with AWS Cognito  
  - WebSocket connections for real-time updates
  - Zustand state management with domain-specific stores
- **Port**: 4000 (development)

#### 2. API Local (FastAPI Backend)
- **Technology**: FastAPI with SQLAlchemy 2.0, PostgreSQL, Redis
- **Purpose**: Main orchestration API for workflow management and execution
- **Key Features**:
  - Node execution and publishing to AWS Lambda
  - Project management (blueprints, routes, schedules, services)
  - WebSocket support for real-time execution logs
  - AWS services integration (Lambda, S3, Cognito, DynamoDB)
- **Port**: 8090 (development)

#### 3. Router (FastAPI Reverse Proxy)
- **Technology**: FastAPI with DynamoDB caching
- **Purpose**: Dynamic request routing to Lambda functions based on subdomain patterns
- **Key Features**:
  - Subdomain parsing: `{project_id}-{stage}.domain.com`
  - Route matching with regex patterns and variable extraction  
  - AWS Lambda function invocation with structured payloads
  - Caching layer for performance optimization
- **Port**: 8080 (development)

#### 4. Database Services
- **PostgreSQL**: Primary data storage for projects, nodes, and configurations
- **Redis**: Caching and real-time communication support
- **DynamoDB**: Route storage and execution state management (AWS)

### Node Execution Framework

#### Node Runner (`node_runner/`)
Core Python framework for executing node-based workflows:
- **Setup Context**: Node definitions, variables, and registration system
- **Execution Context**: Flow orchestration with traversal logic and connection management  
- **Services**: Code generation, AWS integration, and state management

#### Node Libraries
- **`nodes/`**: Main node library with agent orchestration, utility nodes, AWS integrations
- **`nodes_agno/`**: Additional specialized nodes
- **Agent System**: AI orchestration with OpenAI/Mistral, vector storage (Qdrant), memory management

### Infrastructure (AWS/Terraform)

#### Production Architecture
- **ECS Cluster**: Containerized API services with auto-scaling
- **Application Load Balancers**: Traffic distribution and SSL termination
- **RDS PostgreSQL**: Managed database with Multi-AZ deployment
- **Lambda Functions**: Dynamic node execution environment
- **Amplify**: Static hosting for the Portal frontend
- **Route 53**: DNS management with custom domain routing

#### Security & Access
- **VPC**: Private networking with public/private subnets
- **Security Groups**: Fine-grained access control
- **IAM Roles**: Service-specific permissions
- **AWS Secrets Manager**: Secure credential storage
- **Bastion Host**: Secure database access

### Development Patterns

#### Microservices Communication
- **HTTP APIs**: RESTful communication between services
- **WebSocket**: Real-time updates and execution logs
- **Message Queuing**: PubNub for distributed event handling
- **Service Discovery**: Docker Compose networking for local development

#### Data Flow Architecture
1. **Workflow Definition**: Users create workflows in the Portal editor
2. **Publishing**: API processes workflows and generates Lambda functions
3. **Routing**: Router service matches incoming requests to Lambda functions
4. **Execution**: Node Runner executes workflows with state management
5. **Monitoring**: Real-time logs and status updates via WebSocket

#### Testing Strategy
- **Unit Tests**: Component-level testing with pytest/Jest
- **Integration Tests**: Service interaction testing with mocked AWS services
- **End-to-End**: Full workflow testing across all services
- **Test Isolation**: Dockerized test environments with mock services

### Key Design Principles

#### Scalability
- **Stateless Services**: All services designed for horizontal scaling
- **Event-Driven**: Asynchronous processing with event sourcing patterns
- **Caching Layers**: Redis and DynamoDB for performance optimization
- **Lambda Cold Start Optimization**: Efficient code generation and deployment

#### Reliability  
- **Health Checks**: Comprehensive monitoring across all services
- **Error Handling**: Graceful degradation and retry mechanisms
- **State Recovery**: Persistent execution state with resurrection capabilities
- **Circuit Breakers**: Protection against cascading failures

#### Security
- **Authentication**: OIDC with AWS Cognito for user management
- **Authorization**: Role-based access control at service boundaries
- **Secrets Management**: AWS Secrets Manager integration
- **Network Security**: VPC isolation and security group restrictions

### Environment Configuration

#### Local Development
Services communicate via Docker Compose networking with the following key endpoints:
- Portal: `http://localhost:4000`
- API: `http://localhost:8090` 
- Router: `http://localhost:8080`
- Database: `localhost:5432`
- Redis: `localhost:6379`

#### Production Environment
All services deployed on AWS with proper DNS routing:
- Portal: `https://portal.polysynergy.com` (Amplify)
- API: `https://api.polysynergy.com` (ECS + ALB)
- Router: `https://*.polysynergy.com` (ECS + ALB)
- Database: RDS PostgreSQL (private subnet access only)

# Claude Code Working Pattern

## 🔄 Required Workflow for All Tasks

**CRITICAL**: Claude Code must follow this exact pattern for every significant task or request. This ensures proper verification and prevents incorrect assumptions.

### Phase 1: **Deep Research & Investigation**
- Thoroughly investigate the issue/request
- Read all relevant files and understand current architecture  
- Identify root causes, dependencies, and implications
- Research best practices and potential pitfalls
- Use Grep, Read, and other tools extensively to understand context
- **Output**: "Investigation complete, moving to planning phase"
- **NO changes made during this phase**

### Phase 2: **Comprehensive Plan Presentation**
- Present **exactly** what will be done and **why**
- Show specific files to modify with exact code changes
- Explain the reasoning behind each change
- Identify potential risks or side effects  
- Outline the step-by-step implementation approach
- **End with**: "Please check if my understanding and plan are correct before I proceed"

### Phase 3: **Verification & Approval**
- **Wait for explicit user approval** - never assume approval
- Allow user to review and correct any misunderstandings
- Only proceed after user confirms the plan is correct
- If plan needs changes, return to Phase 2

### Phase 4: **Careful Implementation**
- Follow the approved plan exactly
- Make changes systematically as outlined
- Track progress with TodoWrite when appropriate
- No surprises or deviations from the approved plan

## 🔄 Key Principles:
- **No assumptions** - always verify understanding with the user
- **Be explicit** - show exact code changes, not vague descriptions  
- **Ask for confirmation** - "Am I understanding this correctly?"
- **Comprehensive reasoning** - explain the why behind every change
- **Wait for approval** - never implement without explicit user confirmation

## 🚫 What NOT to Do:
- Jump directly to making changes
- Make assumptions about what the user wants
- Implement "obvious" solutions without verification
- Skip the planning phase for any significant change

This pattern ensures quality, prevents rework, and builds user confidence in the solutions provided.