

# **FountainAI Ensemble Service Workbook**
> Draft 

![The FountainAI Ensemble Service](https://coach.benedikt-eickhoff.de/koken/storage/cache/images/000/738/Ensemble-Service,xlarge.1729067517.png)
## **1. Introduction**

The **FountainAI Ensemble Service** is a crucial part of the **FountainAI ecosystem**, enabling structured interaction between the **user**, the **OpenAI Assistant SDK (The Assistant)**, and various **FountainAI services**. The service relies on an **OpenAPI-first approach**, ensuring that system prompts are dynamically generated based on the OpenAPI specifications of each service.

The key roles of this service are:
- **Orchestrating dialogue** between users and services via the Assistant.
- **Generating dynamic system prompts** that guide interactions.
- **Maintaining logs** of user queries, Assistant responses, and service interactions for transparency.

This workbook provides an overview of the design, key features, and detailed implementation strategy for the **FountainAI Ensemble Service**.

---

## **2. Objectives and Scope**

### **2.1 Key Objectives**
- **System Prompt Generation**: The service generates dynamic system prompts using OpenAPI definitions of FountainAI services.
- **Service Interaction Management**: It orchestrates user inputs, Assistant responses, and interactions with FountainAI services.
- **Interaction Logging**: Logs every interaction, ensuring visibility into how the Assistant processes user queries and interacts with services.

### **2.2 Scope of the Service**
Designed for both **local deployment** (for testing and development) and **cloud-based operations**, the FountainAI Ensemble Service manages queries, processes responses, and coordinates dynamic service interactions. Its architecture allows for easy updates and evolution as new services are added.

---

## **3. Architecture and Design**

### **3.1 System Overview**
The FountainAI Ensemble Service acts as a middle layer between:
- **Users**: Who submit queries.
- **The Assistant (GPT model)**: Which processes user queries and generates responses.
- **FountainAI Services**: Which provide the data and operations needed for the Assistant to respond.

### **3.2 Key Components**
- **System Prompt Factory**: Combines OpenAPI definitions from multiple services into a single system prompt that guides the Assistant’s behavior.
- **FastAPI Application**: Provides endpoints for user queries, system prompt generation, and service interaction orchestration.
- **Logging System**: Captures detailed logs of each interaction between the user, Assistant, and services.

### **3.3 Dynamic Orchestration**
The system dynamically adapts by generating prompts based on which services are active and required during a session. This ensures the Assistant can interact with each service effectively based on their current OpenAPI definitions.

---

## **4. OpenAPI-First Approach**

The **OpenAPI-first approach** is central to the service’s design, ensuring each FountainAI service exposes its capabilities via OpenAPI specifications. These specifications are used to generate system prompts and guide the Assistant’s interactions with services.

### **4.1 OpenAPI Specification Overview**

Below is the **OpenAPI specification** for the **FountainAI Ensemble Service**:

```yaml
openapi: 3.0.0
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
        '400':
          description: Bad Request - Invalid service list
        '500':
          description: Internal Server Error

  /interact:
    post:
      summary: Handle user input and dynamically manage dialogue between the Assistant and services
      description: Handles user input, sends it to the Assistant, and manages service requests based on a dynamically generated system prompt.
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
        '400':
          description: Bad Request
        '500':
          description: Internal Server Error

  /logs:
    get:
      summary: Retrieve logs of system-prompt-driven interactions
      description: Logs past interactions, capturing key variables such as user input, Assistant responses, and service interactions.
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
```

---

## **5. Implementation Strategy**

The following steps detail the **implementation strategy** for deploying the **FountainAI Ensemble Service** using shell scripts to automate various components of the system.

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
```
Please write a shell script called `generate_prompt_factory.sh` that implements the System Prompt Factory in `/app/prompt_factory`. The script should:

1. Fetch OpenAPI definitions from FountainAI services.
2. Combine the OpenAPI definitions into a system prompt that guides the Assistant’s behavior.
```

### **Step 4: Schema Validation for Assistant and Service Interactions**

**Goal**: Create Pydantic schemas to validate the requests and responses between the Assistant and services.

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
3. Copy necessary

 app files and run the FastAPI app on port 8000.
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

This project workbook outlines the **FountainAI Ensemble Service** and its **OpenAPI-first design**. Through this detailed architecture and implementation strategy, the service ensures seamless interaction between the user, the Assistant, and the FountainAI services. The accompanying shell scripts allow for easy deployment and configuration, ensuring flexibility in both local and cloud environments.

