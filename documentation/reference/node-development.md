---
title: "Developing Custom Nodes"
category: "reference"
order: 2
tags: ["development", "nodes", "python", "advanced"]
description: "Learn how to create custom nodes for PolySynergy Orchestrator"
last_updated: "2025-01-07"
---

# Developing Custom Nodes

This guide explains how to create custom nodes for PolySynergy, allowing you to extend the platform with your own functionality.

## Prerequisites

- Python 3.12 or higher
- Understanding of Python programming
- Familiarity with PolySynergy concepts
- Development environment set up

## Node Development Overview

Nodes in PolySynergy are Python classes that:

1. Inherit from a base Node class
2. Use decorators to define metadata
3. Implement an `execute` method
4. Define input and output variables
5. Include documentation in adjacent README files

## Basic Node Structure

Here's the minimal structure for a custom node:

```python

```

## Node Decorator

The `@node()` decorator defines node metadata:

```python
@node(
    name="Display Name",           # Shown in the UI
    category="category_name",      # Groups nodes in the library
    icon="icon_name.svg",         # Icon file (optional)
    version="1.0.0",              # Node version (optional)
    description="Brief description"
)
```

### Categories
Common categories include:
- `http` - Web requests and responses
- `data` - Data processing and manipulation
- `logic` - Conditional logic and flow control
- `file` - File operations
- `email` - Email functionality
- `database` - Database operations
- `utility` - Helper and utility functions

## Variable Types

Variables define the inputs and outputs of your node:

### Supported Types
- `String` - Text data
- `Number` - Numeric values
- `Boolean` - True/false values
- `Dict` - JSON objects
- `List` - Arrays
- `Files` - File uploads/downloads
- `Code` - Code editor with syntax highlighting
- `Json` - JSON editor with validation
- `Template` - String templates with variable substitution
- `SecretString` - Encrypted text storage

### Variable Configuration

```python
Variable(
    name="variable_name",          # Internal identifier
    type="String",                 # Data type
    description="User description", # Help text
    required=True,                 # Is this variable required?
    default_value="default",       # Default value (optional)
    options=["opt1", "opt2"]       # Dropdown options (optional)
)
```

## Advanced Variable Features

### Optional Variables
```python
self.optional_var = Variable(
    name="optional_setting",
    type="Boolean",
    required=False,
    default_value=False
)
```

### Dropdown Options
```python
self.method_var = Variable(
    name="http_method",
    type="String",
    options=["GET", "POST", "PUT", "DELETE"],
    default_value="GET"
)
```

### File Variables
```python
self.file_input = Variable(
    name="input_file",
    type="Files",
    description="File to process"
)
```

## Execution Context

The `execute` method receives a `NodeExecutor` instance that provides:

### Getting Variable Values
```python
def execute(self, executor: NodeExecutor):
    # Get required variable
    text = executor.get_variable_value(self.input_text)
    
    # Get optional variable with default
    setting = executor.get_variable_value(self.optional_setting, default=False)
    
    # Check if variable has a value
    if executor.has_variable_value(self.optional_input):
        value = executor.get_variable_value(self.optional_input)
```

### Setting Output Values
```python
def execute(self, executor: NodeExecutor):
    result = "processed data"
    executor.set_variable_value(self.output_var, result)
```

### Error Handling
```python
def execute(self, executor: NodeExecutor):
    try:
        # Your processing logic
        result = process_data()
        executor.set_variable_value(self.output_var, result)
    except Exception as e:
        executor.log_error(f"Processing failed: {str(e)}")
        raise
```

### Logging
```python
def execute(self, executor: NodeExecutor):
    executor.log_info("Starting processing")
    executor.log_warning("This is a warning")
    executor.log_error("This is an error")
```

## Documentation

Every node should have a corresponding README file:

**File naming**: `{NodeClassName}_README.md`

**Example**: `MyCustomNode_README.md`

```markdown
# My Custom Node

## Description
Brief description of what this node does.

## Variables

### Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|
| input_text | String | Yes | Text to process |

### Outputs
| Name | Type | Description |
|------|------|-------------|
| output_text | String | Processed text |

## Examples

### Basic Usage
Input: "hello world"
Output: "HELLO WORLD"

## Error Handling
- Handles empty input gracefully
- Logs processing errors

## Use Cases
- Text normalization
- Data preprocessing
- String formatting
```

## Creating a Node Package

### Package Structure
```
my_custom_nodes/
├── pyproject.toml
├── my_custom_nodes/
│   ├── __init__.py
│   ├── text_processing/
│   │   ├── __init__.py
│   │   ├── uppercase_node.py
│   │   └── UppercaseNode_README.md
│   └── utilities/
│       ├── __init__.py
│       ├── logger_node.py
│       └── LoggerNode_README.md
```

### pyproject.toml
```toml
[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.poetry]
name = "my-custom-nodes"
version = "1.0.0"
description = "Custom nodes for PolySynergy Orchestrator"
authors = ["Your Name <email@example.com>"]

[tool.poetry.dependencies]
python = "^3.9"
polysynergy-node-runner = "*"

[tool.poetry.plugins."polysynergy_nodes"]
my_custom_nodes = "my_custom_nodes"
```

### Package Registration
Your package will be automatically discovered if:
1. It's installed in the same environment
2. It uses the `polysynergy_nodes` entry point
3. It follows the naming conventions

## Testing Your Nodes

### Unit Testing
```python
import unittest
from my_custom_nodes.text_processing.uppercase_node import UppercaseNode
from polysynergy_node_runner.execution_context.node_executor import NodeExecutor

class TestUppercaseNode(unittest.TestCase):
    def test_uppercase_conversion(self):
        node = UppercaseNode()
        executor = MockNodeExecutor()
        
        executor.set_variable_value(node.input_var, "hello")
        node.execute(executor)
        
        result = executor.get_variable_value(node.output_var)
        self.assertEqual(result, "HELLO")
```

### Integration Testing
Test your nodes in the actual PolySynergy environment:
1. Install your package in the development environment
2. Restart the API service to discover new nodes
3. Test through the Portal interface

## Best Practices

### Code Quality
- Follow PEP 8 style guidelines
- Add type hints where possible
- Include comprehensive error handling
- Write clear variable names and descriptions

### Performance
- Avoid blocking operations in the main thread
- Use async patterns for I/O operations
- Cache expensive computations when appropriate
- Clean up resources properly

### Security
- Validate all inputs
- Sanitize user-provided data
- Handle secrets securely
- Don't log sensitive information

### Documentation
- Write clear, comprehensive README files
- Include examples and use cases
- Document error conditions
- Keep documentation up to date

## Publishing Your Nodes

### Private Distribution
- Use private PyPI repositories
- Distribute as wheel files
- Version control your packages

### Public Distribution
- Publish to PyPI
- Include comprehensive documentation
- Add examples and tutorials
- Maintain backward compatibility

## Getting Help

- Review existing nodes in the `polysynergy_nodes` package for examples
- Check the API documentation for detailed method references
- Join the developer community for support and collaboration