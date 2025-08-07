---
title: "Your First Workflow"
category: "tutorials"
order: 1
tags: ["tutorial", "beginner", "hands-on"]
description: "Build a simple workflow that fetches data from an API and sends an email notification"
last_updated: "2025-01-07"
---

# Your First Workflow: API to Email

In this tutorial, you'll create a simple but practical workflow that fetches data from a public API and sends an email notification. This will introduce you to the core concepts of PolySynergy Orchestrator.

## What We'll Build

A workflow that:
1. Fetches weather data from a public API
2. Processes the JSON response
3. Formats the data into a readable message
4. Sends an email notification

## Prerequisites

- Access to PolySynergy Portal
- Basic understanding of JSON data
- An email configured for sending (we'll use a simple setup)

## Step 1: Create a New Project

1. Log into your PolySynergy Portal
2. Click **"New Project"**
3. Name it: `"Weather Email Alert"`
4. Description: `"Daily weather notification workflow"`
5. Click **"Create"**

## Step 2: Add the HTTP Request Node

1. From the **Node Library**, find the **HTTP** category
2. Drag the **"HTTP Request"** node onto the canvas
3. Double-click the node to configure it:
   - **URL**: `https://api.openweathermap.org/data/2.5/weather?q=London&appid=demo&units=metric`
   - **Method**: `GET`
   - **Headers**: Leave empty for this demo
4. Click **"Save"**

> Note: This uses a demo API key. For production, you'd use your own OpenWeatherMap API key.

## Step 3: Process the JSON Response

1. Add a **"JSON Query"** node from the **Data** category
2. Connect the `response_body` output from the HTTP node to the `json_data` input of the JSON Query node
3. Configure the JSON Query node:
   - **Query Path**: `main.temp`
   - This extracts the temperature from the weather API response

## Step 4: Format the Message

1. Add a **"Variable String"** node from the **Data** category
2. Configure it with this template:
   ```
   Good morning! Today's temperature in London is {temperature}°C.
   
   Weather: {weather_description}
   
   Have a great day!
   ```
3. We need to extract more data, so add another **JSON Query** node:
   - **Query Path**: `weather[0].description`
   - Connect the HTTP response to this node too

## Step 5: Connect the Template Variables

1. Connect the first JSON Query output (`main.temp`) to the `temperature` variable in the String Template
2. Connect the second JSON Query output to the `weather_description` variable

## Step 6: Send the Email

1. Add a **"Send Email"** node from the **Email** category
2. Configure it:
   - **To**: Your email address
   - **Subject**: `"Daily Weather Update"`
   - **Body**: Connect the output from the Variable String node
   - **From**: Configure with your email settings

## Step 7: Test Your Workflow

1. Click the **"Test"** button in the toolbar
2. Watch as each node executes in sequence
3. Check that:
   - The HTTP request returns weather data
   - The JSON queries extract the correct values
   - The string template formats the message properly
   - The email is sent successfully

## Step 8: Debug Common Issues

If something goes wrong:

### HTTP Request Fails
- Check the URL is correct
- Verify you have internet connectivity
- For production, ensure you have a valid API key

### JSON Query Returns Empty
- Use the debug view to see the actual API response structure
- The weather API might have a different structure than expected
- Adjust the query paths accordingly

### Email Not Sending
- Verify your email configuration
- Check spam folder
- Ensure the email service is properly configured

## Step 9: Publish Your Workflow

Once everything works:
1. Click **"Publish"**
2. Choose your deployment settings
3. Your workflow is now available as an API endpoint
4. You can schedule it to run daily or trigger it manually

## What You Learned

- **Node basics**: Adding and configuring nodes
- **Connections**: Linking outputs to inputs
- **Data flow**: How information moves through your workflow
- **JSON processing**: Extracting data from API responses
- **String templating**: Formatting output messages
- **Testing**: Debugging and validating your workflow

## Next Steps

Try enhancing this workflow:
- Add error handling for API failures
- Include more weather data (humidity, wind speed)
- Send different emails based on weather conditions
- Store the weather data in a database for historical tracking

Check out our other tutorials:
- [Building an API Automation](./api-automation.md)
- [Data Processing Pipeline](./data-processing-pipeline.md)