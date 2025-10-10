---
title: "Flow Basics"
category: "tutorials"
order: 1
tags: ["flow", "basics", "interface", "beginner"]
description: "Learn the fundamental operations to build a flow in PolySynergy Studio"
last_updated: "2025-10-08"
---

# Flow Basics in PolySynergy Studio

## Step 1: Create a new blueprint

Create a new blueprint, so we have an empty canvas.

![Empty Canvas](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-1.png)

---

## Step 2: Add a play node

With a play node, you can start the flow manually.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-2.png)

<div class="info">
You can add as many play nodes as you want, so you can test sub parts of your flow for example.
</div>

---

## Step 3: Add variable string node

Press "a", to bring up the node library, and search for "variable string". Then click to add it to the canvas.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-3.png)

---

## Step 4: Connect!

Then connect the green output of the play node to the green input of the variable string node.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-4.png)

---

## Step 5: Click play

In the bottom left corner, there is a play button, it will start the flow as well as the play button in the node itself.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-5.png)

### Congratulations! You have executed your first flow!

<div class="info">
**Tip**: In the bottom left panel you see the logs that belong to the last flow execution.
</div>

---

## Step 6: Hello World!

But, this was a little too boring. we can make it a little bit more interesting, let's make a hello world flow.
Select the variable string node and change the right side, to the variables tab. This way you see the configurable fields of the node.

Enter "Hello World!" in the "Value" field.

<div class="info">
**Tip**: You can clear the execution info on the nodes (the green border and the order numbers) by pressing "c" on the keyboard.
</div>

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-6.png)

Now run the flow again. To the right you can see the output of the second run. Click the last output row (2), to see the details.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-7.png)

### Congratulations again! You have executed your first hello world flow!

---

## Step 7: Hello {{ myName }}!

Now let's make it a little bit more dynamic. Change the value of the variable string node to "Hello {{ myName }}!".

Now check the output again! Even though the node executed successfully, the output is on "false_path". Which is the Red output connector.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-8.png)

---

## Step 8: Why red output?

The placeholder `{{ myName }}` is not defined, so the node cannot replace it with a value. 
For that reason, the node fails, and uses the red output connector.

Let's see why this is useful. Let's add a log error node to the flow, and then a log info node.

Connect the info node message input to the green output of the variable string node.
Connect the error node message input to the red output of the variable string node.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-9.png)

Now run the flow again. As you can see, the flow system choose the "false_path", and executed the log error node.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-10.png)

This is how you can steer the flow, and take different actions based on the success or failure of a node.

<div class="info">
**Tip**: The error is logged in de flow logs at the bottom left, as well as it is visible in the output panel on the right.
</div>

---

## Step 9: Define the variable

Now let's define the variable `myName`, so the variable string node can execute successfully.

Let's select the variable string node again, so we can add a variable to it.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-11.png)

To the right you can see "values", right below the value where "Hello {{ myName }}!" is defined, click the pencil button to edit the values.

A form will appear, where you can add a new variable.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-12.png)

Click: Add row. Then enter "myName" in the key field, and "Connie" in the value field. Then click "Save Dictionary".

<div class="info">
**Tip**: On the node, you can also see the "values" property, it has a chevron, you can click it to show the values in the node itself.
</div>

Execute the flow again. And you will see the flow executed by choosing the green output connector (true_path).

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-13.png)

---

## Step 10: Now, finally, we will make a dynamic Hello {{ myName }}!

Well, that's cool and all, but still not very dynamic.

Before we add another variable string node, let's make sure the "values" on the existing variable string node is configured correctly.

Click the pencil button again, to edit the values, and then switch the "In" toggle on the "myName" variable.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-14.png)

Save the dictionary again, and now we are ready to add another variable string node.

We shall place it before the existing variable string node, give it a value of "Superman" and connect it to the input of the "myName" variable in the dictionary of the existing variable string node.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-15.png)

Now run the flow again, and see the magic happen!

---

### Congratulations! You have created a dynamic flow that says Hello to a variable name!

This obviously is a very simple example, but it shows the basics of building a flow in PolySynergy Studio.

---

## Step 11: Accessing variable from previous node

There is another way to access the name variable, without using the dynamic connectors of the dictionary.

Let's remove the connection from the output of the second variable string node to the input of the "myName" variable in the dictionary of the first variable string node.

Then we will change the value of the first variable string node to "Hello {{ name_node.value }}!".

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-16.png)

The nodes always get a random node handle value, just change it to name_node, or leave it the way it is. For this example I changed it to name_node.

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-17.png)

Also, I reconnected the green output of the "name_node" to the green input of the hello node. That is because we are not passing a value. We are just making it part of the flow.

<div class="info">
**Tip**: Referencing values from other nodes, is most useful when you need a value many nodes later in the flow.
</div>

Run the flow again, and see the magic happen!

<div class="info">
**Tip**: To see the values that are available to a given node, you can switch the left panel to "Handles". Select a node and the panel will update with the available handles.
</div>

![Add Play Node](http://localhost:8090/api/v1/documentation/assets/images/tutorial-basic-flow-step-18.png)

