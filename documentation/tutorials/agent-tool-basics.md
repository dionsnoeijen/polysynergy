---
title: "Agent Tool Basics"
category: "tutorials"
order: 5
tags: ["flow", "basics", "tool", "beginner"]
description: "Learn the fundamental operations to build an agent with RAG"
last_updated: "2025-10-08"
---

# Agent Tool Basics in PolySynergy Studio

In this tutorial, you'll learn how to create an agent that uses tools in PolySynergy Studio. Tools allow agents to interact with external systems, perform specific tasks, and enhance their capabilities.

---

## Step 1: Follow the Agent Basics Tutorial first

Before diving into tools, ensure you've completed the [Agent Basics](./agent-basics) tutorial. This will give you a solid foundation in creating agents within PolySynergy Studio.

---

## Step 2: Add a DuckDuckGo Tool node

Press "a", to bring up the node library, and search for "DuckDuckGo". Then click to add it to the canvas.

![Add DuckDuckGo Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-1.png)

The agent has the tol available now, and it will use it whenever it finds it useful.

If you want the agent to choose the tool more often, you can update the intstruction field in the agent node.

![Prompt Agent](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-2.png)

---

## Step 3: Now prompt the agent

Make sure to prompt for something that requires a web search. In this case I searched for my name, so I am certain the agent will use the tool.

![Prompt Agent](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-3.png)

You will see it used the search tool, and got the correct answer.

---

# Step 4: Let's make a custom tool

Now let's make a custom tool that the agent can use. We will make a simple calculator tool.

First, add a Path Tool Node.

![Add Path Tool Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-4.png)

Let's configure it to be a calculator. Set the following fields:

- Function Name: `add_two_numbers`
- Description: `Adds two numbers together.`

Also set two parameters:

`number_a` of type `int` and description `The first number to add.`
`number_b` of type `int` and description `The second number to add.`

![Configure Path Tool Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-5.png)

---

# Step 5: Add the nodes for addition

First, connect the agent to the path tools.

Add the 'Add' node, which adds two numbers together.

![Add Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-6.png)

Now add the 'Tool Result' node, which will deliver the eventual result to the agent.

Configure the 'Tool Result' node to use an output argument.
Name it: `addition_result`, and describe the output as: `The result of the addition.`

![Tool Result Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-7.png)

Now connect the add node like this:

![Connect Add Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-8.png)

Let's see if it works: Ask the agent: "What is 5 + 7?"

Yay, it works! The result is 12. Check the output of the tool result as well, to see if it got executed.

![Agent Addition](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-9.png)

<div class="info">
**Tip**: Everything comes down to explicitly defining what everything means. From the argument names to their descriptions. This helps the agent understand how to use the tool correctly.
</div>

---

## Step 6: Let's make it a bit more interesting

First, clear the tools we have now.

![Clear Tools](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-10.png)

---

## Step 7: Let's add a couple of nodes

We are going to make a receipt tool, that can read an image of a receipt, then normalize the result into a json, and then store it in a database.

Nodes:
- Path Tool
- Variable List
- Agno Agent
- JSON Example To Response Model
- Agent Response Model Settings
- Agno Tool Result
- OpenAI Model

### Configure the Path Tool

Set the following fields:

- Name: `Receipt Processor`
- Function Name: `process_receipt`
- Description: `Processes a receipt image and extracts relevant information.`
- Parameters: `receipt_path` of type `string` and instructions `This is the path to the receipt, that will be passed to another agent, that can parse the receipt into a format that is suitable for further processing.`

![Configure Path Tool Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-11.png)

### Configure the Variable List

The variable list is simply there to convert the receipt_path argument into a list, so we can pass it to the agent.

![Configure Variable List Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-12.png)

### Configure the Agno Agent

This agent will be responsible for parsing the receipt. It will use an OpenAI model to do so.

- Prompt: `You are a receipt parsing agent. Your task is to extract relevant information from the receipt image and format it into the structured JSON format.`

Also connect the variable list with the files, and connect an openai model to the agent, with the secret `<secret:openai_api_key>`.

![Configure Agno Agent Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-13.png)

### Configure JSON Example To Response Model

This node will help the agent understand the format we want the receipt to be in.

- Example JSON:
```json
{
    "receipt_type": "parking",
    "merchant": {
      "name": "Q-Park Centrum",
      "location": "Stationsplein 1, Amsterdam"
    },
    "receipt_number": "QP-20250925213456",
    "date": "2025-09-25",
    "time": "21:34",
    "items": [
      {
        "description": "Parkeren",
        "duration": "3u 24min",
        "amount": 14.50
      },
      {
        "description": "Toeslag avond",
        "duration": null,
        "amount": 2.00
      }
    ],
    "total": 16.50,
    "payment_method": "PIN",
    "currency": "EUR"
  }
```

![Configure JSON Example To Response Model Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-14.png)

### Configure Agent Response Model Settings

Connect the Agent Response Model Settings to the Agno Agent, and connect the JSON Example To Response Model to the settings node.

![Configure Agent Response Model Settings Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-15.png)

### Configure Agno Tool Result

Make sure the result can receive the normalized receipt.

- Result: `normalized_receipt` with instructions: `This is the normalized receipt in JSON format.`

![Configure Agno Tool Result Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-16.png)

Connect the agent result to that result.

![Connect Agno Tool Result Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-17.png)

### Test the tool

Open up chat mode, and upload a receipt image.

Like this receipt for example:
![benzine_total_01.png](http://localhost:8090/api/v1/documentation/assets/images/benzine_total_01.png)

Add the image to the prompt by pressing the paperclip icon in the chat input field.
Then ask the agent: "Please process the receipt I just uploaded."
![Test Receipt Tool](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-18.png)

You should see the agent process the receipt, and return a normalized JSON response.
But you are getting the result from the agent, not from the tool, so check the output to see if everything is normalized properly.

![Receipt Tool Result](http://localhost:8090/api/v1/documentation/assets/images/tutorial-tools-step-19.png)

Nice! This worked out well.

---

## Step 8: Next Steps

Now, as a challenge, you might want to try and store the normalized receipt in a database.
Use a HTTP Request node to send the data to a REST API endpoint that can store the receipt.

## Congratulations! You've successfully created an agent that uses tools in PolySynergy Studio. 

Experiment with different tools and configurations to enhance your agent's capabilities further!

Also understand:

- An agent can use multiple tools.
- Tools can be as simple or complex as needed.
- The key is in defining clear function names, descriptions, and parameters for each tool.
- The more explicit you are, the better the agent can utilize the tools effectively.
