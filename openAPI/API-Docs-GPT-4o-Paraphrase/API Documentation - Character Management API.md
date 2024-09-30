### API Documentation - Character Management API

### Overview

The Character Management API is designed to handle characters within stories, including their creation, management, actions, and spoken words. It integrates with the Central Sequence Service to ensure logical sequence numbers for each element, allowing a coherent flow within the story.

### Key Features

- **Retrieve All Characters**: Fetches a list of all characters stored in the system.
- **Create a New Character**: Allows for the creation of a new character.
- **Retrieve All Paraphrases for a Character**: Fetches all paraphrases linked to a specific character.
- **Create a New Paraphrase for a Character**: Allows for the creation of a new paraphrase linked to a character.
- **Retrieve All Actions**: Lists all actions stored within the system.
- **Create a New Action**: Allows for the creation of a new action entity.
- **Retrieve All Paraphrases for an Action**: Fetches all paraphrases linked to a specific action.
- **Create a New Paraphrase for an Action**: Allows for the creation of a new paraphrase linked to an action.
- **Retrieve All Spoken Words**: Lists all spoken words currently stored within the system.
- **Create a New Spoken Word**: Allows for the creation of a new spoken word entity.
- **Retrieve All Paraphrases for a Spoken Word**: Fetches all paraphrases linked to a specific spoken word.
- **Create a New Paraphrase for a Spoken Word**: Allows for the creation of a new paraphrase linked to a spoken word.

### Data Flow and Integration

The Character Management API relies on the Central Sequence Service to assign unique sequence numbers to each element (characters, actions, spoken words, paraphrases), ensuring a logical and coherent order within the story.

### Example of Usage

The following example shows a dialogue exchange between characters within an established sequence, managed by the Central Sequence Service. Each element is assigned a sequence number to ensure a natural and logical reading flow.

```json
{
  "characterId": 1,
  "name": "Juliet",
  "description": "The heroine of Romeo and Juliet.",
  "actions": [
    {
      "actionId": 1,
      "description": "Juliet stands on the balcony, looking out into the night.",
      "sequence": 1
    }
  ],
  "spokenWords": [
    {
      "dialogueId": 1,
      "text": "O Romeo, Romeo! wherefore art thou Romeo?",
      "sequence": 2
    }
  ],
  "paraphrases": [
    {
      "paraphraseId": 1,
      "originalId": 1,
      "text": "Juliet, the love interest of Romeo in the classic tale.",
      "commentary": "Adapted description for modern retellings.",
      "sequence": 3
    }
  ]
}
```

### Character Management API Specification

Below is the full OpenAPI specification for the Character Management API, ensuring that all necessary information is integrated.

```yaml
openapi: 3.1.0
info:
  title: Character Management API
  description: >
    This API handles characters within stories, including their creation, management, actions, and spoken words. It integrates with the Central Sequence Service to ensure logical sequence numbers for each element, allowing a coherent flow within the story.
  version: 1.0.0
servers:
  - url: https://character.fountain.coach
    description: Production server for Character Management API
  - url: http://localhost:8080
    description: Development server
paths:
  /characters:
    get:
      summary: Retrieve All Characters
      operationId: listCharacters
      description: Lists all characters stored within the application.
      responses:
        '200':
          description: A JSON array of character entities.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Character'
        '500':
          description: Internal server error indicating a failure to process the request.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
    post:
      summary: Create a New Character
      operationId: createCharacter
      description: Allows for the creation of a new character.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CharacterCreateRequest'
      responses:
        '201':
          description: Character successfully created, returning the new character entity.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Character'
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error indicating a failure in creating the character.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
  /characters/{characterId}/paraphrases:
    get:
      summary: Retrieve All Paraphrases for a Character
      operationId: listCharacterParaphrases
      description: Retrieves all paraphrases linked to a specific character, including a commentary on why each paraphrase is connected to the original character.
      parameters:
        - name: characterId
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: A JSON array of paraphrases for the specified character.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Paraphrase'
        '404':
          description: The specified character was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error indicating a failure to retrieve the paraphrases.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
    post:
      summary: Create a New Paraphrase for a Character
      operationId: createCharacterParaphrase
      description: Allows for the creation of a new paraphrase linked to a character.
      parameters:
        - name: characterId
          in: path
          required: true
          schema:
            type: integer
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ParaphraseCreateRequest'
      responses:
        '201':
          description: The paraphrase has been successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Paraphrase'
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '404':
          description: The specified character was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error indicating a failure in creating the paraphrase.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
  /actions:
    get:
      summary: Retrieve All Actions
      operationId: listActions
      description: Lists all actions currently stored within the system.
      responses:
        '200':
          description: A JSON array of action entities.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Action'
        '500':
          description: Internal server error indicating a failure to process the request.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
    post:
      summary: Create a New Action
      operationId: createAction
      description: Allows for the creation of a new action entity.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ActionCreateRequest'
      responses:
        '201':
          description: The action has been successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Action'
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error indicating a failure in creating the action.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
  /actions/{actionId}/paraphrases:
    get:
      summary: Retrieve All Paraphrases for an Action
      operationId: listActionParaphrases
      description: Retrieves all paraphrases linked to a specific action.
      parameters:
        - name: actionId
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: A JSON array of paraphrases for the specified action.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Paraphrase'
        '404':
          description: The specified action was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error indicating a failure to retrieve the paraphrases.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
    post:
      summary: Create a New Paraphrase for an Action
      operationId: createActionParaphrase
      description: Allows for the creation of a new paraphrase linked to an action.
      parameters:
        - name: actionId
          in: path
          required: true
          schema:
            type: integer
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ParaphraseCreateRequest'
      responses:
        '201':
          description: The paraphrase has been successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Paraphrase'
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '404':
          description: The specified action was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error indicating a failure in creating the paraphrase.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
  /spokenWords:
    get:
      summary: Retrieve All Spoken Words
      operationId: listSpokenWords
      description: Lists all spoken words currently stored within the system.
      responses:
        '200':
          description: A JSON array of spoken word entities.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/SpokenWord'
        '500':
          description: Internal server error indicating a failure to process the request.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
    post:
      summary: Create a New Spoken Word
      operationId: createSpokenWord
      description: Allows for the creation of a new spoken word entity.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SpokenWordCreateRequest'
      responses:
        '201':
          description: The spoken word has been successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SpokenWord'
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error indicating a failure in creating the spoken word.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
  /spokenWords/{spokenWordId}/paraphrases:
    get:
      summary: Retrieve All Paraphrases for a Spoken Word
      operationId: listSpokenWordParaphrases
      description: Retrieves all paraphrases linked to a specific spoken word.
      parameters:
        - name: spokenWordId
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: A JSON array of paraphrases for the specified spoken word.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Paraphrase'
        '404':
          description: The specified spoken word was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error indicating a failure to retrieve the paraphrases.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
    post:
      summary: Create a New Paraphrase for a Spoken Word
      operationId: createSpokenWordParaphrase
      description: Allows for the creation of a new paraphrase linked to a spoken word.
      parameters:
        - name: spokenWordId
          in: path
          required: true
          schema:
            type: integer
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ParaphraseCreateRequest'
      responses:
        '201':
          description: The paraphrase has been successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Paraphrase'
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '404':
          description: The specified spoken word was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error indicating a failure in creating the paraphrase.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
components:
  schemas:
    Character:
      type: object
      properties:
        characterId:
          type: integer
          description: Unique identifier for the character.
        name:
          type: string
          description: Name of the character.
        description:
          type: string
          description: A brief description of the character and their role within the story.
    CharacterCreateRequest:
      type: object
      properties:
        name:
          type: string
          description: Name of the character.
        description:
          type: string
          description: A brief description of the character and their role within the story.
      required:
        - name
        - description
    Paraphrase:
      type: object
      properties:
        paraphraseId:
          type: integer
          description: Unique identifier for the paraphrase.
        originalId:
          type: integer
          description: Identifier of the original entity this paraphrase is linked to.
        text:
          type: string
          description: The text of the paraphrase.
        commentary:
          type: string
          description: Commentary on why the paraphrase is linked to the original entity.
    ParaphraseCreateRequest:
      type: object
      properties:
        originalId:
          type: integer
          description: Identifier of the original entity this paraphrase is linked to.
        text:
          type: string
          description: The text of the paraphrase.
        commentary:
          type: string
          description: Commentary on why the paraphrase is linked to the original entity.
      required:
        - originalId
        - text
        - commentary
    Action:
      type: object
      properties:
        actionId:
          type: integer
          description: Unique identifier for the action.
        description:
          type: string
          description: A textual description outlining what happens in this action.
    ActionCreateRequest:
      type: object
      properties:
        description:
          type: string
          description: A textual description outlining what happens in this action.
      required:
        - description
    SpokenWord:
      type: object
      properties:
        dialogueId:
          type: integer
          description: Unique identifier for the spoken word entity.
        text:
          type: string
          description: The dialogue text of the spoken word entity.
    SpokenWordCreateRequest:
      type: object
      properties:
        text:
          type: string
          description: The dialogue text of the spoken word entity.
      required:
        - text
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
   - Use the API to create initial sessions for characters,

 receiving sequence numbers for each session.
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
   - **Sequence Request**: The Character Management API requests a sequence number from the Central Sequence Service.
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
