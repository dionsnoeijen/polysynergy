---
title: "RAG Basics"
category: "tutorials"
order: 4
tags: ["flow", "basics", "rag", "beginner"]
description: "Learn the fundamental operations to build an agent with RAG"
last_updated: "2025-10-08"
---

# RAG Basics in PolySynergy Studio

<div class="video-container">
<iframe width="560" height="315" src="https://www.youtube.com/embed/fSOgC79wRSo" title="RAG Basics Tutorial" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>

In this tutorial, you'll learn how to create a Retrieval-Augmented Generation (RAG) workflow in PolySynergy Studio. RAG combines the power of large language models with external knowledge sources to provide more accurate and contextually relevant responses.

---

## Step 1: Follow the Agent Basics Tutorial first

Before diving into RAG, ensure you've completed the [Agent Basics](./agent-basics) tutorial. This will give you a solid foundation in creating agents within PolySynergy Studio.

---

## Step 2: Create an account at Qdrant

[Qdrant](https://qdrant.tech/) is a vector database that will store and manage the embeddings for our RAG workflow.

Create a free cluster, and get the API key and URL.

Make a new secret for the API Key, and make a new environment variable for the URL.

Make sure to have qrdant_api_key and qdrant_url as keys.

---

## Step 3: Add a Qdrant Vector Store Database node

Press "a", to bring up the node library, and search for "Qdrant Vector Store Database". Then click to add it to the canvas.

Configure it with the secret, and the url. You can add: `<environment:qdrant_url>` in the URL field, and `<secret:qdrant_api_key>` in the API Key field.
Also set the collection name to `tutorial`.

![Add Qdrant Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-1.png)

---

## Step 4: Open the file manager

At the bottom, you see a file manager tab. Click it to open the file manager.

![Open File Manager](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-2.png)

Create a folder, like `ragtutorial`, and upload those two files:

- [cape_recipes_short_2.pdf](http://localhost:8090/api/v1/documentation/assets/images/cape_recipes_short_2.pdf)
- [thai_recipes_short.pdf](http://localhost:8090/api/v1/documentation/assets/images/thai_recipes_short.pdf).

![Upload Files](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-3.png)

---

## Step 5: Add a File Selection Node

Press "a", to bring up the node library, and search for "file selection". Then click to add it to the canvas.

![Add File Selection Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-4.png)

Make sure this node is active, by clicking the node.

Then select the two files you just uploaded, and then click "assign" in the file manager.

![Select Files](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-5.png)

This node will output the file paths of the selected files.

---

## Step 6: Add a Document Knowledge Node

Press "a", to bring up the node library, and search for "document knowledge". Then click to add it to the canvas.

![Add Document Knowledge Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-6.png)

![Add Document Knowledge Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-7.png)

<div class="info">
**Note**: The Document Knowledge node supports various file types, including PDF, TXT, DOCX, and more. You can add multiple files to the File Selection node, and the Document Knowledge node will process all of them.
</div>

---

## Step 7: Also add an openai embedder node

Press "a", to bring up the node library, and search for "openai embedder". Then click to add it to the canvas.

![Add OpenAI Embedder Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-8.png)

Make sure to add the `<secret:openai_api_key>` secret to the API Key field.

---

## Step 8: Also add a chunking strategy node

Press "a", to bring up the node library, and search for "chunk". Then click to add it to the canvas.

Let's go for document chunking.

![Add Chunking Strategy Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-9.png)

---

## Step 9: Add a play node, and connect everything together

Press "a", to bring up the node library, and search for "play". Then click to add it to the canvas.

Now connect everything together, this should be easy, because the compatible connectors light up while dragging from the output to the input.

![Connect Nodes](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-10.png)

<div class="info">
**Additional**: Let's also give the play button a title and a description.
</div>

---

## Step 10: Click play to ingest the documents

Clicking play, will start the ingestion of the documents.

![Click Play](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-11.png)

<div class="info">
**Tip** Check the output, to see how many chunks were created, and how many vectors were added to the database.
**Tip** You can also check the logs, in the info tab, for more details.
</div>

---

## Step 11: Check qdrant, to see the vectors

Go to the Qdrant console, and check the collection `tutorial`, to see the vectors.

![Check Vectors](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-12.png)

In my case, I can see we have 13 points (vectors) in the collection.

---

## Step 12: Lets clean up a little

Select the nodes that do the indexing, and group them together (ctrl+g).

Then collapse the group, to save space.

Check the [documentation on groups](./grouping-basics) for more information.

To find play buttons that have been hidden in groups, click the play botton in the bottom right corner.

![Collapse Group](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-13.png)

This will bring up a list of all play buttons in the flow, including the ones in groups.

![Find Play Buttons](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-14.png)

Then click the play button of the group, to see where you can run the flow on a per environment basis.

![Run Group](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-15.png)

Just move the grouped indexing nodes to the side for now, so we have space to add the RAG nodes required to give the agent RAG capabilities.

![Open Agent Settings](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-16.png)

---

## Step 13: Set up the RAG nodes

The agent has a settings propery, open this by clicking the agent, and then the chevron next to the settings property (on the node itself).

![Open Agent Settings](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-17.png)

Now we can add a "Agent Knowledge Settings" node, a "Qdrant Vector Database" node and an "OpenAI Embedder" node.

<div class="info">
The Qdrant Vector Database and OpenAI Embedder nodes should be the same as the ones we used for indexing, so you can copy them (ctrl+c) and paste them (ctrl+v) to create duplicates. Or configure them exactly the same.
</div>

Make sure they are connected accordingly, and that the "Agent Knowledge Settings" node is connected to the "knowledge" input of the agent settings.

![Add RAG Nodes](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-18.png)

---

## Step 14: Ask it a question

Now we can ask the agent a question about something we know is in the documents.

![Ask Question](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-19.png)

Voilà! The agent answers the question based on the documents we ingested.

<div class="info">
**Tip** Shift+c to enter chat mode.
</div>

![Ask Question](http://localhost:8090/api/v1/documentation/assets/images/tutorial-rag-step-20.png)

<div class="info">
**Tip** It is recommended to group nodes that belong together, like the RAG nodes, to keep the flow organized.
</div>

---

## Congratulations! You have created a RAG workflow in PolySynergy Studio

This is a simple example of how to set up a RAG workflow. Other tutorials will explain more about chunking, different vector databases and embedders, and how to create more advanced RAG workflows.

<div class="info">
**Alpha** PolySynergy allows you to keep the indexed data in sync from external sources, tutorials will follow soon.
</div>




