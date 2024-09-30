# FountainAI System Description

---

## **Overview**

**FountainAI** is a modular system designed to manage story elements such as scripts, characters, actions, spoken words, sessions, context, and the logical flow of stories. It comprises several microservices, each responsible for specific functionalities, and integrates them to provide a cohesive platform for story creation and management. The system leverages Kong API Gateway for request routing, authentication, and other API management features, and uses PostgreSQL as a unified persistence backend. All components are orchestrated using Docker Compose for easy deployment and scalability.

---

## **Table of Contents**

1. [System Architecture](#system-architecture)
2. [Requirements](#requirements)
   - [Functional Requirements](#functional-requirements)
   - [Non-Functional Requirements](#non-functional-requirements)
3. [Microservices](#microservices)
   - [Central Sequence Service API](#central-sequence-service-api)
   - [Character Management API](#character-management-api)
   - [Core Script Management API](#core-script-management-api)
   - [Session and Context Management API](#session-and-context-management-api)
   - [Story Factory API](#story-factory-api)
4. [Unified Persistence Backend](#unified-persistence-backend)
   - [Database Schema](#database-schema)
   - [Database Migrations](#database-migrations)
5. [Docker Compose Setup](#docker-compose-setup)
   - [Services](#services)
   - [Docker Compose File](#docker-compose-file)
6. [Kong API Gateway Integration](#kong-api-gateway-integration)
   - [Service and Route Configuration](#service-and-route-configuration)
   - [Authentication and Plugins](#authentication-and-plugins)
7. [Client Interaction](#client-interaction)
   - [GPT Model Clients](#gpt-model-clients)
   - [Developer Access](#developer-access)
8. [Security Considerations](#security-considerations)
9. [Monitoring and Maintenance](#monitoring-and-maintenance)
10. [Conclusion](#conclusion)

---

## **System Architecture**

The FountainAI system comprises the following components:

- **Microservices**: Five FastAPI applications, each handling specific aspects of story management:
  - **Central Sequence Service API**
  - **Character Management API**
  - **Core Script Management API**
  - **Session and Context Management API**
  - **Story Factory API**
- **PostgreSQL Database**: A unified persistence backend shared by all microservices.
- **Kong API Gateway**: Acts as a reverse proxy, routing client requests to the appropriate services and providing API management features.
- **Clients**: Primarily GPT models consuming the APIs, and developers accessing the OpenAPI documentation for testing purposes.
- **Docker Compose**: Orchestrates all components, ensuring seamless deployment and networking.

---

## **Requirements**

### **Functional Requirements**

1. **Microservices**: Each microservice provides RESTful APIs for managing specific story elements.
2. **OpenAPI Specifications**: Each microservice must expose an OpenAPI specification that exactly matches predefined schemas for input and output.
3. **Data Persistence**: Use a unified PostgreSQL database for storing all data, ensuring consistency and reliability.
4. **API Gateway Integration**: Utilize Kong API Gateway to:
   - Route requests to the appropriate microservices.
   - Provide authentication mechanisms.
   - Implement rate limiting and caching as needed.
5. **Client Support**:
   - Allow GPT models to interact with the APIs seamlessly.
   - Provide developers with access to OpenAPI documentation for testing and development.

### **Non-Functional Requirements**

1. **Scalability**: The system should handle increasing load by scaling microservices and database connections.
2. **Security**:
   - Implement authentication and authorization mechanisms.
   - Secure communication between all components.
3. **Reliability**: Ensure high availability and fault tolerance, with minimal downtime.
4. **Maintainability**: The system should be easy to maintain, update, and extend.
5. **Performance**: Optimize for low latency and high throughput, suitable for real-time interactions with GPT models.

---

## **Microservices**

### **1. Central Sequence Service API**

- **Version**: 1.0.0
- **Description**: Manages the assignment and updating of sequence numbers for various elements within a story, ensuring logical order and consistency.
- **Servers**:
  - Production: `https://centralsequence.fountain.coach`
  - Development: `http://localhost:8080`

#### **Key Endpoints**

1. **`POST /sequence`**
   - **Summary**: Generate Sequence Number
   - **OperationId**: `generateSequenceNumber`
   - **Description**: Generates a new sequence number for a specified element type.
   - **Request Body**: `SequenceRequest` (elementType, elementId)
   - **Response**: `SequenceResponse` (sequenceNumber)

2. **`POST /sequence/reorder`**
   - **Summary**: Reorder Elements
   - **OperationId**: `reorderElements`
   - **Description**: Reorders elements by updating their sequence numbers.
   - **Request Body**: `ReorderRequest` (elementType, elements)
   - **Response**: `SuccessResponse` (message)

3. **`POST /sequence/version`**
   - **Summary**: Create New Version
   - **OperationId**: `createVersion`
   - **Description**: Creates a new version of an element.
   - **Request Body**: `VersionRequest` (elementType, elementId, newVersionData)
   - **Response**: `VersionResponse` (versionNumber)

### **2. Character Management API**

- **Version**: 1.0.0
- **Description**: Handles characters within stories, including their creation, management, actions, and spoken words. Integrates with the Central Sequence Service to ensure logical sequence numbers.
- **Servers**:
  - Production: `https://character.fountain.coach`
  - Development: `http://localhost:8080`

#### **Key Endpoints**

1. **`GET /characters`**
   - **Summary**: Retrieve All Characters
   - **OperationId**: `listCharacters`
   - **Description**: Lists all characters stored within the application.
   - **Response**: List of `Character` entities.

2. **`POST /characters`**
   - **Summary**: Create a New Character
   - **OperationId**: `createCharacter`
   - **Description**: Allows for the creation of a new character.
   - **Request Body**: `CharacterCreateRequest` (name, description)
   - **Response**: `Character` entity.

3. **`GET /characters/{characterId}/paraphrases`**
   - **Summary**: Retrieve All Paraphrases for a Character
   - **OperationId**: `listCharacterParaphrases`
   - **Description**: Retrieves all paraphrases linked to a specific character.
   - **Parameters**: `characterId`
   - **Response**: List of `Paraphrase` entities.

4. **`POST /characters/{characterId}/paraphrases`**
   - **Summary**: Create a New Paraphrase for a Character
   - **OperationId**: `createCharacterParaphrase`
   - **Description**: Allows for the creation of a new paraphrase linked to a character.
   - **Parameters**: `characterId`
   - **Request Body**: `ParaphraseCreateRequest`
   - **Response**: `Paraphrase` entity.

5. **`GET /actions`**
   - **Summary**: Retrieve All Actions
   - **OperationId**: `listActions`
   - **Description**: Lists all actions currently stored within the system.
   - **Response**: List of `Action` entities.

6. **`POST /actions`**
   - **Summary**: Create a New Action
   - **OperationId**: `createAction`
   - **Description**: Allows for the creation of a new action entity.
   - **Request Body**: `ActionCreateRequest` (description)
   - **Response**: `Action` entity.

7. **`GET /actions/{actionId}/paraphrases`**
   - **Summary**: Retrieve All Paraphrases for an Action
   - **OperationId**: `listActionParaphrases`
   - **Description**: Retrieves all paraphrases linked to a specific action.
   - **Parameters**: `actionId`
   - **Response**: List of `Paraphrase` entities.

8. **`POST /actions/{actionId}/paraphrases`**
   - **Summary**: Create a New Paraphrase for an Action
   - **OperationId**: `createActionParaphrase`
   - **Description**: Allows for the creation of a new paraphrase linked to an action.
   - **Parameters**: `actionId`
   - **Request Body**: `ParaphraseCreateRequest`
   - **Response**: `Paraphrase` entity.

9. **`GET /spokenWords`**
   - **Summary**: Retrieve All Spoken Words
   - **OperationId**: `listSpokenWords`
   - **Description**: Lists all spoken words currently stored within the system.
   - **Response**: List of `SpokenWord` entities.

10. **`POST /spokenWords`**
    - **Summary**: Create a New Spoken Word
    - **OperationId**: `createSpokenWord`
    - **Description**: Allows for the creation of a new spoken word entity.
    - **Request Body**: `SpokenWordCreateRequest` (text)
    - **Response**: `SpokenWord` entity.

11. **`GET /spokenWords/{spokenWordId}/paraphrases`**
    - **Summary**: Retrieve All Paraphrases for a Spoken Word
    - **OperationId**: `listSpokenWordParaphrases`
    - **Description**: Retrieves all paraphrases linked to a specific spoken word.
    - **Parameters**: `spokenWordId`
    - **Response**: List of `Paraphrase` entities.

12. **`POST /spokenWords/{spokenWordId}/paraphrases`**
    - **Summary**: Create a New Paraphrase for a Spoken Word
    - **OperationId**: `createSpokenWordParaphrase`
    - **Description**: Allows for the creation of a new paraphrase linked to a spoken word.
    - **Parameters**: `spokenWordId`
    - **Request Body**: `ParaphraseCreateRequest`
    - **Response**: `Paraphrase` entity.

### **3. Core Script Management API**

- **Version**: 2.0.0
- **Description**: Manages scripts, section headings, and transitions. Integrates with the Central Sequence Service for logical ordering and supports reordering and versioning.
- **Servers**:
  - Production: `https://scriptmanagement.fountain.coach`
  - Development: `http://localhost:8080`

#### **Key Endpoints**

1. **`POST /scripts`**
   - **Summary**: Create Script
   - **OperationId**: `createScript`
   - **Description**: Creates a new script, obtaining a sequence number from the Central Sequence Service.
   - **Request Body**: `ScriptRequest` (title, author, description)
   - **Response**: `ScriptResponse` (scriptId, sequenceNumber)

2. **`GET /scripts`**
   - **Summary**: List Scripts
   - **OperationId**: `listScripts`
   - **Description**: Retrieves all scripts.
   - **Response**: List of `Script` entities.

3. **`PUT /scripts/{scriptId}`**
   - **Summary**: Update Script
   - **OperationId**: `updateScript`
   - **Description**: Updates an existing script.
   - **Parameters**: `scriptId`
   - **Request Body**: `ScriptUpdateRequest` (title, author, description)
   - **Response**: `ScriptResponse`

4. **`POST /scripts/{scriptId}/sections`**
   - **Summary**: Add Section Heading
   - **OperationId**: `addSectionHeading`
   - **Description**: Adds a new section heading to a script, obtaining a sequence number from the Central Sequence Service.
   - **Parameters**: `scriptId`
   - **Request Body**: `SectionHeadingRequest` (title)
   - **Response**: `SectionHeadingResponse`

5. **`PUT /scripts/{scriptId}/sections`**
   - **Summary**: Update Section Heading
   - **OperationId**: `updateSectionHeading`
   - **Description**: Updates an existing section heading.
   - **Parameters**: `scriptId`, `headingId`
   - **Request Body**: `SectionHeadingUpdateRequest` (title)
   - **Response**: `SectionHeadingResponse`

6. **`POST /scripts/{scriptId}/sections/reorder`**
   - **Summary**: Reorder Section Headings
   - **OperationId**: `reorderSectionHeadings`
   - **Description**: Reorders section headings within a script by updating their sequence numbers.
   - **Parameters**: `scriptId`
   - **Request Body**: `ReorderRequest` (elements)
   - **Response**: `SuccessResponse` (message)

### **4. Session and Context Management API**

- **Version**: 2.0.0
- **Description**: Manages sessions and context, allowing for the creation, updating, and retrieval of session-specific data.
- **Servers**:
  - Production: `https://sessioncontext.fountain.coach`
  - Development: `http://localhost:8080`

#### **Key Endpoints**

1. **`POST /sessions`**
   - **Summary**: Create Session
   - **OperationId**: `createSession`
   - **Description**: Creates a new session.
   - **Request Body**: `SessionRequest` (userId, context)
   - **Response**: `SessionResponse` (sessionId, userId, context)

2. **`GET /sessions`**
   - **Summary**: List Sessions
   - **OperationId**: `listSessions`
   - **Description**: Retrieves all sessions.
   - **Response**: List of `Session` entities.

3. **`PUT /sessions/{sessionId}`**
   - **Summary**: Update Session
   - **OperationId**: `updateSession`
   - **Description**: Updates an existing session.
   - **Parameters**: `sessionId`
   - **Request Body**: `SessionUpdateRequest` (context)
   - **Response**: `SessionResponse`

4. **`GET /sessions/{sessionId}/context`**
   - **Summary**: Get Session Context
   - **OperationId**: `getSessionContext`
   - **Description**: Retrieves the context of a specific session.
   - **Parameters**: `sessionId`
   - **Response**: `SessionContextResponse` (sessionId, context)

### **5. Story Factory API**

- **Version**: 1.0.0
- **Description**: Integrates data from the Core Script Management API, Character Management API, and Session and Context Management API to assemble and manage the logical flow of stories.
- **Servers**:
  - Production: `https://storyfactory.fountain.coach`
  - Development: `http://localhost:8080`

#### **Key Endpoints**

1. **`GET /stories`**
   - **Summary**: Retrieve Full Story
   - **OperationId**: `getFullStory`
   - **Description**: Fetches a complete story, including sections, characters, actions, spoken words, context, and transitions.
   - **Parameters**: `scriptId` (query, required)
   - **Response**: `FullStory`

2. **`GET /stories/sequences`**
   - **Summary**: Retrieve Story Sequences
   - **OperationId**: `getStorySequences`
   - **Description**: Retrieves specific sequences from a story, ensuring a logical flow.
   - **Parameters**: `scriptId`, `startSequence`, `endSequence` (query, required)
   - **Response**: `StorySequence`

---

## **Unified Persistence Backend**

### **Database Schema**

The PostgreSQL database includes tables corresponding to each element managed by the microservices:

- **scripts**
- **section_headings**
- **characters**
- **actions**
- **spoken_words**
- **paraphrases**
- **sessions**
- **contexts**
- **sequence_numbers**

### **Database Migrations**

Use **Alembic** to manage database migrations:

- **Initial Migration**: Create the initial database schema.
- **Schema Updates**: Apply changes to the database schema in a controlled manner.
- **Version Control**: Keep track of schema versions and changes over time.

---

## **Docker Compose Setup**

### **Services**

1. **PostgreSQL Database**: Provides data persistence for all microservices.
2. **Kong API Gateway**: Handles request routing and API management.
3. **Microservices**: Each microservice is a separate service in Docker Compose.

### **Docker Compose File**

An example `docker-compose.yml` file includes:

- **postgres**: The PostgreSQL database service.
- **kong-db**, **kong-migrations**, **kong**: Services for Kong API Gateway.
- **microservices**: Individual services for each microservice (e.g., `central-sequence-service`, `character-management`, `script-management`, `session-context-management`, `story-factory`).

---

## **Kong API Gateway Integration**

### **Service and Route Configuration**

For each microservice:

1. **Create a Service**:

   ```bash
   curl -i -X POST http://localhost:8001/services/ \
     --data 'name=service-name' \
     --data 'url=http://service-host:port'
   ```

2. **Create a Route**:

   ```bash
   curl -i -X POST http://localhost:8001/services/service-name/routes \
     --data 'paths[]=/api/v1/service-path'
   ```

### **Authentication and Plugins**

- **API Key Authentication**: Implemented using Kong's key-auth plugin.
- **Rate Limiting**: Configured per service based on client needs.
- **Caching**: Optional, enabled via Kong's proxy-cache plugin.

---

## **Client Interaction**

### **GPT Model Clients**

- **API Consumption**: GPT models interact with the APIs programmatically.
- **Authentication**: Include the API key in the `apikey` header of each request.
- **Endpoint Access**: Use the Kong-provided URLs.

### **Developer Access**

- **OpenAPI Documentation**: Accessible via the microservices for testing and development.
- **Testing Endpoints**: Developers can send requests through Kong to simulate the production environment.

---

## **Security Considerations**

- **Secure Communications**:
  - Use HTTPS for all client-to-Kong and Kong-to-microservices communications.
- **Authentication**:
  - Use API key authentication for clients.
  - Manage API keys securely.
- **Database Security**:
  - Use strong passwords and restrict network access.
- **Network Security**:
  - Use Docker networks to isolate services.
  - Implement firewall rules as necessary.

---

## **Monitoring and Maintenance**

- **Logging**:
  - Kong and microservices should log requests and errors.
- **Monitoring**:
  - Monitor system performance using Prometheus and Grafana.
- **Backups**:
  - Regularly back up the PostgreSQL database.
- **Scaling**:
  - Scale microservices horizontally as needed.

---

## **Conclusion**

FountainAI is a comprehensive system designed to manage screenplay elements effectively, integrating multiple microservices to provide precise API specifications for seamless client interactions, primarily with GPT models. By leveraging FastAPI, PostgreSQL, Kong API Gateway, and Docker Compose, the system ensures high performance, scalability, and maintainability. The unified persistence backend facilitates data consistency across all services, while Kong provides essential API management features.
