---
title: "Editor Basics"
category: "guides"
order: 2
tags: ["editor", "basics", "interface", "beginner"]
description: "Learn the fundamental operations in the PolySynergy visual editor"
last_updated: "2025-01-07"
---

# Editor Basics

This guide covers the fundamental operations you need to know to work effectively with the PolySynergy visual editor.

## The Editor Interface

The PolySynergy editor consists of several key areas:

- **Item Manager**: The bar on the left, that contains the routes, schedules, blueprints, services, secrets and variables you have created
- **Dock**: The right sidebar, that contains the node variable inspector, and execution output
- **Bottom Bar**: Contains, logs, info and chat functionality
- **Editor**: The canvas where the nodes are added and connected
- **Top left menu** The menu where you can access basic editor interactions
- **Bottom right menu** The menu where you can access, publishing, documentation and advanced features

## Basic Navigation

### Panning the Canvas
- Hold space, then click and drag to pan the canvas   
- Use mouse wheel to zoom in and out

### Selecting Elements
- Click on a node to select it
- Hold Ctrl/Cmd and click to select multiple nodes
- Press b, and then click and drag to create a selection rectangle
- Click on empty space to deselect all

## Working with Nodes

### Adding Nodes to Canvas

<img src="http://localhost:8090/api/v1/documentation/assets/images/add-node.png" alt="Adding a Node" style="max-width: 600px; width: 100%;" />

1. Browse the Node Library. Open it by clicking the plus button in the top left menu
   - The library contains all available nodes, organized by categories
   - Use the search bar to quickly find specific nodes
2. Find the node you want to use
3. Select the node, and place it on the canvas by clicking
4. The node appears at the drop location

### Moving Nodes
- Click and drag any node to reposition it
- Nodes snap to a grid for clean alignment
- Move multiple selected nodes together

### Configuring Nodes

<img src="http://localhost:8090/api/v1/documentation/assets/images/variable-dock.png" alt="Configuring Nodes" style="max-width: 400px; width: 100%;" />

1. Click a node to open its configuration panel, it appears in the dock on the right side
2. Set input variables by modifying the items in the dock

## Making Connections

### Understanding Variables
- **Input variables**: Left side of nodes (receive data)
- **Output variables**: Right side of nodes (send data)
- Variables have types (String, Number, Boolean, etc.)

### Creating Connections
1. Click on an output variable (right side of a node)
2. Drag to an input variable on another node (left side)
3. Release to create the connection
4. Connection appears as a line between nodes

### Connection Rules
- You can only connect outputs to inputs
- Variable types must be compatible
- One output can connect to multiple inputs
- Each input can only have one connection

### Removing Connections
- Click the end of a line, then drag it away from the target variable, release the mouse

## Organizing Your Workflow

### Collapsing Nodes
- Right-click a node and select "Collapse" to hide its details

### Grouping Nodes
1. Select multiple nodes that belong together
2. Right-click and choose "Create Group"
3. Give the group a descriptive name
4. Collapse or expand groups to manage complexity

### Clean Layout Tips
- Arrange nodes from left to right (input → processing → output)
- Keep related nodes close together
- Avoid crossing connection lines when possible
- Use groups to organize complex workflows

## Testing Your Workflow

### Running Tests
1. Click the "Play" button in the toolbar
2. Watch nodes execute in sequence (they highlight during execution)
3. Check the execution log for any errors or warnings
4. Review output values to verify correct behavior

### Debugging Issues
- Red nodes indicate errors - check their configuration
- Use the execution log to trace problems

## Saving and Publishing

### Saving Your Work
- Work is automatically saved as you make changes
- Changes are stored in your project

### Stages
- **Mock**: Initial version, not yet published, can be published for testing (route only)
- **Create own stages**: You can add as many stages as you like, like acc, dev, staging, prod, etc.

### Publishing Workflows
- Test your workflow thoroughly first
- Click "Publish", in the publish form, to make it available for use
- Published workflows become available as API endpoints, or as schedules, that run automatically
- You can update published workflows by republishing, the mock stage is always automatically updated

## Keyboard Shortcuts

### General Navigation
- **Space + Click & Drag**: Pan the canvas
- **Mouse Wheel**: Zoom in and out
- **Escape**: Deselect all elements or cancel current operation
- **B + Click & Drag**: Box select (create selection rectangle)

### Node Operations
- **Delete**: Remove selected nodes or connections  
- **Backspace**: Remove selected nodes or connections
- **X**: Remove selected nodes or connections
- **Ctrl/Cmd + A**: Select all nodes
- **Ctrl/Cmd + Click**: Multi-select nodes

### Drawing Tools (when in Draw mode)
- **V**: Switch to select tool
- **P**: Switch to pen tool  
- **E**: Switch to eraser tool
- **N**: Switch to note tool

### Node Library
- **Arrow Keys**: Navigate through available nodes in the library
- **Enter**: Place selected node from library onto canvas
- **Escape**: Close node library

### Form Interactions
- **Enter**: Submit/save form when editing properties
- **Escape**: Cancel/close form or dialog

### Workflow Execution
- **Play button**: Start workflow execution (no keyboard shortcut currently)

## Next Steps

Once you're comfortable with these basics:
- Learn about [Working with Nodes](./working-with-nodes.md) for advanced node configuration
- Try the [Your First Workflow](../tutorials/first-workflow.md) tutorial
- Explore [Variables and Connections](./variables-and-connections.md) for complex data flow