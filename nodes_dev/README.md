# PolySynergy Development Nodes

This package contains experimental and in-development nodes for the PolySynergy orchestrator system. These nodes are only available in local development mode and are not deployed to production.

## Purpose

- **Experimentation**: Test new node concepts without affecting stable nodes
- **Iteration**: Rapid development and testing of node functionality
- **Isolation**: Keep unstable or incomplete nodes separate from production code

## Structure

```
polysynergy_nodes_dev/
├── __init__.py                 # Package initialization and node registration
├── experimental/               # Experimental nodes and features
│   └── ...
└── in_progress/               # Nodes being actively developed
    └── ...
```

## Usage

These nodes are automatically discovered when running the API in local development mode with the `ENABLE_DEV_NODES` environment variable set to `true`.

## Promotion Workflow

When a node is ready for production:
1. Move the node directory from `polysynergy_nodes_dev` to `polysynergy_nodes`
2. Update the imports and registration
3. Add comprehensive tests
4. Update documentation

## Development

```bash
# Install dependencies
poetry install

# Run tests
poetry run pytest
```

## License

See LICENSE file in the root repository.