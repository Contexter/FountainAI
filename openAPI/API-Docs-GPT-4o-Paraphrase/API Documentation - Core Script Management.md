### Core Script Management API Documentation

### Overview

The Core Script Management API is responsible for managing scripts, section headings, and transitions. It integrates with the Central Sequence Service to ensure that all elements follow a logical order and supports reordering and versioning.

### Key Features

- **Script Management**: Create, update, and list scripts.
- **Section Headings**: Add, update, and reorder section headings within scripts.
- **Transitions**: Manage transitions between sections.
- **Integration with Central Sequence Service**: Ensures logical order and version control of elements.
- **Reordering**: Allows changing the order of elements within a script.
- **Versioning**: Maintains a history of modifications to elements.

### Data Flow and Integration

The Core Script Management API requests sequence numbers from the Central Sequence Service when creating or updating elements. This integration ensures that all elements have unique and sequential numbers, maintaining a logical flow within the story.

### Example of Usage

The following example shows how the Core Script Management API interacts with the Central Sequence Service to create a script and add section headings.

```json
{
  "scriptId": 1,
  "title": "Romeo and Juliet",
  "author": "William Shakespeare",
  "description": "A tale of two star-crossed lovers.",
  "sections": [
    {
      "headingId": 1,
      "scriptId": 1,
      "title": "Act 1, Scene 1",
      "sequence": 1
    }
  ]
}
```

### Core Script Management API Specification

Below is the full OpenAPI specification for the Core Script Management API, ensuring that it integrates with the Central Sequence Service.

```yaml
openapi: 3.1.0
info:
  title: FountainAI Core Script Management API
  description: >
    This API manages scripts, section headings, and transitions. It integrates with the Central Sequence Service to ensure all elements follow a logical order and supports reordering and versioning.
  version: 2.0.0
servers:
  - url: https://scriptmanagement.fountain.coach
    description: Production server for Core Script Management API
  - url: http://localhost:8080
    description: Development server
paths:
  /scripts:
    post:
      summary: Create Script
      operationId: createScript
      description: Creates a new script, obtaining a sequence number from the Central Sequence Service.
      requestBody:
        required: true
        description: Details of the script to be created.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ScriptRequest'
            examples:
              example:
                value:
                  title: "Romeo and Juliet"
                  author: "William Shakespeare"
                  description: "A tale of two star-crossed lovers."
      responses:
        '201':
          description: Script created successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ScriptResponse'
              examples:
                example:
                  value:
                    scriptId: 1
                    sequenceNumber: 1
    get:
      summary: List Scripts
      operationId: listScripts
      description: Retrieves all scripts.
      responses:
        '200':
          description: List of scripts.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Script'
  /scripts/{scriptId}:
    put:
      summary: Update Script
      operationId: updateScript
      description: Updates an existing script.
      parameters:
        - name: scriptId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the script to update.
      requestBody:
        required: true
        description: Details of the script to be updated.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ScriptUpdateRequest'
            examples:
              example:
                value:
                  title: "Romeo and Juliet - Updated"
                  author: "William Shakespeare"
                  description: "An updated tale of two star-crossed lovers."
      responses:
        '200':
          description: Script updated successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ScriptResponse'
              examples:
                example:
                  value:
                    scriptId: 1
                    sequenceNumber: 1
  /scripts/{scriptId}/sections:
    post:
      summary: Add Section Heading
      operationId: addSectionHeading
      description: Adds a new section heading to a script, obtaining a sequence number from the Central Sequence Service.
      parameters:
        - name: scriptId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the script to add the section heading to.
      requestBody:
        required: true
        description: Details of the section heading to be added.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SectionHeadingRequest'
            examples:
              example:
                value:
                  title: "Act 1, Scene 1"
      responses:
        '201':
          description: Section heading added successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SectionHeadingResponse'
              examples:
                example:
                  value:
                    headingId: 1
                    scriptId: 1
                    sequenceNumber: 2
    put:
      summary: Update Section Heading
      operationId: updateSectionHeading
      description: Updates an existing section heading.
      parameters:
        - name: scriptId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the script the section heading belongs to.
        - name: headingId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the section heading to update.
      requestBody:
        required: true
        description: Details of the section heading to be updated.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SectionHeadingUpdateRequest'
            examples:
              example:
                value:
                  title: "Act 1, Scene 1 - Updated"
      responses:
        '200':
          description: Section heading updated successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SectionHeadingResponse'
              examples:
                example:
                  value:
                    headingId: 1
                    scriptId: 1
                    sequenceNumber: 2
    post:
      summary: Reorder Section Headings
      operationId: reorderSectionHeadings
      description: Reorders section headings within a script by updating their sequence numbers.
      parameters:
        - name: scriptId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the script to reorder section headings for.
      requestBody:
        required: true
        description: Details of the reordering request.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ReorderRequest'
            examples:
              example:
                value:
                  elements:
                    - headingId: 1
                      newSequence: 2
                    - headingId: 2
                      newSequence: 1
      responses:
        '200':
          description: Section headings reordered successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SuccessResponse'
              examples:
                example:
                  value:
                    message: "Reorder successful."
components:
  schemas:
    ScriptRequest:
      type: object
      properties:
        title:
          type: string
          description: Title of the script.
        author:
          type: string
          description: Author of the script.
        description:
          type: string
          description: Brief description of the script.
      required:
        - title
    ScriptResponse:
      type: object
      properties:
        scriptId:
          type: integer
          description: Unique identifier of the script.
        sequenceNumber:
          type: integer
          description: Sequence number assigned to the script.
    Script:
      type: object
      properties:
        scriptId:
          type: integer
          description: Unique identifier of the script.
        title:
          type: string
          description: Title of the script.
        author:
          type: string
          description: Author of the script.
        description:
          type: string
          description: Brief description of the script.
        sequenceNumber:
          type: integer
          description: Sequence number assigned to the script.
    ScriptUpdateRequest:
      type: object
      properties:
        title:
          type: string
          description: Title of the script.
        author:
          type: string
          description: Author of the script.
        description:
          type: string
          description: Brief description of the script.
    SectionHeadingRequest:
      type: object
      properties:
        title:
          type: string
          description: Title of the section heading.
      required:
        - title
    SectionHeadingResponse:
      type: object
      properties:
        headingId:
          type: integer
          description: Unique identifier of the section heading.
        scriptId:
          type: integer
          description: Unique identifier of the script.
        sequenceNumber:
          type: integer
          description: Sequence number assigned to the section heading.
    SectionHeadingUpdateRequest:
      type: object
      properties:
        title:
          type: string
          description: Title of the section heading.
    ReorderRequest:
      type: object
      properties:
        elements:
          type: array
          items:
            type: object
            properties:
              headingId:
                type: integer
                description: Unique identifier of the section heading.
              newSequence:
                type: integer
                description: New sequence number for the section heading.
      required:
        - elements
    SuccessResponse:
      type: object
      properties:
        message:
          type: string
          description: Success message.
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

#### Creating the First Script

1. **Request**: Create a new script titled "Romeo and Juliet" with the Core Script Management API.
   - The API requests a sequence number from the Central Sequence Service.
2. **Response**: The script is created with sequence number 1.

#### Adding Sections to the Script

1. **Request**: Add a section heading "Act 1, Scene 1" to "Romeo and Juliet".
   - The API requests a sequence number from the Central Sequence Service.
2. **Response**: The section heading is added with sequence number 2.

#### Creating Characters

1. **Request**: Create a new character named "Juliet" using the Character Management API.
   - The API requests a sequence number from the Central Sequence Service.
2. **Response**: The character is created with sequence number 3.

1. **Request**: Create a new character named "Romeo" using the Character Management API.
   - The API requests a sequence number from the Central Sequence Service.
2. **Response**: The character is created with sequence number 4.

#### Adding Actions and Spoken Words

1. **Request**: Add an action "Juliet stands on the balcony" to Juliet.
   - The API requests a sequence number from the Central Sequence Service.
2. **Response**: The action is added with sequence number 5.

1. **Request**: Add a spoken word "O Romeo, Romeo! wherefore art thou Romeo?" to Juliet.
   - The API requests a sequence number from the Central Sequence Service.
2. **Response**: The spoken word is added with sequence number 6.

#### Creating Sessions and Contexts

1. **Request**: Create a session for Juliet using the Session and Context Management API.
   - The API requests a sequence number from the Central Sequence Service.
2. **Response**: The session is created with sequence number 7.

1. **Request**: Add context data "longing" and "Capulet's mansion balcony" for Juliet.
   - The API requests a sequence number from the Central Sequence Service.
2. **Response**: The context is added with sequence number 8.

#### Assembling the Story

1. **Request**: Use the Story Factory API to fetch and assemble the story for "Romeo and Juliet".
   - Fetch scripts, sections, characters, actions, spoken words, and contexts from the respective APIs.
   - Use the sequence numbers to order these elements correctly.
2. **Response**: The complete story is assembled with all elements in logical order, ready to be read.

### Conclusion

By following these steps, the system ensures that every element within the story is assigned a unique sequence number, maintaining a consistent and logical flow. The Central Sequence Service acts as the backbone, providing a centralized mechanism to generate and manage sequence numbers, ensuring all APIs work harmoniously to create a cohesive narrative.

If you start from somewhere else, such as creating a snippet of dialogue, a character, or any other element besides the script, the system will still function seamlessly. Here’s how it works:

### Creating a Character First

1. **Request**: Create a new character named "Juliet" using the Character Management API.
   - **Sequence Request**: The API requests a sequence number from the Central Sequence Service.
2. **Response**: The character is created with sequence number 1.

3. **Next Step**: Add actions and spoken words to this character.
   - **Request**: Add an action "Juliet stands on the balcony" to Juliet.
     - **Sequence Request**: The API requests a sequence number from the Central Sequence Service.
   - **Response**: The action is added with sequence number 2.
   
   - **Request**: Add a spoken word "O Romeo, Romeo! wherefore art thou Romeo?" to Juliet.
     - **Sequence Request**: The API requests a sequence number from the Central Sequence Service.
   - **Response**: The spoken word is added with sequence number 3.

### Creating a Snippet of Dialogue First

1. **Request**: Add a spoken word "O Romeo, Romeo! wherefore art thou Romeo?" using the Character Management API.
   - **Sequence Request**: The API requests a sequence number from the Central Sequence Service.
2. **Response**: The spoken word is added with sequence number 1.

3. **Next Step**: Link the spoken word to a character and an action.
   - **Request**: Create a new character named "Juliet" using the Character Management API.
     - **Sequence Request**: The API requests a sequence number from the Central Sequence Service.
   - **Response**: The character is created with sequence number 2.

   - **Request**: Add an action "Juliet stands on the balcony" to Juliet.
     - **Sequence Request**: The API requests a sequence number from the Central Sequence Service.
   - **Response**: The action is added with sequence number 3.



### Creating a Context First

1. **Request**: Create a session for Juliet using the Session and Context Management API.
   - **Sequence Request**: The API requests a sequence number from the Central Sequence Service.
2. **Response**: The session is created with sequence number 1.

3. **Next Step**: Add context data for the session.
   - **Request**: Add context data "longing" and "Capulet's mansion balcony" for Juliet.
     - **Sequence Request**: The API requests a sequence number from the Central Sequence Service.
   - **Response**: The context is added with sequence number 2.

### Example Scenario: Adding Elements in a Non-linear Order

#### Step 1: Create a Character

1. **Request**: Create a character named "Romeo".
   - **Sequence Request**: The Character Management API requests a sequence number from the Central

 Sequence Service.
2. **Response**: Character "Romeo" is created with sequence number 1.

#### Step 2: Add a Snippet of Dialogue

1. **Request**: Add a spoken word "But, soft! what light through yonder window breaks?".
   - **Sequence Request**: The Character Management API requests a sequence number from the Central Sequence Service.
2. **Response**: Spoken word is added with sequence number 2.

#### Step 3: Create a Script

1. **Request**: Create a script titled "Romeo and Juliet".
   - **Sequence Request**: The Core Script Management API requests a sequence number from the Central Sequence Service.
2. **Response**: Script "Romeo and Juliet" is created with sequence number 3.

#### Step 4: Add Section Headings

1. **Request**: Add a section heading "Act 1, Scene 1".
   - **Sequence Request**: The Core Script Management API requests a sequence number from the Central Sequence Service.
2. **Response**: Section heading is added with sequence number 4.

#### Step 5: Add Context for Romeo

1. **Request**: Create a session for "Romeo".
   - **Sequence Request**: The Session and Context Management API requests a sequence number from the Central Sequence Service.
2. **Response**: Session is created with sequence number 5.

1. **Request**: Add context data "Capulet's garden at night" for Romeo.
   - **Sequence Request**: The Session and Context Management API requests a sequence number from the Central Sequence Service.
2. **Response**: Context is added with sequence number 6.

### Logical Reading Flow

No matter the order in which elements are created, each element is assigned a sequence number by the Central Sequence Service, ensuring a logical reading flow when the story is assembled. The Story Factory API will gather these elements, sort them by their sequence numbers, and present them in the intended order.

### Conclusion

The Central Sequence Service ensures that all elements, regardless of the order in which they are created, are given unique and sequential numbers. This guarantees a coherent and logical narrative flow when assembled by the Story Factory API, maintaining the integrity and readability of the story.

This documentation now includes detailed breakdowns, examples, and the YAML version of the OpenAPI specification for the **Core Script Management API**, ensuring it follows the format used for the Central Sequence Service. We will follow a similar approach for the other APIs (Character Management API, Session and Context Management API, and Story Factory API).