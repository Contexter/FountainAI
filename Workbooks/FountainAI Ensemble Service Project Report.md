# **FountainAI Ensemble Service Workbook**

> Draft 2

![The FountainAI Ensemble Service](https://coach.benedikt-eickhoff.de/koken/storage/cache/images/000/738/Ensemble-Service,xlarge.1729067517.png)

## **1. Introduction**

The **FountainAI Ensemble Service** is a core component of the **FountainAI ecosystem**, facilitating structured interaction between the **user**, the **OpenAI Assistant SDK (The Assistant)**, and various **FountainAI services**. By leveraging an **OpenAPI-first approach**, this service dynamically generates system prompts based on the OpenAPI specifications of each integrated service.

The primary roles of the Ensemble Service include:

- **Orchestrating dialogue** between users and services through the Assistant.
- **Generating dynamic system prompts** that guide these interactions.
- **Maintaining logs** of user queries, Assistant responses, and service interactions for transparency and traceability.

This workbook provides an overview of the design, key features, and detailed implementation strategy for the **FountainAI Ensemble Service**.

---

## **2. Objectives and Scope**

### **2.1 Key Objectives**

- **System Prompt Generation**: Dynamically generate system prompts using OpenAPI definitions of the FountainAI services.
- **Service Interaction Management**: Orchestrate user inputs, Assistant responses, and interactions with various FountainAI services.
- **Interaction Logging**: Log every interaction to ensure visibility into how user queries are processed by the Assistant and FountainAI services.

### **2.2 Scope of the Service**

The FountainAI Ensemble Service is designed for both **local deployment** (for testing and development) and **cloud-based operations**. It manages queries, processes responses, and coordinates service interactions, allowing for easy updates as new services are added to the ecosystem.

---

## **3. Architecture and Design**

### **3.1 System Overview**

The FountainAI Ensemble Service functions as a middle layer between:

- **Users**: Who submit queries.
- **The Assistant (GPT model)**: Which processes user queries and generates responses.
- **FountainAI Services**: Which provide data and operations needed for responses.

### **3.2 Key Components**

- **System Prompt Factory**: Combines OpenAPI definitions from multiple services to create a unified system prompt that guides the Assistant’s behavior.
- **FastAPI Application**: Provides endpoints for user queries, system prompt generation, and interaction management.
- **Logging System**: Captures detailed logs of interactions between users, the Assistant, and services.

### **3.3 Dynamic Orchestration**

The service dynamically generates prompts based on which services are active and required during a session, ensuring that the Assistant can interact effectively with each service based on its OpenAPI definition.

---

## **4. OpenAPI-First Approach**

The OpenAPI-first approach ensures that the Assistant can dynamically parse and understand the API specifications of each integrated service. Since OpenAPI definitions are machine-readable by nature, they provide the Assistant with the comprehensive details needed to reason about the available operations and construct appropriate requests accordingly. By using OpenAPI, the Assistant is expected to:

- **Parse and Integrate Definitions**: Automatically parse the OpenAPI specifications to understand all endpoints, parameters, request types, and response formats. This gives the Assistant a complete understanding of each service.
- **Contextual Awareness of Dependencies**: Infer dependencies between services in real time. For example, if storing a script requires generating sequence numbers first, the Assistant should dynamically understand and respect this dependency.
- **Automated Validation**: Validate each constructed request against the provided OpenAPI schema to ensure it is correctly formatted before executing the request. If validation fails, the Assistant should adjust its request accordingly.
- **Dynamic Request Construction**: Based on user input, the Assistant constructs correct API requests, including handling dependencies such as generating sequence numbers, creating or updating entities, and managing interdependent service calls. This minimizes errors related to incorrect request structures or missing data.
- **Dynamic Workflow Inference**: The Assistant should dynamically infer the sequence of API interactions needed by parsing OpenAPI definitions in real time. This approach enables the Assistant to adapt to different user requests, reason about dependencies, and construct workflows without predefined limitations, thereby maintaining flexibility and ensuring context-aware operations.

### **4.1 OpenAPI Specification Overview**

Below is the **OpenAPI specification** for the **FountainAI Ensemble Service**:

```yaml
openapi: 3.1.0
info:
  title: FountainAI Ensemble Service
  description: |
    The FountainAI Ensemble Service acts as the intermediary between the user, the OpenAI Assistant SDK, and FountainAI services. It dynamically generates system prompts from multiple OpenAPI definitions and manages service interactions.
  version: 1.1.0
servers:
  - url: http://localhost:8000
    description: Local deployment for testing and development

paths:
  /system-prompt:
    get:
      summary: Generate system prompt for the Assistant based on multiple services
      description: Generates a system prompt for the Assistant using OpenAPI definitions from multiple FountainAI services.
      operationId: generateSystemPrompt
      parameters:
        - name: services
          in: query
          required: true
          schema:
            type: array
            items:
              type: string
          description: List of FountainAI services to include in the system prompt
      responses:
        '200':
          description: System prompt generated successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  system_prompt:
                    type: string
                    description: The generated system prompt for the Assistant
              example:
                system_prompt: "You are an AI assistant interacting with various FountainAI services through their OpenAPI specifications. Parse each service's OpenAPI definition to determine available operations, required parameters, and response formats. For user queries, identify the appropriate sequence of service calls, including dependencies like sequence number generation from the Central Sequence Service before storing a new section. Validate all requests against the OpenAPI specification before executing. Act as an intermediary, making sure all interactions follow the API logic accurately."

        '400':
          description: Bad Request - Invalid service list
        '500':
          description: Internal Server Error

  /interact:
    post:
      summary: Handle user input and dynamically manage dialogue between the Assistant and services
      description: Handles user input, sends it to the Assistant, and manages service requests based on a dynamically generated system prompt.
      operationId: handleUserInput
      requestBody:
        description: User input to be processed by the Assistant
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                user_input:
                  type: string
                  description: The user's query or instruction
      responses:
        '200':
          description: Assistant and service interaction response
          content:
            application/json:
              schema:
                type: object
                properties:
                  assistant_response:
                    type: string
                    description: The Assistant's response
                  service_responses:
                    type: array
                    items:
                      type: object
                      properties:
                        service_name:
                          type: string
                          description: FountainAI service invoked
                        response:
                          type: string
                          description: Response from the service
              example:
                assistant_response: "The character John Doe moves to the door."
                service_responses:
                  - service_name: "Character Service"
                    response: "Character details retrieved successfully."
                  - service_name: "Action Service"
                    response: "Action 'move to door' processed successfully."
        '400':
          description: Bad Request
        '500':
          description: Internal Server Error

  /logs:
    get:
      summary: Retrieve logs of system-prompt-driven interactions
      description: Logs past interactions, capturing key variables such as user input, Assistant responses, and service interactions.
      operationId: retrieveLogs
      responses:
        '200':
          description: Logs retrieved successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  logs:
                    type: array
                    items:
                      type: object
                      properties:
                        timestamp:
                          type: string
                          description: Time of interaction
                        user_input:
                          type: string
                          description: User's input
                        assistant_response:
                          type: string
                          description: Assistant's response
                        service_responses:
                          type: array
                          items:
                            type: object
                            properties:
                              service_name:
                                type: string
                                description: FountainAI service invoked
                              response:
                                type: string
                                description: Response from the service
              example:
                logs:
                  - timestamp: "2024-10-17T12:34:56Z"
                    user_input: "Retrieve actions for character John Doe."
                    assistant_response: "Character John Doe performs an action."
                    service_responses:
                      - service_name: "Action Service"
                        response: "Action 'enter room' retrieved successfully."
```

---

## **5. Implementation Strategy**

The implementation strategy for the FountainAI Ensemble Service focuses on leveraging **Dynamic Workflow Inference** to ensure seamless, adaptive interaction with multiple APIs. This strategy aims to guide the Assistant in real-time decision-making, based on the OpenAPI specifications of each integrated service, without relying on predefined workflows. The following steps outline the modular approach to creating, deploying, and maintaining the Ensemble Service.



### **Step 1: Directory Structure Creation**

**Goal**: Create the necessary directory structure for the service.

**Prompt**:

```
Please write a shell script called `create_directory_structure.sh` that will create the following directories for the FountainAI Ensemble Service:

1. `/app/prompt_factory` - for managing the System Prompt Factory.
2. `/app/interactions` - for managing the interaction flow.
3. `/app/logs` - for logging user input, Assistant responses, and service interactions.
4. `/app/schemas` - for validating requests and responses between the Assistant and services.

The script should print confirmation for each directory created.
```

### **Step 2: FastAPI Entry Point for System-Prompt-Driven Dialogue**

**Goal**: Set up the FastAPI entry point that handles user queries, generates system prompts, and manages the interaction flow.

**Prompt**:

```
Please write a shell script called `generate_main_entry.sh` that creates a FastAPI entry point (`app/main.py`). This script should:

1. Set up a FastAPI app with routes `/interact` and `/system-prompt`.
2. Create the `/interact` route to handle user input and manage service requests.
3. Create the `/system-prompt` route to generate system prompts using OpenAPI definitions.
4. Ensure proper logging of user input, Assistant responses, and service interactions.
```

### **Step 3: System Prompt Factory Creation**

**Goal**: Implement the **System Prompt Factory**.

**Prompt**:

**Goal**: Implement the **System Prompt Factory**, which will also include logic from the **Internal Workflow Map** to facilitate efficient API interaction.

**Prompt**:

```
Please write a shell script called `generate_prompt_factory.sh` that implements the System Prompt Factory in `/app/prompt_factory`. The script should:

1. Fetch OpenAPI definitions from FountainAI services.
2. Combine the OpenAPI definitions into a system prompt that guides the Assistant’s behavior.
3. Integrate the `WorkflowMap` class to determine the correct sequence of API calls based on user requests, ensuring services are invoked in the proper order and dependencies are respected.
```

### **Step 4: Schema Validation for Assistant and Service Interactions**

**Goal**: Create Pydantic schemas to validate requests and responses between the Assistant and services.

**Prompt**:

```
Please write a shell script called `generate_schemas.sh` that creates Pydantic schemas in `/app/schemas`. The script should:

1. Define schemas for validating requests sent to the Assistant.
2. Validate system prompts, service interactions, and API responses.
```

### **Step 5: Interaction Logging Setup**

**Goal**: Set up logging to capture interactions.

**Prompt**:

```
Please write a shell script called `generate_logging.sh` that sets up a logging system in `/app/logs`. The script should:

1. Log user input, Assistant responses, service interactions, and system prompts.
2. Store logs in a structured format for easy retrieval and debugging.
```

### **Step 6: Dockerfile Creation**

**Goal**: Containerize the FountainAI Ensemble Service.

**Prompt**:

```
Please write a shell script called `create_dockerfile.sh` that generates a Dockerfile for the FountainAI Ensemble Service. The Dockerfile should:

1. Use a Python 3.9+ base image.
2. Install FastAPI and the OpenAI SDK.
3. Copy necessary app files and run the FastAPI app on port 8000.
```

### **Step 7: Docker Compose for Service Orchestration**

**Goal**: Use Docker Compose to orchestrate the services.

**Prompt**:

```
Please write a shell script called `create_docker_compose.sh` that generates a `docker-compose.yml` file. The script should:

1. Define services for the FastAPI app and the Assistant SDK.
2. Ensure services can communicate via networking.
```

### **Step 8: Main Shell Script for Running All Components**

**Goal**: Orchestrate the entire system setup.

**Prompt**:

```
Please write a shell script called `setup_fountainai_ensemble.sh` that runs all the shell scripts in sequence to set up the FountainAI Ensemble Service.
```

---

## **6. Conclusion**

This workbook provides a comprehensive overview of the **FountainAI Ensemble Service** and its **OpenAPI-first design**. The detailed architecture and implementation strategy ensure seamless interaction between users, the Assistant, and FountainAI services. The accompanying shell scripts facilitate straightforward deployment and configuration, enabling flexibility in both local and cloud environments.

