---
title: "Agent Basics"
category: "tutorials"
order: 3
tags: ["flow", "basics", "interface", "beginner"]
description: "Learn the fundamental operations to build an agent in PolySynergy Studio"
last_updated: "2025-10-08"
---

# Agent Basics in PolySynergy Studio

<div class="video-container">
<iframe width="560" height="315" src="https://www.youtube.com/embed/evgV7HefDQ0" title="Agent Basics Tutorial" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>

In this tutorial, you'll learn how to create an agent in PolySynergy Studio. Agents are autonomous entities that can perform tasks, make decisions, and interact with other agents or systems.

---

## Step 1: Create a new blueprint and add an agent node

Create a new blueprint, so we have an empty canvas.

![Empty Canvas](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-1.png)

Then press "a", to bring up the node library, and search for "agent". Then click to add it to the canvas.

![Add Agent Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-2.png)

Now you have an agent node on the canvas.

![Agent Node on Canvas](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-3.png)

To the right, you can see the "Generate new avatar" button. Click it to generate a new avatar for your agent.
This takes a few seconds. It's ai generated.

![Generate Avatar](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-4.png)

---

## Step 2: Attach a model to the agent

Let's select the openai model.

![Select Model](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-5.png)

And then attach it to the agent model input.

![Attach Model](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-6.png)

---

## Step 3: Create and use a new secret

Next, we need to create a new secret, to store the `openai_api_key`, so we can use the OpenAI model.

![Attach Model](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-7.png)

Attach the model to the agent model input.

![Use Secret](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-8.png)

Now we can use it by typing: `<secret:openai_api_key>` in the `API Key` field of the OpenAI model node.

![Use Secret](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-9.png)

Then collapse the model node to save space.

![Collapse Model](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-10.png)

---

## Step 4: Add a prompt node, so we can talk to the agent

Press "a", to bring up the node library, and search for "prompt". Then click to add it to the canvas.
Then connect it to the pompt input of the agent.

![Add Prompt Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-11.png)

Once you did that, you can see the chat window changes, and is ready to receive a prompt.

![Chat Window](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-12.png)

---

## Step 5: Give the agent a memory!

Now lat's add a memory to the agent, so it can remember what we said before.

![Add Memory Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-13.png)

Then connect it to the 'db' input of the agent.

This changes the chat window again, and now you can see the memory is active. But you need a Session, as the memory is session based.

![Chat Window with Memory](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-14.png)

---

## Step 6: Create a session, and a user

In the chat window, click the "Create Session" button.
Also create a user, so the agent knows who you are.

![Create Session and User](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-15.png)

---

## Step 7: Now give it something to remember

First, lets open chat-mode, so we have a better chat experience.

![Open Chat Mode](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-16.png)

<div class="info">
**Tip**, Press shift+c to enter chat mode.
</div>

Now type something in the chat window, so the agent has something to remember. Tell it about your hobby.

![Tell Agent About Hobby](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-17.png)

Now, test if it remembers it, by asking it what your hobby is.

![Ask Agent About Hobby](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-18.png)

---

## Step 8: Give the agent some instructions!

Now let's give the agent some instructions, so it knows how to behave.

Select the agent, and check the variables panel to the right, you will see a lot of options.

<div class="info">
**Alpha**, A lot of those options are still being tested and updated.
</div>

![Agent Instructions](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-19.png)

Now ask the agent another question, you can ask it about its own hobby.

![Agent Instructions](http://localhost:8090/api/v1/documentation/assets/images/tutorial-agent-step-20.png)

## Congratulations! You have created your first agent in PolySynergy Studio!

There is a lot more to explore, but this tutorial showed you the basics of creating an agent, attaching a model, giving it memory, and interacting with it via the chat window.
