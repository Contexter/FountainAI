# FountainAI Project Report: Running FountainAI Locally and OpenAPI-First Approach

## Introduction

FountainAI is a modular, AI-driven system that integrates multiple microservices, facilitating complex interactions using OpenAPI-driven workflows. The objective of this project report is to outline the plan for **running FountainAI locally**, enabling efficient testing and development, while also ensuring dynamic adaptability through OpenAPI specifications and a flexible, GPT-powered assistant.

### Project Vision: Local Orchestration with Dynamic Interaction

The project envisions the development of a **Client FastAPI App** that will act as the **user interface** and **manager** of the local FountainAI system. At the core of this vision is an **OpenAPI-first development** approach, where interactions between the client app and FountainAI services are defined, generated, and updated dynamically based on OpenAPI specifications.

Additionally, the project integrates a **System Role Definition Factory** that dynamically generates the assistant’s system role based on the latest specifications, ensuring it remains accurate as FountainAI services evolve.

---

## Relevant Documentation

This project report draws on the following key documents, which address critical aspects of running FountainAI locally and ensuring dynamic adaptability:

### 1. **[Running FountainAI Locally: A Proposal for Reengineering Custom GPT Behavior](https://github.com/Contexter/FountainAI/blob/main/Project%20Report%20by%20Date/Proposal/Running%20FountainAI%20Locally_%20A%20Proposal%20for%20Reengineering%20Custom%20GPT%20Behavior.md)**

This document outlines the initial proposal for running FountainAI locally, focusing on:
- **OpenAI Assistant SDK**: Simulating the cloud-based GPT decision-making locally.
- **FastAPI Client**: Managing interactions between the assistant and FountainAI services for local testing and development.

### 2. **[Running FountainAI Locally: Reengineering the Custom GPT Configurator with OpenAI Assistant SDK](https://github.com/Contexter/FountainAI/blob/main/Workbooks/Running%20FountainAI%20Locally_%20Reengineering%20the%20Custom%20GPT%20Configurator%20with%20OpenAI%20Assistant%20SDK.md)**

This guide provides a step-by-step plan for implementing the FastAPI client and OpenAI Assistant SDK for local development, emphasizing:
- **API Requests**: Generating and managing API requests dynamically based on user inputs.
- **Dynamic Context Management**: Ensuring that the assistant has a real-time understanding of available services through OpenAPI specifications.

### 3. **[FountainAI System Role Prompting: Dynamic Integration with OpenAPI Specifications](https://github.com/Contexter/FountainAI/blob/main/Workbooks/FountainAI%20System%20Role%20Prompting_%20Dynamic%20Integration%20with%20OpenAPI%20Specifications.md)**

This document introduces the **System Role Definition Factory**, which dynamically generates system roles based on OpenAPI specifications. The key ideas include:
- **Dynamic Role Updates**: Ensuring the assistant's role remains up-to-date with the evolving service landscape.
- **Automatic Synchronization**: Automating the integration of new OpenAPI specifications into the assistant's system role.

---

## Client FastAPI App and OpenAPI-First Approach

### 1. **Client FastAPI App as the Central Interface**

The **Client FastAPI App** will act as the **central hub** for user interactions, managing the flow of data between the user, the OpenAI assistant, and the FountainAI services. Its key responsibilities include:
- **Handling User Requests**: Acting as the interface where users interact with FountainAI services through natural language queries.
- **Generating API Requests**: Dynamically creating and sending API requests based on the OpenAPI specifications.
- **Service Integration**: Managing real-time integration with FountainAI services, ensuring smooth interactions.

### 2. **OpenAPI-First Development**

Adopting an **OpenAPI-first** approach ensures that the system remains scalable and adaptable. The key benefits include:
- **Consistent API Definitions**: Each service in FountainAI is defined by its own OpenAPI specification, outlining operations, request parameters, and response formats.
- **Auto-Generation of Client Stubs**: The OpenAPI definitions are used to auto-generate client stubs for the FastAPI app, ensuring consistency with backend services.
- **Seamless Integration of New Services**: As new services are introduced or existing ones updated, the OpenAPI specifications ensure the system remains synchronized.

### 3. **System Role Definition Factory: Dynamic Role Management**

The **System Role Definition Factory** will dynamically generate the assistant’s system role based on the OpenAPI specifications. This ensures:
- **Adaptation to Changes**: The assistant remains updated with the current service landscape as APIs evolve.
- **Accurate Service Interactions**: The assistant can understand and interact with the most recent services offered by FountainAI.

---

## User Workflow

- **User Queries**: Users can make natural language requests (e.g., "Retrieve all actions in Scene 1"), which are interpreted by the assistant.
- **Assistant Processing**: The assistant, with dynamically generated roles, will understand the request and generate appropriate API calls.
- **Service Execution**: The FountainAI microservices execute the requested operation, and the results are returned to the user.

---

## Next Steps: From Vision to Implementation

The following steps will be guided by the **OpenAPI-first approach** and will be detailed in future development guides and scripts:

1. **Project Setup**: Define the project structure, configure the FastAPI framework, and integrate OpenAPI specifications.
2. **OpenAPI Specification for Each Service**: Ensure that each FountainAI service (e.g., Character Service, Action Service) has a detailed OpenAPI definition.
3. **Auto-Generated Client Stubs**: Use the OpenAPI specifications to generate client stubs.
4. **System Role Definition Factory**: Implement the dynamic generation of system roles based on the most recent OpenAPI specifications.

Following the structure laid out in the **[FountainAI FastAPI Guide](https://github.com/Contexter/FountainAI/blob/main/Workbooks/FountainAI%20FastAPI%20Guide.md)**, we will create a series of shell scripts and automation steps to streamline the development process.

---

This **project report** outlines the vision, objectives, and next steps for running FountainAI locally, utilizing an **OpenAPI-first** approach and dynamic role management.