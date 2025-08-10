# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This is a Poetry-managed Python project for experimental and development nodes.

```bash
# Install dependencies
poetry install

# Run tests for a specific node
poetry run pytest polysynergy_nodes_dev/[node_name]/tests/

# Install in development mode
poetry install --with dev
```

## Architecture Overview

This is `polysynergy_nodes_dev` - a Python library containing experimental and in-development nodes for the PolySynergy orchestration system. These nodes are only loaded in local development mode and are excluded from production deployments.

### Core Structure

- **Node Registration**: All stable dev nodes are registered in `polysynergy_nodes_dev/__init__.py` via a `registered_nodes` list
- **Node Framework**: Nodes inherit from `polysynergy_node_runner.setup_context.node.Node` and use the `@node` decorator
- **Development Categories**:
  - `experimental/`: Proof-of-concept and experimental features
  - `in_progress/`: Nodes being actively developed for future release

### Development Guidelines

- **Isolation**: Dev nodes should not depend on production nodes
- **Documentation**: Even experimental nodes should have basic README files
- **Testing**: Write tests early, even for experimental features
- **Promotion Path**: Clear path to move nodes to `polysynergy_nodes` when ready

### Node Development Patterns

Same as production nodes:
- Use `NodeVariableSettings` for inputs/outputs
- Implement `execute()` method
- Follow error handling with `NodeError`
- Include icon files in `icons/` subdirectories

### Important Notes

- These nodes are **NOT** available in production
- They are loaded only when `ENABLE_DEV_NODES=true`
- Use for rapid prototyping and experimentation
- Move to `polysynergy_nodes` when stable and tested