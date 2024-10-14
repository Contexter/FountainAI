# Running FountainAI Locally: A Proposal for Reengineering Custom GPT Behavior
![Local Fountain](https://coach.benedikt-eickhoff.de/koken/storage/originals/40/d5/FountainAI-Locally.png)

## Introduction

FountainAI is a sophisticated system that relies heavily on OpenAPI-driven interactions between multiple microservices. Traditionally, interaction with these services is orchestrated by a custom-configured GPT model using OpenAI’s Custom GPT configurator, which allows intelligent, contextual decision-making. To facilitate local development and testing, we propose reengineering this setup using the OpenAI Assistant SDK. This approach will allow developers to replicate the behavior of the Custom GPT configurator locally, enabling seamless, OpenAPI-driven interaction between FountainAI services and the GPT model.

## Objective

The goal of this proposal is to outline a path for running FountainAI locally by leveraging the OpenAI Assistant SDK to simulate the behavior of the Custom GPT configurator. This implementation will enable the GPT model to understand and interact with FountainAI's services according to the OpenAPI specifications, facilitating efficient testing and local integration.

## Overview of the Proposed Approach

### 1. **Understanding OpenAPI as the Basis of Interaction**

The foundation of this approach lies in the OpenAPI specifications that define each service within the FountainAI ecosystem. By using OpenAPI specs as the single source of truth, we can ensure that the GPT model’s behavior is predictable and aligned with the expected functionality of each service.

The OpenAI Assistant SDK (or API) can be configured to:

- Understand service endpoints, including their required parameters and expected responses.
- Trigger actions and provide intelligent suggestions for appropriate API calls based on the OpenAPI documentation.

### 2. **Leveraging the OpenAI Assistant SDK for Local Implementation**

To simulate the Custom GPT configurator's behavior locally, we will use the OpenAI Assistant SDK to:

- Set up a client that utilizes a persistent system message, providing context about FountainAI’s OpenAPI specifications.
- Generate API requests based on prompts that reflect the desired action (e.g., retrieving data, creating resources, or updating information).

The Assistant SDK will be configured with system prompts to establish roles, behaviors, and interaction logic:

- **System Role Definition**: Instruct the assistant to act as an API interaction layer that uses OpenAPI to generate the appropriate request for each scenario.
- **Custom Prompts**: Guide the assistant on how to utilize OpenAPI information to generate requests, manage error handling, or even interact with multiple endpoints in a specific sequence.

### 3. **Implementing the Local Client as a FastAPI Application**

We propose implementing the local client as a FastAPI application. This FastAPI app will:

- Act as an intermediary between the OpenAI Assistant SDK and the FountainAI services.
- Expose endpoints that trigger specific actions defined by the OpenAPI specifications, allowing for easy testing and interaction.
- Handle the logic for querying the Assistant, generating appropriate HTTP requests, and executing them against the local FountainAI services.
- Provide a chat interface endpoint that allows users to interact directly with the assistant, similar to the Custom GPT configurator.

The FastAPI app will:

- **Receive Requests**: Accept incoming requests for different operations, such as retrieving characters or creating new resources.
- **Query the Assistant**: Use the OpenAI Assistant SDK to generate the appropriate request details based on the OpenAPI specifications.
- **Execute the Request**: Use the generated request to interact with the corresponding FountainAI service and return the response to the user.
- **Chat Interface**: Provide an endpoint where users can send natural language queries, and the assistant will generate responses based on the available OpenAPI specs and user intent.

### 4. **Workflow for Reengineering the Custom GPT Configurator**

The following steps outline the implementation process:

#### **Step 1: Set Up Local Environment**

- Deploy all FountainAI services locally using Docker Compose.
- Ensure all services (e.g., Character Service, Action Service, Spoken Word Service) are accessible via their respective APIs.

#### **Step 2: Configure OpenAI Assistant SDK**

- Set up the OpenAI Assistant SDK with an API key to interact with GPT-4.
- Use system prompts to establish the assistant’s role, including a comprehensive understanding of FountainAI’s OpenAPI specifications.

#### **Step 3: Develop FastAPI Client**

- Create a FastAPI application that acts as the client to FountainAI and OpenAI Assistant.
- Define endpoints within the FastAPI app to handle different operations, such as retrieving data or creating resources.
- Write functions to query the Assistant for API calls, parse the generated requests, and execute them against the local FountainAI services.
- Add a chat interface endpoint (`/api/chat`) that allows users to interact with the assistant in natural language.

#### **Step 4: Simulate Custom GPT Behavior**

- Prompt the assistant using detailed OpenAPI specifications, asking it to generate valid HTTP requests based on the required actions.
- Execute those actions locally, enabling full interaction between the local services and the GPT-driven client.
- Use the chat interface to interact conversationally with the assistant.

#### **Step 5: Validate Functionality**

- Test interactions between the OpenAI Assistant and local FountainAI services to ensure the responses match expected results.
- Validate each endpoint’s behavior, including CRUD operations, using OpenAPI as the guiding standard.

### 5. **Example Workflow: Retrieving Characters from Character Service**

1. **Request to FastAPI Client**: A user sends a request to the FastAPI app to retrieve characters.
   - Example Request: `GET /api/characters`
2. **Prompt Generation**: The FastAPI app sends a prompt to the assistant to retrieve characters.
   - Example Prompt: "Generate an HTTP GET request for retrieving characters from the Character Service based on the provided OpenAPI specification."
3. **Assistant Response**: The assistant provides a detailed HTTP request.
   - Example Response:
     ```
     GET /characters HTTP/1.1
     Host: localhost:8000
     X-API-KEY: your_api_key_here
     ```
4. **Execute Request**: The FastAPI app executes the request, retrieves the character data from the Character Service, and returns it to the user.
5. **Chat Interface Example**: A user sends a chat query to `/api/chat` asking, "How can I add a new character?" The assistant responds with instructions and can generate a sample POST request for creating a new character.

### Benefits of This Approach

- **Consistency**: The local environment replicates the behavior of the production Custom GPT configurator, ensuring consistent testing outcomes.
- **Efficiency**: Using the Assistant SDK to generate actions based on OpenAPI specs reduces manual effort and improves accuracy.
- **Flexibility**: Developers can refine system prompts and user queries, adapting to new requirements or services within FountainAI.
- **Full Local Integration**: The entire interaction is localized, providing a development and testing environment that doesn’t rely on external resources beyond the OpenAI Assistant.
- **Scalable Testing**: By implementing the client as a FastAPI app, it becomes easier to scale and test different scenarios programmatically.
- **User-Friendly Chat Interface**: The chat interface allows developers and testers to interact with the system in a conversational way, enhancing usability and ease of testing.

## Conclusion

By using the OpenAI Assistant SDK to replicate the Custom GPT configurator, FountainAI developers will be able to interact with and test the system locally in an efficient, consistent, and scalable manner. This proposal outlines how to utilize OpenAPI specifications as the driving force behind the assistant’s actions, ensuring that every service interaction follows a predictable, standards-compliant pattern. Implementing the client as a FastAPI app further enhances the ability to interact with and test the system locally, providing a robust framework for development and integration.

## Next Steps

1. **Set Up Docker Compose for Local FountainAI Services**: Ensure all necessary services are running locally.
2. **Integrate OpenAI Assistant SDK**: Configure the assistant to understand and interact based on OpenAPI specifications.
3. **Develop FastAPI Client**: Write a FastAPI app that queries the assistant and interacts with the FountainAI services, including a chat interface.
4. **Begin Testing and Validation**: Test the interactions to confirm the assistant's responses are accurate and interactions are effective.

## OpenAPI 3.1.0 Specification for Local Client FastAPI App

```yaml
openapi: 3.1.0
info:
  title: FountainAI Local Client API
  version: 1.0.0
  description: |
    This OpenAPI specification defines the endpoints for the local FastAPI client that interacts with FountainAI services via the OpenAI Assistant SDK. The FastAPI app acts as an intermediary, generating requests based on OpenAPI prompts and communicating with the corresponding FountainAI microservices. It also provides a chat interface for interacting with the assistant in a conversational manner.
servers:
  - url: http://localhost:8000
    description: Local development server
paths:
  /api/characters:
    get:
      summary: Retrieve characters
      description: Retrieve a list of characters from the Character Service by using the OpenAI Assistant to generate the appropriate request.
      responses:
        '200':
          description: A list of characters retrieved successfully
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    id:
                      type: string
                      description: The unique identifier of the character
                    name:
                      type: string
                      description: The name of the character
        '400':
          description: Bad request
        '500':
          description: Internal server error
  /api/generate-request:
    post:
      summary: Generate a custom API request
      description: Use the OpenAI Assistant to generate an API request based on the provided OpenAPI specification and user prompt.
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                prompt:
                  type: string
                  description: The user prompt describing the action to perform
                openapi_spec:
                  type: string
                  description: The OpenAPI specification to be used for generating the request
              required:
                - prompt
                - openapi_spec
      responses:
        '200':
          description: The generated API request details
          content:
            application/json:
              schema:
                type: object
                properties:
                  request:
                    type: string
                    description: The generated HTTP request details
        '400':
          description: Bad request
        '500':
          description: Internal server error
  /api/chat:
    post:
      summary: Chat with the assistant
      description: Provide a chat interface to interact with the assistant. The assistant uses OpenAPI specs and user input to generate responses.
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  description: The user message to interact with the assistant
              required:
                - message
      responses:
        '200':
          description: The assistant's response
          content:
            application/json:
              schema:
                type: object
                properties:
                  response:
                    type: string
                    description: The response generated by the assistant
        '400':
          description: Bad request
        '500':
          description: Internal server error
components:
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: X-API-KEY
security:
  - ApiKeyAuth: []
```

