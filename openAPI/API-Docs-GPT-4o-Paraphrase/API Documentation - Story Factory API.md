### API Documentation - Story Factory API

### Overview

The Story Factory API integrates data from the other APIs to assemble and manage the logical flow of stories. It collects information from the Core Script Management API, Character Management API, and Session and Context Management API, ensuring that each element follows a logical sequence.

### Key Features

- **Assemble Stories**: Collect and organize data from multiple sources to create a cohesive story.
- **Fetch Story Elements**: Retrieve scripts, sections, characters, actions, spoken words, and contexts.
- **Sequence Integration**: Use sequence numbers from the Central Sequence Service to maintain the logical flow of stories.

### Data Flow and Integration

The Story Factory API integrates with the Central Sequence Service to ensure that all elements of the story are presented in a coherent and logical order. It gathers data from the Core Script Management API, Character Management API, and Session and Context Management API, using sequence numbers to assemble these elements correctly.

### Example of Usage

The following example JSON object shows how a story is assembled by the Story Factory API, with each element assigned a sequence number to ensure a natural and logical reading flow.

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
  ],
  "story": [
    {
      "sequence": 1,
      "character": {
        "characterId": 1,
        "name": "Juliet",
        "description": "The heroine of Romeo and Juliet."
      },
      "action": {
        "actionId": 1,
        "description": "Juliet stands on the balcony, looking out into the night."
      },
      "spokenWord": {
        "dialogueId": 1,
        "text": "O Romeo, Romeo! wherefore art thou Romeo?"
      },
      "context": {
        "contextId": 1,
        "characterId": 1,
        "data": {
          "mood": "longing",
          "location": "Capulet's mansion balcony"
        }
      }
    },
    {
      "sequence": 2,
      "character": {
        "characterId": 2,
        "name": "Romeo",
        "description": "The hero of Romeo and Juliet."
      },
      "action": {
        "actionId": 2,
        "description": "Romeo steps out from the shadows below the balcony."
      },
      "spokenWord": {
        "dialogueId": 2,
        "text": "By a name I know not how to tell thee who I am: My name, dear saint, is hateful to myself, Because it is an enemy to thee."
      },
      "context": {
        "contextId": 2,
        "characterId": 2,
        "data": {
          "mood": "desperate",
          "location": "Below Juliet's balcony"
        }
      }
    },
    {
      "sequence": 3,
      "character": {
        "characterId": 1,
        "name": "Juliet",
        "description": "The heroine of Romeo and Juliet."
      },
      "action": {
        "actionId": 3,
        "description": "Juliet leans over the balcony, reaching out towards Romeo."
      },
      "spokenWord": {
        "dialogueId": 3,
        "text": "What’s in a name? That which we call a rose By any other name would smell as sweet."
      },
      "context": {
        "contextId": 3,
        "characterId": 1,
        "data": {
          "mood": "curious",
          "location": "Capulet's mansion balcony"
        }
      }
    }
  ],
  "orchestration": {
    "csoundFilePath": "/files/sound.csd",
    "lilyPondFilePath": "/files/sheet.ly",
    "midiFilePath": "/files/music.mid"
  }
}
```

### Story Factory API Specification

Below is the full OpenAPI specification for the Story Factory API, ensuring that all necessary information from the FountainAI APIs is integrated.

```yaml
openapi: 3.1.0
info:
  title: Story Factory API
  description: >
    This API integrates data from the Core Script Management API, Character Management API, and Session and Context Management API to assemble and manage the logical flow of stories.
  version: 1.0.0
servers:
  - url: https://storyfactory.fountain.coach
    description: Production server for Story Factory API
  - url: http://localhost:8080
    description: Development server
paths:
  /stories:
    get:
      summary: Retrieve Full Story
      operationId: getFullStory
      description: Fetches a complete story, including sections, characters, actions, spoken words, context, and transitions.
      parameters:
        - name: scriptId
          in: query
          required: true
          schema:
            type: integer
          description: Unique identifier of the script to retrieve the story for.
      responses:
        '200':
          description: Full story retrieved successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/FullStory'
              examples:
                example:
                  value:
                    scriptId: 1
                    title: "Romeo and Juliet"
                    author: "William Shakespeare"
                    description: "A tale of two star-crossed lovers."
                    sections:
                      - headingId: 1
                        scriptId: 1
                        title: "Act 1, Scene 1"
                        sequence: 1
                    story:
                      - sequence: 1
                        character:
                          characterId: 1
                          name: "Juliet"
                          description: "The heroine of Romeo and Juliet."
                        action:
                          actionId: 1
                          description: "Juliet stands on the balcony, looking out into the night."
                        spokenWord:
                          dialogueId: 1
                          text: "O Romeo, Romeo! wherefore art thou Romeo?"
                        context:
                          contextId: 1
                          characterId: 1
                          data:
                            mood: "longing"
                            location: "Capulet's mansion balcony"
                      - sequence: 2
                        character:
                          characterId: 2
                          name: "Romeo"
                          description: "The hero of Romeo and Juliet."
                        action:
                          actionId: 2
                          description: "Romeo steps out from the shadows below the balcony."
                        spokenWord:
                          dialogueId: 2
                          text: "By a name I know not how to tell thee who I am: My name, dear saint, is hateful to myself, Because it is an enemy to thee."
                        context:
                          contextId: 2
                          characterId: 2
                          data:
                            mood: "desperate"
                            location: "Below Juliet's balcony"
                      - sequence: 3
                        character:
                          characterId: 1
                          name: "Juliet"
                          description: "The heroine of Romeo and Juliet."
                        action:
                          actionId: 3
                          description: "Juliet leans over the balcony, reaching out towards Romeo."
                        spokenWord:
                          dialogueId: 3
                          text: "What’s in a name? That which we call a rose By any other name would smell as sweet."
                        context:
                          contextId: 3
                          characterId: 1
                          data:
                            mood: "curious"
                            location: "Capulet's mansion balcony"
                    orchestration:
                      csoundFilePath: "/files/sound.csd"
                      lilyPondFilePath: "/files/sheet.ly"
                      midiFilePath: "/files/music.mid"
        '404':
          description: Script not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                example:
                  value:
                    message: "Script not found."
  /stories/sequences:
    get:
      summary: Retrieve Story Sequences
      operationId: getStorySequences
      description: Retrieves specific sequences from a story, ensuring a logical flow.
      parameters:
        - name: scriptId
          in: query
          required: true
          schema:
            type: integer
          description: Unique identifier of the script to retrieve sequences for.
        - name: startSequence
          in: query
          required: true
          schema:
            type: integer
          description: The starting sequence number.
        - name: endSequence
          in: query
          required: true
          schema:
            type: integer
          description: The ending sequence number.
      responses:
        '200':
          description: Story sequences retrieved successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/StorySequence'
              examples:
                example:
                  value:
                    scriptId: 1
                    sequences:
                      - sequence: 1
                        character:
                          characterId: 1
                          name: "Juliet"
                        action:
                          actionId: 1
                          description: "Juliet stands on the balcony."
                        spokenWord:
                          dialogueId: 1
                          text: "O Romeo, Romeo! wherefore art thou Romeo?"
                      - sequence: 2
                        character:
                          characterId: 2
                          name: "Romeo"
                        action:
                          actionId: 2
                          description: "Romeo steps out from the shadows."
                        spokenWord:
                          dialogueId: 2
                          text: "By a name I know not how to tell thee who I am."
                      - sequence: 3
                        character:
                          characterId: 1
                          name: "Juliet"
                        action:
                          actionId: 3
                          description: "Juliet leans over the balcony."
                        spokenWord:
                          dialogueId: 3
                          text: "What’s in a name? That which we call a rose."
        '404':
          description: Script or sequences not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                example:
                  value:
                    message: "Script or sequences not found."
components:
  schemas:
    FullStory:
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
          description: Brief description or summary of the script.
        sections:
          type: array
          items:
            $ref: '#/components/schemas/SectionHeading'
        story:
          type: array
          items:
            $ref: '#/components/schemas/StoryElement'
        orchestration:
          type: object
          properties:
            csoundFilePath:
              type: string
              description: Path to the generated Csound file.
            lilyPondFilePath:
              type: string
              description: Path to the generated LilyPond file.
            midiFilePath:
              type: string
              description: Path to the generated MIDI file.
    SectionHeading:
      type: object
      properties:
        headingId:
          type: integer
          description: Unique identifier for the Section Heading.
        scriptId:
          type: integer
          description: Identifier of the script this Section Heading belongs to.
        title:
          type: string
          description: Title of the Section Heading.
        sequence:
          type: integer
          description: Order sequence of the Section Heading within the script.
    StoryElement:
      type: object
      properties:
        sequence:
          type: integer
          description: The sequence number of the story element, ensuring the correct order.
        character:
          $ref: '#/components/schemas/Character'
        action:
          $ref: '#/components/schemas/Action'
        spokenWord:
          $ref: '#/components/schemas/SpokenWord'
        context:
          $ref: '#/components/schemas/Context'
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
          description: A brief description of the character and their role within the screenplay.
    Action:
      type: object
      properties:
        actionId:
          type: integer
          description: Unique identifier for the action.
        description:
          type: string
          description: A textual description outlining what happens in this action.
    SpokenWord:
      type: object
      properties:
        dialogueId:
          type: integer
          description: Unique identifier for the SpokenWord entity.
        text:
          type: string
          description: The dialogue text of the SpokenWord entity.
        sequence:
          type: integer
          description: Order sequence of the SpokenWord within the script.
    Context:
      type: object
      properties:
        contextId:
          type: integer
          description: Unique identifier for the context.
        characterId:
          type: integer
          description: Identifier of the character this context belongs to.
        data:
          type: object
          description: Context data for the character.
          additionalProperties:
            type: string
    StorySequence:
      type: object
      properties:
        scriptId:
          type: integer
          description: Unique identifier of the script.
        sequences:
          type: array
          items:
            $ref: '#/components/schemas/StoryElement'
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
2. **Response**: The context is

 added with sequence number 8.

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