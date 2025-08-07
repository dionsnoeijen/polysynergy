---
title: "Getting Started with PolySynergy Orchestrator"
category: "guides"
order: 1
tags: ["beginner", "introduction", "setup"]
description: "Learn the basics of PolySynergy Orchestrator and create your first workflow"
last_updated: "2025-01-07"
---

# Getting Started with PolySynergy Orchestrator

Welcome to PolySynergy Orchestrator! This guide will help you understand the basics of creating automated workflows using our node-based visual editor.

## What is PolySynergy Orchestrator?

PolySynergy Orchestrator is a powerful automation platform that allows you to create complex workflows using a visual, node-based interface. You can connect different services, process data, make API calls, and automate repetitive tasks without writing code.

## Key Concepts

### Nodes
Nodes are the building blocks of your workflows. Each node performs a specific function, such as:
- Making HTTP requests
- Processing data (JSON, strings, numbers)
- Sending emails
- Working with files
- Conditional logic (if/then/else)
- Contain variable data like a string, or a number

### Connections
Connections link nodes together, allowing data to flow from one node to another. 
You connect nodes, by connecting "connectors", together.

## Creating Your First Workflow

This is a very simple description of how to create your first workflow in the PolySynergy Portal:

1. **Open the Portal**: Navigate to your PolySynergy Portal interface
2. **Create a New Project**: Click "New Project" and give it a name
3. **Create a Route, Schedule or Blueprint** Click the plus button in the menu on the left
4. **Connect Nodes**: Click and drag from output variables to input variables
5. **Configure Variables**: Set values for input variables that don't have connections
6. **Test Your Workflow**: Use the test functionality to see if it works as expected
7. **Publish**: Deploy your workflow to make it available via API

## Next Steps

- Read about [Editor Basics](./editor-basics.md) for understanding the way the editor works

- Learn about [Working with Nodes](./working-with-nodes.md) to understand different node types
- Explore [Variables and Connections](./variables-and-connections.md) for advanced data flow concepts

## Getting Help

If you encounter any issues:
- Check the [Troubleshooting](../reference/troubleshooting.md) guide
- Review node-specific documentation by clicking the info button on any node
- Consult the [API Reference](../reference/api-reference.md) for technical details