---
title: "Creating Workflows"
category: "guides"
order: 2
tags: ["workflows", "canvas", "editor"]
description: "Learn how to design and build workflows in the visual editor"
last_updated: "2025-01-07"
---

# Creating Workflows

This guide covers the workflow creation process in detail, from planning your automation to publishing it for use.

## Planning Your Workflow

Before you start building, it's helpful to plan your workflow:

1. **Define Your Goal**: What do you want to automate?
2. **Identify Inputs**: What data or triggers will start your workflow?
3. **Map the Process**: What steps need to happen?
4. **Define Outputs**: What should the workflow produce?

## Using the Visual Editor

### The Canvas
The canvas is your main workspace where you'll build your workflow:
- **Zoom**: Use mouse wheel or zoom controls
- **Pan**: Click and drag empty space to move around
- **Grid**: Nodes snap to a grid for clean alignment

### Adding Nodes
1. Browse the **Node Library** in the left sidebar
2. Nodes are organized by category (HTTP, Data, Logic, etc.)
3. **Drag and drop** nodes onto the canvas
4. **Double-click** a node to edit its configuration

### Node Categories
- **HTTP**: Make web requests, handle responses
- **Data**: JSON processing, string manipulation, math operations
- **Logic**: Conditional statements, loops, switches
- **Files**: Upload, download, process files
- **Email**: Send notifications and alerts
- **Database**: Store and retrieve data
- **Utilities**: Logging, debugging, helpers

## Connecting Nodes

### Variable Types
Understanding variable types is crucial for making connections:
- `String`: Text data
- `Number`: Numeric values
- `Boolean`: True/false values
- `Dict`: JSON objects
- `List`: Arrays of data
- `Files`: File uploads/downloads

### Making Connections
1. Click on an **output variable** (right side of a node)
2. Drag to an **input variable** (left side of another node)
3. Variables must be **compatible types** to connect
4. Connections are shown as colored lines between nodes

### Connection Rules
- You can only connect outputs to inputs
- Variable types must be compatible
- One output can connect to multiple inputs
- Each input can only have one connection

## Configuring Variables

### Input Variables
Variables without connections need values:
- **Text fields**: For strings and numbers
- **Dropdowns**: For predefined options
- **Checkboxes**: For boolean values
- **Code editors**: For JSON, templates, or custom code

### Variable Settings
Some variables have additional settings:
- **Required**: Must have a value or connection
- **Optional**: Can be left empty
- **Default values**: Used when no value is provided

## Testing Your Workflow

### Debug Mode
1. Click the **Test** button to run your workflow
2. Watch the **execution flow** as nodes are processed
3. Check **variable values** at each step
4. Review **logs** for any errors or warnings

### Common Issues
- **Missing connections**: Required inputs without values
- **Type mismatches**: Incompatible variable types
- **Node errors**: Check node-specific documentation
- **Infinite loops**: Avoid circular dependencies

## Workflow Organization

### Grouping Nodes
- Select multiple nodes and **group** them together
- **Collapse** groups to reduce visual complexity
- **Name** groups to describe their purpose

### Best Practices
- **Logical flow**: Arrange nodes left-to-right
- **Clean connections**: Avoid crossing lines when possible
- **Descriptive names**: Use clear variable and node names
- **Comments**: Add notes for complex logic

## Next Steps

Once your workflow is working:
- Learn about [Publishing and Deployment](./publishing-and-deployment.md)
- Explore [Variables and Connections](./variables-and-connections.md) for advanced techniques
- Try building more complex workflows with our [Tutorials](../tutorials/)