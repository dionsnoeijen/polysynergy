---
title: "Grouping Basics"
category: "tutorials"
order: 2
tags: ["flow", "basics", "interface", "beginner"]
description: "Learn the fundamental operations to create a group of nodes"
last_updated: "2025-10-08"
---

# Grouping Basics in PolySynergy Studio

<div class="video-container">
<iframe width="560" height="315" src="https://www.youtube.com/embed/30w3T7Xxtz0" title="Grouping Basics Tutorial" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>

In this tutorial, you'll learn how to create a group of nodes in PolySynergy Studio. Grouping nodes helps you organize your workflows, making them easier to manage and understand.

<div class="info">
**Alpha**, This example is very basic, a more advanced, real world example is coming soon.
</div>

---

## Step 1: Select Nodes to Group

![Select Nodes](http://localhost:8090/api/v1/documentation/assets/images/tutorial-grouping-step-1.png)

<div class="info">
**Tip**, You can select multiple nodes by holding down the Shift key while clicking on each node. Or you can press the "b" key and drag a selection box around the nodes you want to group.
</div>

---

## Step 2: Create the Group

Press the right mouse button, and select "Create Group" from the context menu.

![Select Nodes](http://localhost:8090/api/v1/documentation/assets/images/tutorial-grouping-step-2.png)

<div class="info">
**Tip**, Cmd+G or Ctrl+G is the shortcut to create a group.
</div>

---

## Step 3: Name the Group

You can simply change the name of a group to something that makes sense.

![Select Nodes](http://localhost:8090/api/v1/documentation/assets/images/tutorial-grouping-step-3.png)

---

## Step 4: Connect the Group

You can connect the outside of the group, to the nodes, so the conenctors are exposed to the group.

You can either connect it to a value, so the value can flow into the group, to the node.
![Select Nodes](http://localhost:8090/api/v1/documentation/assets/images/tutorial-grouping-step-5.png)

Or like this, leaving the value you have confugured intact, and just continue the flow.
![Select Nodes](http://localhost:8090/api/v1/documentation/assets/images/tutorial-grouping-step-4.png)

The output of this exmple grouped node will be "Hello Bert!".

Now if you doubleclick the group (green area), you can see the collapsed view of the group.

<div class="info">
**Tip**, You can have as manu in and out connectors as you want.
</div>

![Select Nodes](http://localhost:8090/api/v1/documentation/assets/images/tutorial-grouping-step-6.png)

---

## Step 5: Make inputs and outputs more clear

Now yoy have a node that is quite clear by it's custom name, but the input and output is rather vagua.

On the left, you have "Value" (Or Variable String, if you connected it to the green input of the variable string). And the output is "Result".

This is because the group will just take the naming of the node you connected to.

We can override those values by clicking the group, and then look at the "variables" panel to the right.

![Select Nodes](http://localhost:8090/api/v1/documentation/assets/images/tutorial-grouping-step-7.png)

If you change the overrides, you can see the group update accordingly, making it's purpuse super clear.

![Select Nodes](http://localhost:8090/api/v1/documentation/assets/images/tutorial-grouping-step-8.png)

---

## Step 6: Reconnect and run

If you took the route of connecting the input to a value, you will have to add another variable string with a name, and connect it to the input of the group.

Then, run the flow and see the result.

![Select Nodes](http://localhost:8090/api/v1/documentation/assets/images/tutorial-grouping-step-9.png)
