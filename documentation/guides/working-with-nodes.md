---
title: "Working with Nodes"
category: "guides"
order: 3
tags: ["nodes", "variables", "configuration"]
description: "Understand different node types and how to configure them effectively"
last_updated: "2025-01-07"
---

# Working with Nodes

Nodes are the core components of your workflows. Each node performs a specific task and can be configured to process data, make API calls, perform calculations, and much more.

## Node Types Overview

### HTTP Nodes
Handle web requests and API interactions:
- **HTTP Request**: Make GET, POST, PUT, DELETE requests to APIs
- **HTTP Response**: Format responses for web endpoints

### Data Processing Nodes
Transform and manipulate data:
- **JSON Query**: Extract values from JSON objects
- **JSON Combine**: Merge multiple JSON objects
- **Variable String**: Create formatted text with templates
- **Math Operations**: Perform calculations (add, subtract, multiply, divide)
- **List Operations**: Work with arrays (filter, map, sort)

### Logic and Control Flow
Control workflow execution:
- **If Then Else**: Conditional branching
- **Switch Case**: Multiple condition handling
- **Comparison**: Compare values (equal, greater than, less than)
- **Boolean Operations**: AND, OR, NOT operations

### File Operations
Work with files and uploads:
- **File Upload**: Handle file uploads from users
- **File Type**: Detect and validate file types
- **Upload to Storage**: Save files to cloud storage

### Communication Nodes
Send notifications and messages:
- **Send Email**: Send email notifications
- **Log**: Output information for debugging

### Database Operations
Store and retrieve data:
- **Key-Value Store**: Simple data storage and retrieval
- **Database Query**: Execute SQL queries (advanced)

## Node Configuration

### Basic Setup
1. **Drag node** from library to canvas
2. **Double-click** to open configuration
3. **Set required variables** (marked with red indicators)
4. **Configure optional settings** as needed
5. **Save** configuration

### Variable Types Explained

#### String Variables
- **Purpose**: Text data, API endpoints, messages
- **Example**: `"Hello, World!"` or `"https://api.example.com"`
- **Special**: Can use templates with `{variable_name}` syntax

#### Number Variables
- **Purpose**: Numeric calculations, counters, thresholds
- **Example**: `42`, `3.14159`, `-100`
- **Operations**: Can be used in math nodes

#### Boolean Variables
- **Purpose**: True/false values, flags, conditions
- **Example**: `true` or `false`
- **Usage**: Control flow in conditional nodes

#### Dict (Object) Variables
- **Purpose**: Complex data structures, API responses
- **Example**: `{"name": "John", "age": 30}`
- **Access**: Use JSON Query nodes to extract values

#### List (Array) Variables
- **Purpose**: Collections of data
- **Example**: `[1, 2, 3]` or `["apple", "banana", "cherry"]`
- **Operations**: Use List nodes for filtering, mapping

#### Files Variables
- **Purpose**: File uploads, downloads, attachments
- **Format**: File metadata with content
- **Usage**: Process uploaded files, generate downloads

### Advanced Configuration

#### Template Strings
Use variables in text with curly braces:
```
Hello {user_name}, your order #{order_id} is ready!
```

#### JSON Path Queries
Extract data from complex objects:
- `user.name` - Get name from user object
- `items[0].price` - Get price from first item
- `data.results[*].id` - Get all IDs from results array

#### Conditional Logic
Set up branching workflows:
1. Use **Comparison** nodes to evaluate conditions
2. Connect to **If Then Else** nodes for branching
3. Route different data paths based on results

## Node Organization

### Grouping Nodes
- **Select multiple nodes** (Ctrl/Cmd + click)
- **Right-click** and choose "Group"
- **Name the group** descriptively
- **Collapse/expand** to manage complexity

### Naming Conventions
- **Descriptive names**: `"Fetch User Data"` instead of `"HTTP Request"`
- **Action-oriented**: Start with verbs (`"Calculate"`, `"Send"`, `"Validate"`)
- **Consistent naming**: Use similar patterns across workflow

### Layout Best Practices
- **Left to right flow**: Start inputs on left, outputs on right
- **Logical grouping**: Keep related nodes together
- **Clean connections**: Avoid crossing lines when possible
- **Adequate spacing**: Don't crowd nodes together

## Common Node Patterns

### API Data Processing
1. **HTTP Request** → Get data from API
2. **JSON Query** → Extract specific values
3. **Variable String** → Format for display
4. **Send Email** → Notify user

### Data Validation
1. **File Upload** → Receive user file
2. **File Type** → Validate file format
3. **If Then Else** → Branch on validation result
4. **Log Error** OR **Process File** → Handle outcome

### Conditional Processing
1. **Variable** → Input value
2. **Comparison** → Test condition
3. **If Then Else** → Branch workflow
4. **Different processing paths** → Handle each case

### List Processing
1. **API Request** → Get array of items
2. **JSON Query** → Extract the list
3. **List Filter** → Remove unwanted items
4. **List Map** → Transform each item
5. **Variable String** → Format results

## Debugging Nodes

### Using Test Mode
1. **Click Test button** to run workflow
2. **Watch execution flow** - active nodes highlight
3. **Check variable values** - hover over connections
4. **Review logs** - check for errors or warnings

### Common Issues

#### "Variable Required" Errors
- **Cause**: Input variable has no value or connection
- **Solution**: Set a value or connect from another node

#### "Type Mismatch" Errors
- **Cause**: Trying to connect incompatible variable types
- **Solution**: Use cast nodes or verify data types

#### "Connection Failed" Errors
- **Cause**: Network issues with HTTP requests
- **Solution**: Check URLs, authentication, network connectivity

#### "Invalid JSON" Errors
- **Cause**: Malformed JSON data
- **Solution**: Validate JSON structure, handle edge cases

### Debug Techniques
1. **Add Log nodes** temporarily to output intermediate values
2. **Use simple test data** first, then real data
3. **Test nodes individually** before connecting complex flows
4. **Check variable types** match expectations

## Performance Optimization

### Efficient Data Flow
- **Minimize HTTP requests** - batch when possible
- **Cache results** - avoid repeated expensive operations
- **Process data in chunks** - handle large datasets efficiently

### Resource Management
- **Clean up temporary data** - don't hold large objects longer than needed
- **Use appropriate variable types** - don't store numbers as strings
- **Optimize JSON queries** - use specific paths rather than processing entire objects

## Next Steps

Now that you understand nodes, learn about:
- [Variables and Connections](./variables-and-connections.md) - Advanced data flow concepts
- [Publishing and Deployment](./publishing-and-deployment.md) - Making workflows available
- [Custom Node Development](../reference/node-development.md) - Creating your own nodes