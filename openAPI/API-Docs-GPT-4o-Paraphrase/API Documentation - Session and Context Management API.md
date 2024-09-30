### API Documentation - Session and Context Management API

### Overview

The Session and Context Management API is responsible for handling sessions and character contexts within a story. It ensures that each character's state and interactions are appropriately tracked, providing necessary contextual data for the story.

### Key Features

- **Session Management**: Create, retrieve, update, and delete sessions.
- **Context Management**: Create, retrieve, update, and delete context data for characters.
- **Sequence Integration**: Request sequence numbers from the Central Sequence Service to maintain the logical flow of sessions and context updates.

### Data Flow and Integration

The Session and Context Management API integrates with the Central Sequence Service to assign sequence numbers to sessions and context updates. This ensures that all elements follow a logical order within the story.

### Example of Usage

The following example JSON object shows how a session with its context is managed by the Session and Context Management API. Each element is assigned a sequence number to ensure a natural and logical reading flow.

```json
{
  "sessionId": 1,
  "characterId": 1,
  "contextData": {
    "mood": "longing",
    "location": "Capulet's mansion balcony"
  },
  "sequence": 1
}
```

### Session and Context Management API Specification

Below is the full OpenAPI specification for the Session and Context Management API, ensuring that all necessary information from the FountainAI APIs is integrated.

```yaml
openapi: 3.1.0
info:
  title: Session and Context Management API
  description: >
    This API manages the creation, retrieval, updating, and deletion of sessions and context data, ensuring logical order through sequence numbers.
  version: 1.0.0
servers:
  - url: https://sessioncontext.fountain.coach
    description: Production server for Session and Context Management API
  - url: http://localhost:8080
    description: Development server
paths:
  /sessions:
    post:
      summary: Create Session
      operationId: createSession
      description: Creates a new session for a character.
      requestBody:
        required: true
        description: Details of the session to be created.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SessionRequest'
            examples:
              example:
                value:
                  characterId: 1
                  contextData:
                    mood: "longing"
                    location: "Capulet's mansion balcony"
      responses:
        '201':
          description: Session successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SessionResponse'
              examples:
                example:
                  value:
                    sessionId: 1
                    sequence: 1
  /sessions/{sessionId}:
    get:
      summary: Retrieve Session
      operationId: getSession
      description: Retrieves details of a specific session.
      parameters:
        - name: sessionId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the session.
      responses:
        '200':
          description: Session details retrieved successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SessionResponse'
              examples:
                example:
                  value:
                    sessionId: 1
                    characterId: 1
                    contextData:
                      mood: "longing"
                      location: "Capulet's mansion balcony"
                    sequence: 1
        '404':
          description: Session not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                example:
                  value:
                    message: "Session not found."
  /sessions/{sessionId}:
    put:
      summary: Update Session
      operationId: updateSession
      description: Updates details of an existing session.
      parameters:
        - name: sessionId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the session.
      requestBody:
        required: true
        description: Updated details of the session.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SessionRequest'
            examples:
              example:
                value:
                  contextData:
                    mood: "happy"
                    location: "Capulet's mansion garden"
      responses:
        '200':
          description: Session updated successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SessionResponse'
              examples:
                example:
                  value:
                    sessionId: 1
                    sequence: 2
        '404':
          description: Session not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                example:
                  value:
                    message: "Session not found."
  /sessions/{sessionId}:
    delete:
      summary: Delete Session
      operationId: deleteSession
      description: Deletes a specific session.
      parameters:
        - name: sessionId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the session.
      responses:
        '200':
          description: Session deleted successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SuccessResponse'
              examples:
                example:
                  value:
                    message: "Session deleted successfully."
        '404':
          description: Session not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                example:
                  value:
                    message: "Session not found."
  /contexts:
    post:
      summary: Create Context
      operationId: createContext
      description: Creates new context data for a character.
      requestBody:
        required: true
        description: Details of the context data to be created.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ContextRequest'
            examples:
              example:
                value:
                  characterId: 1
                  contextData:
                    mood: "longing"
                    location: "Capulet's mansion balcony"
      responses:
        '201':
          description: Context data successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ContextResponse'
              examples:
                example:
                  value:
                    contextId: 1
                    sequence: 1
  /contexts/{contextId}:
    get:
      summary: Retrieve Context
      operationId: getContext
      description: Retrieves context data for a specific character.
      parameters:
        - name: contextId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the context data.
      responses:
        '200':
          description: Context data retrieved successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ContextResponse'
              examples:
                example:
                  value:
                    contextId: 1
                    characterId: 1
                    contextData:
                      mood: "longing"
                      location: "Capulet's mansion balcony"
                    sequence: 1
        '404':
          description: Context data not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                example:
                  value:
                    message: "Context data not found."
  /contexts/{contextId}:
    put:
      summary: Update Context
      operationId: updateContext
      description: Updates context data for a specific character.
      parameters:
        - name: contextId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the context data.
      requestBody:
        required: true
        description: Updated context data.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ContextRequest'
            examples:
              example:
                value:
                  contextData:
                    mood: "happy"
                    location: "Capulet's mansion garden"
      responses:
        '200':
          description: Context data updated successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ContextResponse'
              examples:
                example:
                  value:
                    contextId: 1
                    sequence: 2
        '404':
          description: Context data not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                example:
                  value:
                    message: "Context data not found."
  /contexts/{contextId}:
    delete:
      summary: Delete Context
      operationId: deleteContext
      description: Deletes context data for a specific character.
      parameters:
        - name: contextId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the context data.
      responses:
        '200':
          description: Context data deleted successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SuccessResponse'
              examples:
                example:
                  value:
                    message: "Context data deleted successfully."
        '404':
          description: Context data not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                example:
                  value:
                    message: "Context data not found."
components:
  schemas:
    SessionRequest:
      type: object
      properties:
        characterId:
          type: integer
          description: Unique identifier of the character.
        contextData:
          type: object
          description: Context data for the session.
      required: [characterId, contextData]
    SessionResponse:
      type: object
      properties:
        sessionId:
          type: integer
          description: Unique identifier of the session.
        characterId:
          type: integer
          description: Unique identifier of the character.
        contextData:
          type: object
          description: Context data for the session.
        sequence:
          type: integer
          description: Sequence number of the session.
    ContextRequest:
      type: object
      properties:
        characterId:
          type: integer
          description: Unique identifier of the character.
        contextData:
          type: object
          description: Context data for the character.
      required: [characterId, contextData]
    ContextResponse:
      type: object
      properties:
        contextId:
          type: integer
          description: Unique identifier of the context data.
        characterId:
          type: integer
          description: Unique identifier of the character.
        contextData:
          type: object
          description: Context data for the character.
        sequence:
          type: integer
          description: Sequence number of the context data.
    SuccessResponse:
      type: object
      properties:
        message:
          type: string
          description: Success message.
    Error:
      type: object
      properties:
        message:
          type: string
          description: Description of the error encountered.
```

### Detailed Breakdown: Step-by-Step Process

#### Initial Setup and Workflow

When the system is first set up, it will involve initializing each of the APIs and ensuring they are configured to communicate with the Central Sequence Service. Here's a step-by-step guide on how the system will work from the very beginning:

##### Step 1: Initialize Central Sequence Service

**Central Sequence Service** is the backbone of the entire system, responsible for generating and managing sequence numbers.

1. **Set Up the Service**: Deploy the Central Sequence Service and initialize it.
2. **Initialize Sequence Counter**: Start the sequence counter from 1 (or another starting point if specified).

##### Step 2: Set Up Core Script Management API

The **Core Script Management API** handles scripts, section headings, and transitions.

1. **Deploy the API**: Ensure the Core Script Management API is deployed and running.
2. **Connect to Central Sequence Service**: Configure the API to request sequence numbers from the Central Sequence Service.
3. **Create Initial Script**:
   - Use the API to create the first script, receiving a sequence number for the script itself.
   - Add section headings and transitions, each obtaining their sequence numbers from the Central Sequence Service.

##### Step 3: Set Up Character Management API

The **Character Management API** handles characters, their actions, and spoken words.

1. **Deploy the API**: Ensure the Character Management API is deployed and running.
2. **Connect to Central Sequence Service**: Configure the API to request sequence numbers from the Central Sequence Service.
3. **Create Initial Characters**:
   - Use the API to create the first characters, receiving sequence numbers for each.
   - Add actions and spoken words for each character, each obtaining their sequence numbers from the Central Sequence Service.

##### Step 4: Set Up Session and Context Management API

The **Session and Context Management API** manages sessions and character contexts.

1. **Deploy the API**: Ensure the Session and Context Management API is deployed and running.
2. **Connect to Central Sequence Service**: Configure the API to request sequence numbers from the Central Sequence Service.
3. **Create Initial Sessions and Contexts**:
   - Use the API to create initial sessions for characters, receiving sequence numbers for each session.
   - Add context data for characters, each context update receiving its sequence number from the Central Sequence Service.

##### Step 5: Set Up Story Factory API

The **Story Factory API** integrates data from the other APIs to assemble and manage the logical flow of stories.

1. **Deploy the API**: Ensure the Story Factory API is deployed and running.
2. **Connect to Other APIs**: Configure the API to fetch data from the Core Script Management API, Character Management API, and Session and Context Management API.
3. **Connect to Central Sequence Service**: Ensure the Story Factory API can retrieve sequence numbers from the Central Sequence Service.
4. **Assemble Stories**:
   - Fetch scripts, sections, characters, actions, spoken words, and contexts from the respective APIs.
   - Use the sequence numbers to assemble these elements into a coherent and logical story.

### Detailed Example of Initial Operations

#### Creating the First Session

1. **Request**: Create a new session for Juliet using the Session and Context Management API.
   - The API requests a sequence number from the Central Sequence Service.
2. **Response**: The session is created with sequence number 1.

#### Adding Context to the Session

1. **Request**: Add context data "longing" and "Capulet's mansion balcony" for Juliet.
   - The API requests a sequence number from the Central Sequence Service.
2. **Response**: The context is added with sequence number 2.

#### Retrieving a Session

1. **Request**: Retrieve details of a specific session using the Session and Context Management API.
   - The API fetches the session and its associated sequence number.
2. **Response**: The session details are retrieved successfully.

#### Updating a Session

1. **Request**: Update context data for a session using the Session and Context Management API.
   - The API requests a new sequence number from the Central Sequence Service.
2. **Response**: The session is updated with a new sequence number.

### Conclusion

By following these steps, the system ensures that every element within the story is assigned a unique sequence number, maintaining a consistent and logical flow. The Central Sequence Service acts as the backbone, providing a centralized mechanism to generate and manage sequence numbers, ensuring all APIs work harmoniously to create a cohesive narrative.

If you start from somewhere else, such as creating context data or a session, the system will still function seamlessly. Here’s how it works:

### Creating a Context First

1. **Request**: Create a session for Juliet using the Session and Context Management API.
   - **Sequence Request**: The API requests a sequence number from the Central Sequence Service.
2. **Response**: The session is created with sequence number 1.

3. **Next Step**: Add context data for the session.
   - **Request**: Add context data "longing" and "Capulet's mansion balcony" for Juliet.
     - **Sequence Request**: The API requests a sequence number from the Central Sequence Service.
   - **Response**: The context is added with sequence number 2.

### Example Scenario: Adding Elements in a Non-linear Order

#### Step 1: Create a Session

1. **Request**: Create a session for Romeo.
   - **Sequence Request**: The Session and Context Management API requests a sequence number from the Central Sequence Service.
2. **Response**: Session for "Romeo" is created with sequence number 1.

#### Step 2: Add Context Data

1. **Request**: Add context data "Capulet's garden at night" for Romeo.
   - **Sequence Request**: The Session and Context Management API requests a sequence number from the Central Sequence Service.
2. **Response**: Context data is added with sequence number 2.

### Logical Reading Flow

No matter the order in which elements are created, each element is assigned a sequence number by the Central Sequence Service, ensuring a logical reading flow when the story is assembled. The Story Factory API will gather these elements, sort them by their sequence numbers, and present them in the intended order.

### Conclusion

The Central Sequence Service ensures that all elements, regardless of the order in which they are created, are given unique and sequential numbers. This guarantees a coherent and logical narrative flow when assembled by the Story Factory API, maintaining the integrity and readability of the story.