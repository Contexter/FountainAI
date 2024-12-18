# FountainAI Microservices Implementation Guide

This document serves as a central, high-level development resource for implementing all ten microservices of the FountainAI platform. It synthesizes best practices from transitioning from OpenAPI-driven design-time specifications to fully realized, database-backed runtime applications. By following this guide, teams can maintain a consistent workflow, ensure reliable runtime sources of truth, and integrate advanced features like search indexing through services like Typesense.

## Table of Contents

1. Introduction  
2. Common Architecture & Tooling  
3. From OpenAPI Spec to Generated Code  
4. Database Modeling and Migrations  
5. Implementing Handlers  
6. Validation and Error Handling  
7. Integrating Typesense for Enhanced Search  
8. Testing and Verification  
9. Schema Evolution and Synchronization  
10. Deployment and Runtime Considerations  
11. Conclusion and Next Steps  
12. Implementation Examples with Prompt-Driven Development  
    - 12.1 Example: Core Script Management Service  
    - 12.2 Example: Central Sequence Service

---

## 1. Introduction

The FountainAI platform comprises ten interconnected microservices, each designed to serve a distinct role within the larger narrative and story management ecosystem. Each microservice begins its life as an OpenAPI specification, defining endpoints, request/response schemas, security, and error conditions. The steps detailed here apply to all services, ensuring a uniform, reproducible development cycle:

- **Design-Time Source of Truth**: The OpenAPI document ensures all team members understand the intended API contract.
- **Runtime Source of Truth**: A robust SQL database (SQLite in development, Postgres or MySQL in production) backed by Fluent ensures data consistency and scalability.

By building each microservice this way, FountainAI achieves maintainability, reliability, and smooth integration across its suite of services.

---

## 2. Common Architecture & Tooling

The shared technology stack for all FountainAI microservices includes:

- **OpenAPI**: Defines the API contract.
- **Apple OpenAPI Generator**: Auto-generates `Types.swift` (models), `Server.swift` (stubs and interfaces), and `Client.swift` (consumers) directly from the OpenAPI spec.
- **Vapor**: A Swift-based web framework providing routing, middleware, and request handling.
- **Fluent & SQLite**: Fluent serves as an ORM; SQLite is convenient for development. For production, use a more scalable SQL database.
- **Typesense** (Optional): Offers advanced search capabilities over indexed data.

This uniform stack streamlines development across all services, enabling developers to share knowledge, patterns, and best practices.

---

## 3. From OpenAPI Spec to Generated Code

**Workflow**:  
1. **Author the OpenAPI Spec**: Carefully define endpoints, parameters, request/response bodies, and errors.  
2. **Build the Project**: Running `swift build` triggers the OpenAPI Generator plugin, yielding up-to-date `Types.swift`, `Server.swift`, and `Client.swift` files.  
3. **Inspect and Integrate**: Review the generated models in `Types.swift`, the server-side protocols in `Server.swift`, and the optional `Client.swift`. These files form the scaffold on which the microservice logic will be built.

As the spec evolves, simply rebuild to synchronize generated code with the updated API contract.

---

## 4. Database Modeling and Migrations

**From Types to Tables**:
- Translate `Types.swift` models into Fluent `Model` structs.  
- Each schema (e.g., `Script`, `Section`, `Sequence`) corresponds to a database table, with each property mapped to a column.
- Create `Migration` structs to apply changes to the database schema. As the schema evolves, add new migrations to ensure the runtime state matches the OpenAPI definition.

**Example**:  
If `Types.swift` defines a `Script` with `scriptId`, `title`, `author`, and `sections`, create a `Script` Fluent model, map columns, and write a `CreateScript` migration. Use similar steps for `Section`.

---

## 5. Implementing Handlers

The `Server.swift` file provides operation stubs. To implement a handler:

1. **Decode Inputs**: Extract query parameters, path parameters, and request bodies as defined by the OpenAPI spec.
2. **Database Interaction**: Use Fluent to fetch, insert, update, or delete records.
3. **Transform Results**: Convert Fluent model instances into `Types.swift` response objects.
4. **Return Responses**: Match the spec’s responses (e.g., `200 OK`, `201 Created`, `404 Not Found`) and return appropriate data types or error objects.

This ensures that each endpoint precisely follows the contract defined in the OpenAPI document.

---

## 6. Validation and Error Handling

Validation is essential for robust APIs:

- **Validate Required Fields**: Ensure required input fields are present and correctly formatted.
- **Return Structured Errors**: On invalid input, respond with `400 Bad Request` and a `StandardError` schema to detail what went wrong.
- **Graceful Degradation**: For unexpected server errors, return `500 Internal Server Error` with a `StandardError`.

This approach makes the service predictable, user-friendly, and easier to integrate with other FountainAI microservices.

---

## 7. Integrating Typesense for Enhanced Search

For microservices requiring advanced search capabilities:

1. **Indexing**: After creating or updating records, index relevant fields into Typesense.  
2. **Querying**: Use Typesense queries in filtering and searching endpoints.  
3. **Error Handling**: If Typesense is unavailable, handle gracefully and return fallback responses from the primary database or a suitable error response.

This hybrid approach (SQL + Typesense) ensures reliable authoritative storage and rich search functionality.

---

## 8. Testing and Verification

**Testing Strategy**:
- Use Vapor’s test environment to initialize the app, run migrations, and perform requests.
- Write tests for both success paths and error conditions.
- Verify that the responses adhere to the OpenAPI spec, ensuring contract compliance and preventing regressions.

By extensively testing each microservice, you ensure high quality and maintain trust between the services and their consumers.

---

## 9. Schema Evolution and Synchronization

Requirements change, and so will schemas:

1. **Spec Updates**: Modify the OpenAPI spec as needed.
2. **Code Regeneration**: Re-run `swift build` to sync `Types.swift` and `Server.swift`.
3. **Migrations**: Add or update migrations to reflect new database fields or tables.
4. **Backward Compatibility**: In production, handle migrations carefully to avoid breaking existing clients.

This iterative loop keeps your microservices current and reliable over time.

---

## 10. Deployment and Runtime Considerations

When moving from local SQLite to production environments:

- **Database Upgrades**: Switch to Postgres or another robust SQL database.
- **Configuration**: Use environment variables for database URLs, authentication tokens, and Typesense endpoints.
- **Run Migrations in Production**: Ensure deployment pipelines apply schema migrations before starting the service.
- **Monitoring and Logging**: Add metrics, logs, and error monitoring to detect issues early.

Such measures provide the resilience and scalability needed for a mature, production-grade microservice ecosystem.

---

## 11. Conclusion and Next Steps

This guide outlines how to create and maintain FountainAI microservices from an OpenAPI spec to a fully integrated, database-driven, tested, and production-ready service. By adhering to these practices across all ten FountainAI microservices, developers can ensure consistency, maintainability, and high quality.

Next steps include refining integration patterns, enhancing Typesense usage for richer search capabilities, and iterating on the schema and code as requirements evolve.

---

## 12. Implementation Examples with Prompt-Driven Development

Below are two illustrative examples demonstrating the prompt-driven development approach. These examples show how to use structured prompts to guide the transition from OpenAPI specs to fully implemented microservices, ensuring production-ready code quality, validations, error handling, and testing.

### 12.1 Example: Core Script Management Service

**Scenario**: We have an OpenAPI specification for a "Core Script Management API" that retrieves and manages scripts with associated sections.

**Prompts**:

1. *High-Level Roadmap*  
   "We’ve generated `Server.swift`, `Types.swift`, and `Client.swift` from the Core Script Management API OpenAPI specification. We have Vapor, Fluent, and SQLite integrated. Outline the high-level steps to turn these generated files into a fully functioning server that stores scripts and sections, including setting up Fluent models, running migrations, implementing handlers, and integrating with Typesense."

2. *Deriving the Schema from `Types.swift`*  
   "From `Types.swift`, we see `Script` and `Section` schemas. Show how to create Fluent `Model`s `Script` and `Section` with corresponding tables (`scripts`, `sections`), including fields for `scriptId`, `title`, `author`, `comment` in `Script`, and `sectionId`, `title`, plus a foreign key referencing `Script` in `Section`. Provide the models and `Migration` code."

3. *Implementing the `listScripts` Handler*  
   "In `Server.swift`, the `listScripts` operation retrieves scripts filtered by `author`, `title`, `characterId`, `actionId`, and `sectionTitle`, and optionally sorts them. Implement this handler using Fluent queries, applying filters and sorting, and return an array of `Script` objects. Show how to handle invalid query parameters by returning a `400 Bad Request` with a `StandardError`."

4. *Creating and Updating Scripts via Database*  
   "Implement the `createScript` handler to insert a new `Script` and its `sections` into the database, returning `201 Created` with a `ScriptResponse`. Similarly, implement `updateScript` to modify an existing `Script` and its sections, returning `404` if not found, `400` for invalid input, and `500` for unforeseen errors."

5. *Retrieving a Script by ID*  
   "Implement the `getScriptById` handler to load a `Script` and its `sections` by `scriptId`. If not found, return `404 Not Found`. If an unexpected database error occurs, return `500 Internal Server Error`. Show the code and explain the loading of related `sections`."

6. *Data Validation and Error Handling*  
   "Add validation logic in `createScript` and `updateScript` to ensure `title`, `author`, `sections`, and `comment` are present. If validation fails, return `400 Bad Request` with `StandardError`. Also show how to handle invalid foreign keys or unexpected database states, returning `500 Internal Server Error` appropriately."

7. *Integrating Typesense*  
   "Demonstrate how to index scripts into Typesense after creation or update. Show code snippets for calling the Typesense client, handling indexing failures gracefully, and returning a fallback response or error if Typesense is down."

8. *Testing the Endpoints*  
   "Write Vapor tests that verify `listScripts`, `createScript`, and `getScriptById`. Show a test setup that runs migrations, sends requests, and checks the responses. Verify both success cases and error paths to ensure comprehensive coverage."

9. *Evolving the Schema*  
   "If we add `tags: [String]` to `Script`, show how to update the OpenAPI spec, re-run generation, and add a new migration and model property for `tags`. Explain how to remain backward compatible with existing data and how to test this change."

10. *Deployment Considerations*  
    "Discuss switching from SQLite to Postgres, using environment variables for configuration, and running migrations in production. Explain logging, monitoring, and migration versioning to ensure robust production deployments."

### 12.2 Example: Central Sequence Service

**Scenario**: The "Central Sequence Service" uses an OpenAPI spec to define operations that create or update sequences with incrementing numbers.

**Prompts**:

1. *High-Level Steps*  
   "Having generated `Server.swift`, `Types.swift`, and `Client.swift` for the Central Sequence Service, outline how to set up Fluent `Sequence` models and a `CreateSequence` migration, implement `generateSequenceNumber` to handle database-based sequence increments, and validate input."

2. *Deriving the Database Schema*  
   "Given `SequenceResponse` with `elementId: Int` and `sequenceNumber: Int`, create a Fluent `Sequence` model and a migration `CreateSequence` that produces a `sequences` table with these fields. Show the code and explain each step."

3. *Connecting Handlers to the Database*  
   "Implement the `generateSequenceNumber` handler so it checks if a `Sequence` record exists for a given `elementId`. If yes, increment `sequenceNumber` and save. If no, insert a new record starting with `sequenceNumber = 1`. Return a `201 Created` with the updated sequence. Handle database errors and return `500` if needed."

4. *Validation and Error Handling*  
   "Ensure `elementId` is valid in requests. If it's missing or not an integer, return `400 Bad Request` with a `StandardError`. Handle unexpected database conditions by returning `500 Internal Server Error`. Show updated handler code."

5. *Testing the Handler*  
   "Write a Vapor test case that sets up the app, runs the migrations, and calls `POST /generateSequenceNumber` twice with the same `elementId`. Verify the first returns `201 Created` with `sequenceNumber = 1` and the second returns `201 Created` with `sequenceNumber = 2`. Test invalid input and confirm `400 Bad Request` is returned."

6. *Schema Updates and Sync*  
   "If we add `timestamp` to the `Sequence` schema, update the OpenAPI spec, regenerate code, add a Fluent migration to add a `timestamp` field, and update the handler logic accordingly. Show how to remain in sync as the schema evolves."

7. *Deployment and Production Readiness*  
   "Discuss environment-specific configurations, switching from SQLite to a more scalable database, and running migrations in production. Explain how to ensure logging, error monitoring, and scaling strategies are in place."

---

By following these implementation examples and prompts, developers working on any of the FountainAI microservices can systematically approach their tasks. The prompts ensure that each service moves from a clear specification to a robust, tested, and production-ready microservice that aligns with the overall architectural vision of FountainAI.
