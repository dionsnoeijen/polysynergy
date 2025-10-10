---
title: "Creating a Route"
category: "tutorials"
order: 6
tags: ["tutorial", "route", "api", "beginner"]
description: "Learn how to create and configure a route in PolySynergy Studio"
last_updated: "2025-10-08"
---

# Creating a Route in PolySynergy Studio

In this tutorial, you'll learn how to create a route in PolySynergy Studio. A route allows you to expose your workflows via an API endpoint, enabling external systems to trigger your automation processes.

<div class="info">
**Alpha**, we are working on the endpoint api keys, right now all of them are completely open.
</div>

## Open PolySynergy Studio Editor
On the left, you see a plus button with "Routes". Click that button.
![Add Route](http://localhost:8090/api/v1/documentation/assets/images/tutorial-create-route.png)

Then a form will appear, where you can configure the route.
![The route form](http://localhost:8090/api/v1/documentation/assets/images/tutorial-create-route-form.png)

## Initial nodes

<div class="info">
**Alpha**, We are working on that you cannot delete those nodes, and or their connections.
**Alpha**, We are working on making sure that it's clear the flow needs to end in a http response node.
</div>

You will find two nodes that are created by default.
![The route form](http://localhost:8090/api/v1/documentation/assets/images/tutorial-create-route-created.png)

The orange node is the Mock node. You can configure data, to mimick a real call.

The blue node is the one you can use to start the actual flow. In a production situation, this will be the starting point. (As opposed to a mock situation where the orange mock node is the starting point).

A route flow always need to lead to a HTTP Response node, so you can return data to the caller.

![The route form](http://localhost:8090/api/v1/documentation/assets/images/tutorial-create-route-nodes.png)