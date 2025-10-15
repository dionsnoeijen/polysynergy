<div align="center">
  <img src="https://www.polysynergy.com/ps-color-logo-with-text.svg" alt="PolySynergy Logo" width="400"/>

  <h3>Open-source visual AI workflow builder for developers who need transparency and control</h3>

  <p>
    <a href="https://www.polysynergy.com">Website</a> •
    <a href="https://discord.gg/H8eQACAhkX">Discord</a> •
    <a href="https://www.polysynergy.com/ams">Documentation</a>
  </p>

  <img src="images/image-b.png" alt="PolySynergy Visual Editor" style="max-width: 100%; border-radius: 8px;"/>
</div>

## What is PolySynergy?

PolySynergy is a **visual workflow builder** that lets you orchestrate AI agents and integrations through a drag-and-drop interface. Unlike black-box automation tools, every step is visible, debuggable, and under your control.

**See every step. Debug like actual code. No more black box guessing games.**

Perfect for developers building AI applications who need:
- **Multi-agent orchestration** with full visibility into decision-making
- **Flexible AI provider** support (OpenAI, Anthropic, Mistral, Ollama)
- **Real-time execution** monitoring and debugging
- **Complete control** over data flow and logic

> **Status:** Currently in **alpha** - actively developed and used in production by early adopters. Expect breaking changes.

## 🚧 Local Development Setup (In Progress)

**Important:** The local development setup is currently being refactored to remove AWS cloud dependencies. The platform runs in production but local `docker compose` setup is not yet fully functional.

**Current status:**
- ✅ Production deployment works (see [polysynergy.com](https://www.polysynergy.com))
- 🚧 Local development environment being decoupled from AWS
- 📅 Estimated availability: Q1 2026

**Want to try it now?** Join our [Discord](https://discord.gg/H8eQACAhkX) for early access or custom deployment support.

### Quick Start (Once Available)

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/dionsnoeijen/polysynergy.git
cd polysynergy/orchestrator

# Start all services
docker compose up -d

# Access the platform
# Portal:  http://localhost:4000
# API:     http://localhost:8090/docs
# Router:  http://localhost:8080
```

**Requirements:** Docker, Docker Compose

## Key Features

### 🎨 Visual Workflow Editor
Drag-and-drop interface with **40+ node types** including:
- AI agents (OpenAI, Anthropic, Mistral, Ollama)
- Data processing (JSON, lists, strings, files)
- Integrations (HTTP, email, AWS, databases)
- Control flow (conditionals, loops, routing)
- Custom nodes (extensible Python framework)

### 🔍 Transparency & Debugging
- Real-time execution monitoring via WebSocket
- Step-by-step workflow visualization
- Detailed logging and error tracking
- Full control over AI context and prompts

### 🚀 Production-Ready Architecture
- **Microservices** design with Docker
- **Serverless** deployment via AWS Lambda (optional)
- **Scalable** PostgreSQL + Redis stack
- **Secure** with OIDC authentication

### 🔧 Developer-First
- Python-based node development
- REST API for programmatic access
- WebSocket for real-time updates
- Comprehensive test coverage

## Technology Stack

| Layer | Technologies |
|-------|-------------|
| **Frontend** | Next.js 15, React 19, TypeScript, Tailwind CSS, Konva.js |
| **Backend** | FastAPI, SQLAlchemy 2.0, PostgreSQL, Redis |
| **Execution** | Python 3.12, Poetry, AWS Lambda (optional) |
| **AI/ML** | OpenAI, Anthropic, Mistral, Ollama, Qdrant (vector DB) |

## Project Structure

```
orchestrator/
├── portal/         # Next.js visual workflow editor
├── api-local/      # FastAPI orchestration backend
├── router/         # Dynamic request routing service
├── node_runner/    # Python workflow execution framework
├── nodes/          # Core node library (40+ types)
└── nodes_agno/     # Advanced AI agent nodes
```

Each component is a separate repository included as a git submodule. See individual repos for detailed documentation.

## Documentation

- **Architecture:** See [CLAUDE.md](./CLAUDE.md) for technical details
- **API Reference:** http://localhost:8090/docs (when running)
- **Node Development:** Check [nodes/CLAUDE.md](./nodes/CLAUDE.md)
- **Website:** https://www.polysynergy.com/ams

## Contributing

Contributions welcome! This is an early-stage project - expect rough edges and rapid iteration.

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

**Development standards:**
- Python with type hints
- TypeScript for frontend
- Comprehensive test coverage
- Docker for consistency

## License

Licensed under **Business Source License 1.1 (BSL 1.1)**

- ✅ **Free to use** for non-commercial purposes
- ✅ **Source available** - full transparency
- ❌ **Cannot offer as SaaS** to third parties
- 📅 **Becomes Apache 2.0** on January 1, 2028

For commercial licensing: [dion@polysynergy.com](mailto:dion@polysynergy.com)

## Community

- **Discord:** [Join our community](https://discord.gg/H8eQACAhkX)
- **Website:** [polysynergy.com](https://www.polysynergy.com)
- **Issues:** [GitHub Issues](https://github.com/dionsnoeijen/polysynergy/issues)

---

<div align="center">
  Built by developers, for developers who refuse black boxes.
</div>
