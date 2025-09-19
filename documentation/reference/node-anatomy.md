---
title: "Node Anatomy"
category: "reference"
order: 2
tags: ["editor", "basics", "interface", "beginner"]
description: "Learn the fundamental operations in the PolySynergy visual editor"
last_updated: "2025-01-07"
---


# Node Anatomy

This document explains the structure and components of a node in the PolySynergy Orchestrator system.

## Overview

A node is the fundamental building block of workflows in PolySynergy.
Each node represents a discrete unit of functionality that can process inputs, perform operations, and produce outputs. 
Nodes are connected together to form complex automation workflows.

## Simple Node Example

<img src="http://localhost:8090/api/v1/documentation/assets/images/anatomy-simple-node.png" alt="Adding a Node" style="max-width: 600px; width: 100%;" />

### To the left

The node, which has a name, icon and category in the header. The chevron can be used to collapse the node into it's smallest state.
Below the header, is the handle of the node, the handle is used to reference the node in other parts of the flow. More details on that later.

### To the right

This is the dock, that shows all configurable values of the node. The dock is divided into several sections.
At the very top you have the handle, this always gets a random value, that can be overruled if desired. Below that, you have a button that leads you to the documentation of this node.
And then you have the values that are configured to be exposed through the dock, allowing for specific node configurations.

### Input connector

<img src="http://localhost:8090/api/v1/documentation/assets/images/input-connector.png" alt="Adding a Node" style="max-width: 334px; width: 100%;" />

Node variables can have input connectors (and / or output connectors). They accept data from other nodes.

<img src="http://localhost:8090/api/v1/documentation/assets/images/hover-input-connector.png" alt="Adding a Node" style="max-width: 334px; width: 100%;" />

Hovering over the input connector will show you the types of data it can accept.

### Output connector

An output connector has similar functionality, but is used to send data to other nodes.

### Green output connector

<img src="http://localhost:8090/api/v1/documentation/assets/images/green-output.png" alt="Adding a Node" style="max-width: 334px; width: 100%;" />

The green output connector, usually provides the result of a node. It can also be connected to a green input connector (see below for more details).
This output is used when the node is executed successfully.

### Red output connector

<img src="http://localhost:8090/api/v1/documentation/assets/images/red-output.png" alt="Adding a Node" style="max-width: 334px; width: 100%;" />

The red output connector, is used to indicate that the node has failed during execution. You can use the output to take alternative actions in your workflow, such as sending an alert or logging the error.
It can be connected the green input connector of another node.

### Green input connector

<img src="http://localhost:8090/api/v1/documentation/assets/images/green-input.png" alt="Adding a Node" style="max-width: 334px; width: 100%;" />

This input connector accepts green or red output connectors.

### Resize node

<img src="http://localhost:8090/api/v1/documentation/assets/images/resize-node.png" alt="Resize Node" style="max-width: 334px; width: 100%;" />

The bottom right corner of the node has a resize handle, which allows you to resize the node to fit more inputs, outputs or configuration options.

### Dynamic connectors

In case of a dictionary variable, you can create dynamic connectors. This allows you to add or remove inputs and outputs dynamically, based on the data structure of the dictionary.

In the string node, for example, you could use it for the following usecase.

Say you want to output: Hello Connie! But the name should be dynamic, like Hello {{name}}!

In that case you would create a new row in the dictionary, with the key `name` and the value `Connie`.

First find the dict variable in the dock, and click the plus button to add a new row.
<img src="http://localhost:8090/api/v1/documentation/assets/images/dynamic-connectors.png" alt="Dynamic Connectors" style="max-width: 334px; width: 100%;" />

Then create a new row with those values.

<img src="http://localhost:8090/api/v1/documentation/assets/images/dict-simple-example.png" alt="Dynamic Connectors" style="max-width: 600px; width: 100%;" />

Save the dictionary, and change the "value" of the node like this:

<img src="http://localhost:8090/api/v1/documentation/assets/images/configured-variables.png" alt="Dynamic Connectors" style="max-width: 334px; width: 100%;" />

The output of the node will be `Hello Connie!` when executed.

Now let's create another Variable String node, give it a value of "Superman".

But before we continue, we go back to the hello node dictionary configuration, and switch the "In" switch like this:

<img src="http://localhost:8090/api/v1/documentation/assets/images/dict-in-switch.png" alt="Dynamic Connectors" style="max-width: 400px; width: 100%;" />

You should be able to see that the name variable from the dict, has a name variable, with a connector on the "in" side.

Now I make a connection from the output of the Variable String node to the input of the name variable in the dictionary.

<img src="http://localhost:8090/api/v1/documentation/assets/images/connection-a.png" alt="Dynamic Connectors" style="max-width: 400px; width: 100%;" />

The output of the variable string node to the right, as you can probably guess, will be `Hello Superman!`.

## Conclusion

Understanding node anatomy is crucial for developing effective nodes and workflows in PolySynergy. Each component serves a specific purpose in creating modular, reusable, and maintainable automation solutions.

For more information, see:
- [Node Development Guide](node-development.md)
- [Working with Nodes](../guides/working-with-nodes.md)
- [Creating Workflows](../guides/creating-workflows.md)