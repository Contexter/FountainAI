# FountainAI Matrix Bot API Documentation

## Table of Contents
1. [Introduction to the FountainAI Matrix Bot](#introduction-to-the-fountainai-matrix-bot)
2. [Introduction to Matrix Bots](#introduction-to-matrix-bots)
   - [Reasoning Behind Bots in Matrix](#reasoning-behind-bots-in-matrix)
   - [How Bots Are Deployed within the Matrix Platform](#how-bots-are-deployed-within-the-matrix-platform)
   - [Quickest Way to Develop Matrix Bots](#quickest-way-to-develop-matrix-bots)
3. [Flow Chart: Enhanced Autonomous Workflow](#flow-chart-enhanced-autonomous-workflow)
4. [OpenAPI Specification](#openapi-specification)
   - [Info](#info)
   - [Paths](#paths)
     - [Retrieve the Latest Meta Prompt](#retrieve-the-latest-meta-prompt)
     - [Execute an API Command](#execute-an-api-command)
     - [Verify the Response from an API Call](#verify-the-response-from-an-api-call)
     - [Send the Final Verified Response to the User](#send-the-final-verified-response-to-the-user)
   - [Components](#components)
     - [MetaPrompt Schema](#metaprompt-schema)
     - [APICall Schema](#apicall-schema)
     - [VerifyResponse Schema](#verifyresponse-schema)
     - [UserNotification Schema](#usernotification-schema)
   - [Security](#security)
5. [Detailed Breakdown of the API Interactions](#detailed-breakdown-of-the-api-interactions)

## Introduction to the FountainAI Matrix Bot

The **FountainAI Matrix Bot** is a sophisticated assistant designed to enhance script management and editing workflows within the Matrix chat environment. This bot integrates with FountainAI's suite of APIs, providing seamless interactions for managing various script components. The bot leverages OpenAI's GPT models to understand user intents and relay actions, serving as a bridge between human input and automated script management.

## Introduction to Matrix Bots

Matrix is an open network for secure, decentralized communication. It provides a protocol that enables real-time communication over the Internet with a focus on interoperability, security, and user privacy. Within this ecosystem, bots play a crucial role in enhancing user experience and automating various tasks. Matrix bots are automated agents that can interact with users and rooms within the Matrix network, providing functionalities ranging from simple message responses to complex integrations with external services.

### Reasoning Behind Bots in Matrix

The deployment of bots within the Matrix network is driven by several key reasons:

1. **Automation**: Bots can handle repetitive tasks such as welcoming new users, moderating discussions, and managing room settings, reducing the administrative burden on human users.
2. **Integration**: Bots can act as bridges between Matrix and other services, such as social media platforms, ticketing systems, or development tools, facilitating seamless integration and data flow.
3. **Enhanced Functionality**: By providing additional capabilities like reminders, notifications, and custom commands, bots can enhance the overall functionality of Matrix rooms.
4. **User Engagement**: Bots can engage users through interactive features such as games, polls, and trivia, making communication more engaging and dynamic.

### How Bots Are Deployed within the Matrix Platform

Deploying bots in the Matrix ecosystem involves the following steps:

1. **Creating a Matrix User**: Each bot operates as a Matrix user, requiring a unique user account within the Matrix server (also known as a homeserver). This can be done through the Matrix client or programmatically via the Matrix API.
   
2. **Setting Up the Bot Environment**: The bot environment includes the necessary libraries and frameworks to interact with the Matrix API. Popular libraries include matrix-nio (Python), matrix-bot-sdk (JavaScript), and matrix-rust-sdk (Rust).

3. **Connecting to the Homeserver**: The bot connects to the Matrix homeserver using its credentials. This connection can be established via access tokens obtained during the authentication process.

4. **Listening for Events**: Bots listen for specific events in the Matrix rooms they are part of. These events can include messages, membership changes, and state updates. Based on these events, the bot performs predefined actions.

5. **Responding to Events**: Upon detecting an event, the bot executes its logic and responds appropriately. For instance, if a user sends a specific command, the bot can process this command and return the relevant information or perform a task.

### Quickest Way to Develop Matrix Bots

The quickest way to develop Matrix bots involves using high-level libraries and frameworks that abstract much of the complexity of interacting with the Matrix API. Here is a step-by-step guide to quickly getting started with a Matrix bot:

1. **Choose a Programming Language and Library**: Select a language and its corresponding Matrix library. For example, Python with matrix-nio, or JavaScript with matrix-bot-sdk.

2. **Install the Library**:
   - For Python:
     ```bash
     pip install matrix-nio
     ```
   - For JavaScript:
     ```bash
     npm install matrix-bot-sdk
     ```

3. **Set Up the Bot**: Create a basic bot script to connect to the Matrix homeserver, listen for events, and respond to them. Here’s an example in Python using matrix-nio:

   ```python
   from nio import AsyncClient, MatrixRoom, RoomMessageText
   import asyncio

   async def main():
       client = AsyncClient("https://your-homeserver", "your-bot-username")

       await client.login("your-bot-password")

       async def message_callback(room: MatrixRoom, event: RoomMessageText):
           if event.body.startswith("!hello"):
               await client.room_send(
                   room_id=room.room_id,
                   message_type="m.room.message",
                   content={"msgtype": "m.text", "body": "Hello, World!"},
               )

       client.add_event_callback(message_callback, RoomMessageText)

       await client.sync_forever(timeout=30000)

   asyncio.get_event_loop().run_until_complete(main())
   ```

4. **Run and Test the Bot**: Execute the bot script and test it in your Matrix room by sending the command (e.g., `!hello`).

5. **Deploy the Bot**: For continuous operation, deploy the bot on a server or a cloud platform. Use tools like Docker for containerization and systemd for managing the bot as a service.

## Flow Chart: Enhanced Autonomous Workflow

```plaintext
User
  │
  │ 1. Sends a message (e.g., "I'd like to see some recent scripts and maybe write a new one about a sunset.")
  │
  ▼
Matrix Chat Room
  │
  │ 2. Message is received by the bot
  │
  ▼
FountainAI Matrix Bot (Vapor App)
  │
  │ 3. Bot retrieves the latest meta prompt from the Meta Prompt API
  │    └───> HTTP GET /meta-prompt
  │
  ▼
Meta Prompt API
  │
  │ 4. Returns the latest meta prompt (composed from OpenAPI specs)
  │    └───> Meta Prompt
  │
  ▼
FountainAI Matrix Bot (Vapor App)
  │
  │ 5. Bot combines the meta prompt with the current user payload
  │    └───> Combined Prompt: Meta Prompt + User Message
  │
  ▼
OpenAI GPT Model
  │
  │ 6. Bot sends the combined prompt to the GPT model
  │    └───> API Call with Combined Prompt
  │
  │ 7. GPT model processes the combined prompt and generates a response
  │    └───> Response: API Commands with Payloads
  │
  ▼
FountainAI Matrix Bot (Vapor App)
  │
  │ 8. Bot executes the API commands suggested by the GPT model
  │    └───> HTTP POST /api-call
  │
  ▼
Scripts API   SectionHeadings API   SpokenWords API  Transition API    Other APIs
  │               │                   │                │                   │
  │ 9. Bot processes the API response and sends it to the GPT model for verification
  │    └───> HTTP POST /verify-response
  │
  ▼
OpenAI GPT Model
  │
  │ 10. GPT model verifies the API response
  │    └───> Scenarios:
  │           a. **Successful Verification**: Confirms successful API action. The bot prepares the final response for the user.
  │           b. **Partial Mismatch**: Identifies discrepancies, suggests modifications. The bot informs the user or makes further API calls to correct data.
  │           c. **Failure/Error**: Assesses the error, determines cause, suggests retries or alternative actions.
  │           d. **Unexpected Response**: Flags unexpected responses, provides error handling, and suggests contacting support or alternative actions.
  │           e. **No Response/Timeout**: Identifies timeout, suggests retries. The bot may retry a few times before informing the user.
  │
  ▼
FountainAI Matrix Bot (Vapor App)
  │
  │ 11. Bot sends the verified response back to the user
  │    └───> HTTP POST /user-notification
  │
  ▼
Matrix Chat Room
  │
  │ 12. User sees the response and continues the interaction
  │
  ▼
User
```

## OpenAPI Specification

### Info

```yaml
openapi: 3.0.1
info:
  title: FountainAI Matrix Bot API
  description: >
    The FountainAI Matrix Bot is a sophisticated assistant designed to enhance script management and editing workflows within the Matrix chat environment. This bot integrates with FountainAI's suite of APIs, providing seamless interactions for managing various script components. The bot leverages OpenAI's GPT models to understand user intents and relay actions, serving as a bridge between human input and automated script management.
  version: 1.0.0
servers:
  - url: https://api.fountain.coach
    description: FountainAI API Server
```
### Paths
#### Retrieve the Latest Meta Prompt

**Step in Workflow: 3. Bot retrieves the latest meta prompt from the Meta Prompt API**

```yaml
paths:
  /meta-prompt:
    get:
      summary: Retrieve the latest meta prompt
      responses:
        '200':
          description: A meta prompt used to generate responses.
          content:
            application/json:
              schema:
                type: object
                properties:
                  meta_prompt:
                    type: string
                    example: "Write a new script about..."
```

#### Execute an API Command

**Step in Workflow: 8. Bot executes the API commands suggested by the GPT model**

```yaml
  /api-call:
    post:
      summary: Execute an API command as suggested by the GPT model
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                command:
                  type: string
                  example: "create_script"
                payload:
                  type: object
                  example: { "title": "Sunset Script", "content": "A beautiful sunset..." }
      responses:
        '200':
          description: The API command executed successfully.
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: "success"
```

#### Verify the Response from an API Call

**Step in Workflow: 9. Bot processes the API response and sends it to the GPT model for verification**

```yaml
  /verify-response:
    post:
      summary: Verify the response from an API call
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                response:
                  type: object
                  example: { "status": "success", "data": { "script_id": "12345" } }
      responses:
        '200':
          description: The API response verification result.
          content:
            application/json:
              schema:
                type: object
                properties:
                  verification_result:
                    type: string
                    example: "success"
                  action:
                    type: string
                    example: "notify_user"
                  discrepancies:
                    type: array
                    items:
                      type: string
                    example: ["Mismatch in script content"]
```

#### Send the Final Verified Response to the User

**Step in Workflow: 11. Bot sends the verified response back to the user**

```yaml
  /user-notification:
    post:
      summary: Send the final verified response to the user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                user_id:
                  type: string
                  example: "user123"
                message:
                  type: string
                  example: "Your script about the sunset has been created successfully."
      responses:
        '200':
          description: The user has been notified successfully.
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: "notified"
```

### Components

#### MetaPrompt Schema

```yaml
components:
  schemas:
    MetaPrompt:
      type: object
      properties:
        meta_prompt:
          type: string
          example: "Write a new script about..."
```

#### APICall Schema

```yaml
    APICall:
      type: object
      properties:
        command:
          type: string
          example: "create_script"
        payload:
          type: object
          example: { "title": "Sunset Script", "content": "A beautiful sunset..." }
```

#### VerifyResponse Schema

```yaml
    VerifyResponse:
      type: object
      properties:
        response:
          type: object
          example: { "status": "success", "data": { "script_id": "12345" } }
```

#### UserNotification Schema

```yaml
    UserNotification:
      type: object
      properties:
        user_id:
          type: string
          example: "user123"
        message:
          type: string
          example: "Your script about the sunset has been created successfully."
```

### Security

```yaml
security:
  - BearerAuth: []
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

---

## Detailed Breakdown of the API Interactions

1. **User Sends a Message**
   - **Description**: The user sends a message in the Matrix chat room.
   - **Example**: "I'd like to see some recent scripts and maybe write a new one about a sunset."
   
2. **Message Received by the Bot**
   - **Description**: The bot receives the user's message from the Matrix chat room.
   
3. **Bot Retrieves the Latest Meta Prompt**
   - **API Endpoint**: `GET /meta-prompt`
   - **Description**: The bot retrieves the latest meta prompt from the Meta Prompt API.
   - **Example Response**:
     ```json
     {
       "meta_prompt": "Write a new script about..."
     }
     ```

4. **Returns the Latest Meta Prompt**
   - **Description**: The Meta Prompt API returns the latest meta prompt to the bot.
   
5. **Bot Combines Meta Prompt with User Payload**
   - **Description**: The bot combines the meta prompt with the current user payload to create a combined prompt.
   - **Example Combined Prompt**: "Write a new script about a sunset."

6. **Bot Sends Combined Prompt to GPT Model**
   - **Description**: The bot sends the combined prompt to the GPT model for processing.
   - **Example API Call**: 
     ```json
     {
       "prompt": "Write a new script about a sunset."
     }
     ```

7. **GPT Model Processes Combined Prompt**
   - **Description**: The GPT model processes the combined prompt and generates a response.
   - **Example Response**:
     ```json
     {
       "commands": [
         {
           "command": "create_script",
           "payload": {
             "title": "Sunset Script",
             "content": "A beautiful sunset..."
           }
         }
       ]
     }
     ```

8. **Bot Executes API Commands Suggested by GPT Model**
   - **API Endpoint**: `POST /api-call`
   - **Description**: The bot executes the API commands suggested by the GPT model.
   - **Example API Call**:
     ```json
     {
       "command": "create_script",
       "payload": {
         "title": "Sunset Script",
         "content": "A beautiful sunset..."
       }
     }
     ```

9. **Bot Processes API Response and Sends to GPT Model for Verification**
   - **API Endpoint**: `POST /verify-response`
   - **Description**: The bot processes the API response and sends it to the GPT model for verification.
   - **Example API Call**:
     ```json
     {
       "response": {
         "status": "success",
         "data": {
           "script_id": "12345"
         }
       }
     }
     ```

10. **GPT Model Verifies API Response**
    - **Description**: The GPT model verifies the API response and handles different scenarios.
    - **Scenarios**:
      - **Successful Verification**: Confirms successful API action.
      - **Partial Mismatch**: Identifies discrepancies, suggests modifications.
      - **Failure/Error**: Assesses the error, determines cause, suggests retries or alternative actions.
      - **Unexpected Response**: Flags unexpected responses, provides error handling, and suggests contacting support or alternative actions.
      - **No Response/Timeout**: Identifies timeout, suggests retries. The bot may retry a few times before informing the user.

11. **Bot Sends Verified Response Back to User**
    - **API Endpoint**: `POST /user-notification`
    - **Description**: The bot sends the verified response back to the user.
    - **Example API Call**:
      ```json
      {
        "user_id": "user123",
        "message": "Your script about the sunset has been created successfully."
      }
      ```

12. **User Sees the Response**
    - **Description**: The user sees the response in the Matrix chat room and continues the interaction.


