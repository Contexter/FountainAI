You are a highly capable AI trained to assist with software development. Given the following OpenAPI specification, generate a fully functional Vapor application in Swift. The code must be fully commented. Also, integrate a CI/CD pipeline using GitHub Actions, leveraging the secrets manager command-line tool previously created. The code must be provided in executable shell scripts that again produce the code correctly integrated into the FountainAI repository.

**OpenAPI Specification Placeholder:**
```
openapi: 3.0.1
info:
  title: FountainAI Admin API
  description: |
    This API integrates multiple functionalities for managing scripts, including section headings, transitions, spoken words, orchestration, complete script management, characters, and actions, along with their paraphrases.

    **Dockerized Environment**:
    - **Nginx**: An Nginx proxy container handles SSL termination with Let's Encrypt certificates via Certbot.
    - **Vapor Application**: A Swift-based Vapor app runs in a separate Docker container.
    - **Postgres Database**: The primary persistence layer is a PostgreSQL container managed by Docker Compose.
    - **Redis Cache**: A Redis container is used for caching data, optimizing performance for frequent queries.
    - **RedisAI Middleware**: RedisAI provides recommendations, validation, and analysis for various script components.

  version: "1.2"

servers:
  - url: 'https://fountain.coach'
    description: Production server for Script Management API
  - url: 'http://localhost:8080'
    description: Development server (Docker environment)

paths:
  /scripts:
    get:
      summary: Retrieve All Scripts
      operationId: listScripts
      description: |
        Lists all screenplay scripts stored within the system. This endpoint leverages Redis caching for improved query performance.
      responses:
        '200':
          description: An array of scripts.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Script'
              examples:
                allScripts:
                  summary: Example of retrieving all scripts
                  value:
                    - scriptId: 1
                      title: "Sunset Boulevard"
                      description: "A screenplay about Hollywood and faded glory."
                      author: "Billy Wilder"
                      sequence: 1
    post:
      summary: Create a New Script
      operationId: createScript
      description: |
        Creates a new screenplay script record in the system. RedisAI provides recommendations and validation during creation.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ScriptCreateRequest'
            examples:
              createScriptExample:
                summary: Example of script creation
                value:
                  title: "New Dawn"
                  description: "A story about renewal and second chances."
                  author: "Jane Doe"
                  sequence: 1
      responses:
        '201':
          description: Script successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                scriptCreated:
                  summary: Example of a created script
                  value:
                    scriptId: 2
                    title: "New Dawn"
                    description: "A story about renewal and second chances."
                    author: "Jane Doe"
                    sequence: 1
        '400':
          description: Bad request due to missing required fields.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestExample:
                  value:
                    message: "Missing required fields: 'title' or 'author'."
  /scripts/{scriptId}:
    get:
      summary: Retrieve a Script by ID
      operationId: getScriptById
      description: |
        Retrieves the details of a specific screenplay script by its unique identifier (scriptId). Redis caching improves retrieval performance.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to retrieve.
          schema:
            type: integer
      responses:
        '200':
          description: Detailed information about the requested script.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                retrievedScript:
                  summary: Example of a retrieved script
                  value:
                    scriptId: 1
                    title: "Sunset Boulevard"
                    description: "A screenplay about Hollywood and faded glory."
                    author: "Billy Wilder"
                    sequence: 1
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundExample:
                  value:
                    message: "Script not found with ID: 3"
    put:
      summary: Update a Script by ID
      operationId: updateScript
      description: |
        Updates an existing screenplay script with new details. RedisAI provides recommendations and validation for updating script content.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to update.
          schema:
            type: integer
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ScriptUpdateRequest'
            examples:
              updateScriptExample:
                summary: Example of updating a script
                value:
                  title: "Sunset Boulevard Revised"
                  description: "Updated description with more focus on character development."
                  author: "Billy Wilder"
                  sequence: 2
      responses:
        '200':
          description: Script successfully updated.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                scriptUpdated:
                  summary: Example of an updated script
                  value:
                    scriptId: 1
                    title: "Sunset Boulevard Revised"
                    description: "Updated description with more focus on character development."
                    author: "Billy Wilder"
                    sequence: 2
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestUpdateExample:
                  value:
                    message: "Invalid input data: 'sequence' must be a positive number."
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundUpdateExample:
                  value:
                    message: "Script not found with ID: 4"
    delete:
      summary: Delete a Script by ID
      operationId: deleteScript
      description: Deletes a specific screenplay script from the system, identified by its scriptId.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to delete.
          schema:
            type: integer
      responses:
        '204':
          description: Script successfully deleted.
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundDeleteExample:
                  value:
                    message: "Script not found with ID: 5"
  /sectionHeadings:
    get:
      summary: Retrieve Section Headings
      operationId: listSectionHeadings
      description: |
        Fetches a list of all Section Headings across scripts, providing an overview of script structures. This endpoint leverages Redis caching to improve query performance.
      responses:
        '200':
          description: Successfully retrieved a JSON array of Section Headings.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/SectionHeading'
              examples:
                sectionHeadingsExample:
                  value:
                    - headingId: 1
                      scriptId: 101
                      title: "Introduction"
                      sequence: 1
                    - headingId: 2
                      scriptId: 101
                      title: "Rising Action"
                      sequence: 2
    post:
      summary: Create Section Heading
      operationId: createSectionHeading
      description: |
        Creates a new Section Heading within a script, specifying its sequence, title, and associated script ID. RedisAI middleware provides recommendations and validation during the creation process.
      requestBody:
        required: true
        description: Data required to create a new Section Heading.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SectionHeading'
            examples:
              createSectionHeadingExample:
                value:
                  scriptId: 101
                  title: "Climax"
                  sequence: 3
      responses:
        '201':
          description: Successfully created a new Section Heading.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SectionHeading'
              examples:
                createdSectionHeading:
                  value:
                    headingId: 3
                    scriptId: 101
                    title: "Climax"
                    sequence: 3
  /actions:
    get:
      summary: Retrieve All Actions
      operationId: listActions
      description: |
        Lists all actions currently stored within the system. This endpoint leverages Redis caching for optimized query performance.
      responses:
        '200':
          description: A JSON array of action entities.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Action'
              examples:
                actionsExample:
                  summary: Example of an actions list
                  value:
                    - actionId: 1
                      description: "Character enters the room."
                      sequence: 1
                    - actionId: 2
                      description: "Character picks up a book."
                      sequence: 2
        '401':
          description: Unauthorized - Invalid or missing authentication token.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                unauthorizedExample:
                  summary: Unauthorized request example
                  value:
                    code: 401
                    message: "Unauthorized - Authentication token is missing or invalid."
        '500':
          description: Internal Server Error - Error fetching data from the server.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                internalServerErrorExample:
                  summary: Internal server error example
                  value:
                    code: 500
                    message: "Internal Server Error - Unable to retrieve actions."
    post:
      summary: Create a New Action
      operationId: createAction
      description: |
        Allows for the creation of a new action entity. Clients must provide an action description and its sequence within a script. This endpoint integrates with RedisAI to provide recommendations or validations based on predefined models.
      requestBody:
        required: true
        description: A JSON object containing the new action's details.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Action'
            examples:
              createActionExample:
                summary: Example of creating an action
                value:
                  description: "Character shouts for help."
                  sequence: 3
      responses:
        '201':
          description: The action has been successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Action'
              examples:
                createActionResponseExample:
                  summary: Successful action creation example
                  value:
                    actionId: 3
                    description: "Character shouts for help."
                    sequence: 3
        '400':
          description: Bad Request - Missing or invalid data in the request body.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestExample:
                  summary: Bad request example
                  value:
                    code: 400
                    message: "Bad Request - Data format is incorrect or missing fields."
        '401':
          description: Unauthorized - Invalid or missing authentication token.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                unauthorizedExample:
                  summary: Unauthorized request example
                  value:
                    code: 401
                    message: "Unauthorized - Authentication token is missing or invalid."
        '500':
          description: Internal Server Error - Error creating the action.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                internalServerErrorExample:
                  summary: Internal server error example
                  value:
                    code: 500
                    message: "Internal Server Error - Unable to create the action."
  /actions/{actionId}/paraphrases:
    get:
      summary: Retrieve All Paraphrases for an Action
      operationId: listActionParaphrases
      description: |
        Retrieves all paraphrases linked to a specific action. This includes commentary on why each paraphrase is connected to the original action.
        Leverages Redis caching for improved query performance.
      parameters:
        - name: actionId
          in: path
          required: true
          description: The unique identifier of the action whose paraphrases are to be retrieved.
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
              examples:
                paraphrasesExample:
                  summary: Example list of paraphrases
                  value:
                    - paraphraseId: 1
                      originalId: 1
                      text: "Character enters the stage."
                      commentary: "Rephrased to fit a theatrical context."
                    - paraphraseId: 2
                      originalId: 1
                      text: "Character steps into the scene."
                      commentary: "Adjusted for a screenplay format."
        '404':
          description: Not Found - The specified action does not exist.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundExample:
                  summary: Not found example
                  value:
                    code: 404
                    message: "Not Found - The action specified does not exist."
        '401':
          description: Unauthorized - Invalid or missing authentication token.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                unauthorizedExample:
                  summary: Unauthorized request example
                  value:
                    code: 401
                    message: "Unauthorized - Authentication token is missing or invalid."
        '500':
          description: Internal Server Error - Error fetching paraphrases from the server.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                internalServerErrorExample:
                  summary: Internal server error example
                  value:
                    code: 500
                    message: "Internal Server Error - Unable to retrieve paraphrases."
    post:
      summary: Create a New Paraphrase for an Action
      operationId: createActionParaphrase
      description: |
        Allows for the creation of a new paraphrase linked to an action. Clients must provide the paraphrased text and a commentary explaining the link to the original action. RedisAI integration provides additional validation.
      parameters:
        - name: actionId
          in: path
          required: true
          description: The unique identifier of the action to which the paraphrase will be linked.
          schema:
            type: integer
      requestBody:
        required: true
        description: A JSON object containing the new paraphrase's details and its link commentary.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Paraphrase'
            examples:
              createParaphraseExample:
                summary: Example of creating a paraphrase
                value:
                  originalId: 1
                  text: "Character makes an entrance."
                  commentary: "Simplified for better understanding in educational scripts."
      responses:
        '201':
          description: The paraphrase has been successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Paraphrase'
              examples:
                createParaphraseResponseExample:
                  summary: Successful paraphrase creation example
                  value:
                    paraphraseId: 3
                    originalId: 1
                    text: "Character makes an entrance."
                    commentary: "Simplified for better understanding in educational scripts."
        '400':
          description: Bad Request - Missing or invalid data in the request body.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestExample:
                  summary: Bad request example
                  value:
                    code: 400
                    message: "Bad Request - Data format is incorrect or missing fields."
        '404':
          description: Not Found - The specified action does not exist.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundExample:
                  summary: Not found example
                  value:
                    code: 404
                    message: "Not Found - The action specified does not exist."
        '401':
          description: Unauthorized - Invalid or missing authentication token.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                unauthorizedExample:
                  summary: Unauthorized request example
                  value:
                    code: 401
                    message: "Unauthorized - Authentication token is missing or invalid."
        '500':
          description: Internal Server Error - Error creating the paraphrase.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                internalServerErrorExample:
                  summary: Internal server error example
                  value:
                    code: 500
                    message: "Internal Server Error - Unable to create the paraphrase."
  /characters:
    get:
      summary: Retrieve All Characters
      operationId: listCharacters
      description: |
        Lists all characters stored within the application, offering an overview of the characters available for screenplay development. This endpoint leverages Redis caching to improve query performance.
      responses:
        '200':
          description: A JSON array of character entities.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Character'
              examples:
                characterListExample:
                  summary: Example of character listing
                  value:
                    - characterId: 1
                      name: "Juliet"
                      description: "The heroine of Romeo and Juliet."
                      scriptIds: [2, 5, 7]
                    - characterId: 2
                      name: "Romeo"
                      description: "The hero of Romeo and Juliet."
                      scriptIds: [2, 5, 7]
        '500':
          description: Internal server error indicating a failure to process the request.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                internalServerErrorExample:
                  summary: Internal server error example
                  value:
                    code: 500
                    message: "Internal Server Error - Unable to retrieve characters."
    post:
      summary: Create a New Character
      operationId: createCharacter
      description: |
        Allows for the creation of a new character, adding to the pool of characters available for inclusion in screenplays. RedisAI is integrated to provide recommendations and validation for character creation.
      requestBody:
        required: true
        description: A JSON object detailing the new character to be created.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CharacterCreateRequest'
            examples:
              createCharacterExample:
                summary: Example of creating a new character
                value:
                  name: "Mercutio"
                  description: "A close friend of Romeo with a wild, energetic personality."
      responses:
        '201':
          description: Character successfully created, returning the new character entity.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Character'
              examples:
                createCharacterResponseExample:
                  summary: Successful character creation example
                  value:
                    characterId: 3
                    name: "Mercutio"
                    description: "A close friend of Romeo with a wild, energetic personality."
                    scriptIds: []
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestExample:
                  summary: Bad request example
                  value:
                    code: 400
                    message: "Bad Request - Missing name field in request body."
        '500':
          description: Internal server error indicating a failure in creating the character.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                internalServerErrorExample:
                  summary: Internal server error example
                  value:
                    code: 500
                    message: "Internal Server Error - Unable to create character."
  /characters/{characterId}/paraphrases:
    get:
      summary: Retrieve All Paraphrases for a Character
      operationId: listCharacterParaphrases
      description: |
        Retrieves all paraphrases linked to a specific character, including a commentary on why each paraphrase is connected to the original character. Redis caching improves retrieval performance.
      parameters:
        - name: characterId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the character whose paraphrases are to be retrieved.
      responses:
        '200':
          description: A JSON array of paraphrases for the specified character.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Paraphrase'
              examples:
                paraphraseListExample:
                  summary: Example list of paraphrases
                  value:
                    - paraphraseId: 1
                      originalId: 1
                      text: "Juliet, a young woman of Verona."
                      commentary: "Simplified description for younger audiences."
                    - paraphraseId: 2
                      originalId: 1
                      text: "Juliet, the love interest of Romeo in the classic tale."
                      commentary: "Adapted description for modern retellings."
        '404':
          description: The specified character was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundExample:
                  summary: Not found example
                  value:
                    code: 404
                    message: "Not Found - The character specified does not exist."
        '500':
          description: Internal server error indicating a failure to retrieve the paraphrases.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                internalServerErrorExample:
                  summary: Internal server error example
                  value:
                    code: 500
                    message: "Internal Server Error - Unable to retrieve paraphrases."
    post:
      summary: Create a New Paraphrase for a Character
      operationId: createCharacterParaphrase
      description: |
        Allows for the creation of a new paraphrase linked to a character. Clients must provide the paraphrased text and a commentary explaining the link to the original character. RedisAI integration provides additional validation.
      parameters:
        - name: characterId
          in: path
          required: true
          schema:
            type: integer
          description: The unique identifier of the character to which the paraphrase will be linked.
      requestBody:
        required: true
        description: A JSON object containing the new paraphrase's details and its link commentary.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Paraphrase'
            examples:
              createParaphraseExample:
                summary: Example of creating a new paraphrase
                value:
                  originalId: 1
                  text: "Juliet, the star-crossed lover from Shakespeare's famous play."
                  commentary: "Contextualized description for educational purposes."
      responses:
        '201':
          description: The paraphrase has been successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Paraphrase'
              examples:
                createParaphraseResponseExample:
                  summary: Successful paraphrase creation example
                  value:
                    paraphraseId: 3
                    originalId: 1
                    text: "Juliet, the star-crossed lover from Shakespeare's famous play."
                    commentary: "Contextualized description for educational purposes."
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestExample:
                  summary: Bad request example
                  value:
                    code: 400
                    message: "Bad Request - Missing or incorrect fields in request body."
        '404':
          description: The specified character was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundExample:
                  summary: Not found example
                  value:
                    code: 404
                    message: "Not Found - The character specified does not exist."
        '500':
          description: Internal server error indicating a failure in creating the paraphrase.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                internalServerErrorExample:
                  summary: Internal server error example
                  value:
                    code: 500
                    message: "Internal Server Error - Unable to create the paraphrase."
  /spokenWords:
    get:
      summary: Retrieve All SpokenWords
      operationId: getSpokenWords
      description: |
        Fetches a list of all SpokenWords entities in the system, providing an overview of spoken dialogues. This endpoint leverages Redis caching to improve query performance.
      responses:
        '200':
          description: Successfully retrieved a list of SpokenWords.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/SpokenWord'
              examples:
                spokenWordsExample:
                  summary: Example of retrieving all spoken words
                  value:
                    - dialogueId: 1
                      text: "Hello there, how are you?"
                      sequence: 1
                    - dialogueId: 2
                      text: "I'm fine, thank you!"
                      sequence: 2
    post:
      summary: Create SpokenWord
      operationId: createSpokenWord
      description: |
        Creates a new SpokenWord entity with provided dialogue text and sequence within the script. RedisAI middleware provides recommendations and validation during creation.
      requestBody:
        required: true
        description: Details for the new SpokenWord entity to be created.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SpokenWord'
            examples:
              createSpokenWordExample:
                value:
                  text: "Suddenly, he was gone."
                  sequence: 3
      responses:
        '201':
          description: Successfully created a new SpokenWord entity.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SpokenWord'
              examples:
                createdSpokenWord:
                  summary: Example of a created spoken word
                  value:
                    dialogueId: 3
                    text: "Suddenly, he was gone."
                    sequence: 3
  /spokenWords/{id}/paraphrases:
    get:
      summary: Retrieve All Paraphrases for a SpokenWord
      operationId: listSpokenWordParaphrases
      description: |
        Retrieves all paraphrases linked to a specific SpokenWord, including a commentary on why each paraphrase is connected to the original dialogue. This endpoint leverages Redis caching for improved query performance.
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the SpokenWord whose paraphrases are to be retrieved.
      responses:
        '200':
          description: A JSON array of paraphrases for the specified SpokenWord.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Paraphrase'
              examples:
                paraphrasesExample:
                  summary: Example of paraphrases linked to a SpokenWord
                  value:
                    - paraphraseId: 1
                      originalId: 1
                      text: "Hi there, how's it going?"
                      commentary: "A more casual rephrasing."
                    - paraphraseId: 2
                      originalId: 2
                      text: "I'm well, thanks for asking!"
                      commentary: "A polite response."
    post:
      summary: Create a New Paraphrase for a SpokenWord
      operationId: createSpokenWordParaphrase
      description: |
        Allows for the creation of a new paraphrase linked to a SpokenWord. Clients must provide the paraphrased text and a commentary explaining the link to the original dialogue. RedisAI provides validation and analysis for paraphrase creation.
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
          description: The unique identifier of the SpokenWord to which the paraphrase will be linked.
      requestBody:
        required: true
        description: A JSON object containing the new paraphrase's details and its link commentary.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Paraphrase'
            examples:
              createParaphraseExample:
                value:
                  originalId: 1
                  text: "Greetings, how do you do?"
                  commentary: "Formal version for a different context."
      responses:
        '201':
          description: The paraphrase has been successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Paraphrase'
              examples:
                createdParaphrase:
                  summary: Example of a created paraphrase
                  value:
                    paraphraseId: 3
                    originalId: 1
                    text: "Greetings, how do you do?"
                    commentary: "Formal version for a different context."
  /transitions:
    get:
      summary: Get a list of Transitions
      operationId: listTransitions
      description: |
        Retrieves a list of all transitions in the system, providing an overview of transition structures. This endpoint leverages Redis caching to improve query performance.
      responses:
        '200':
          description: A list of Transitions.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Transition'
              examples:
                transitionsExample:
                  summary: Example of retrieving all transitions
                  value:
                    - transitionId: 1
                      description: "Fade out to black."
                      sequence: 1
                    - transitionId: 2
                      description: "Cut to the next scene."
                      sequence: 2
    post:
      summary: Create a new Transition
      operationId: createTransition
      description: |
        Creates a new transition with provided description and sequence within the script. RedisAI middleware provides validation and recommendations during creation.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Transition'
            examples:
              createTransitionExample:
                summary: Example of creating a transition
                value:
                  description: "Dissolve to exterior shot."
                  sequence: 3
      responses:
        '201':
          description: Created Transition.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Transition'
              examples:
                createdTransition:
                  summary: Example of a created transition
                  value:
                    transitionId: 3
                    description: "Dissolve to exterior shot."
                    sequence: 3
  /transitions/{transitionId}/paraphrases:
    get:
      summary: Retrieve All Paraphrases for a Transition
      operationId: listTransitionParaphrases
      description: |
        Retrieves all paraphrases linked to a specific Transition. Redis caching helps optimize retrieval performance.
      parameters:
        - name: transitionId
          in: path
          required: true
          schema:
            type: integer
          description: Unique identifier of the Transition whose paraphrases are to be retrieved.
      responses:
        '200':
          description: A JSON array of paraphrases for the specified Transition.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Paraphrase'
              examples:
                paraphrasesExample:
                  summary: Example of paraphrases linked to a Transition
                  value:
                    - paraphraseId: 1
                      originalId: 1
                      text: "Slowly fade out to a dark scene."
                      commentary: "A detailed version for dramatic effect."
    post:
      summary: Create a New Paraphrase for a Transition
      operationId: createTransitionParaphrase
      description: |
        Allows for the creation of a new paraphrase linked to a Transition. Clients must provide the paraphrased text and commentary explaining the link to the original Transition. RedisAI provides validation and recommendations for paraphrase creation.
      parameters:
        - name: transitionId
          in: path
          required: true
          schema:
            type: integer
          description: The unique identifier of the Transition to which the paraphrase will be linked.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Paraphrase'
            examples:
              createParaphraseExample:
                summary: Example of creating a paraphrase for a transition
                value:
                  originalId: 2
                  text: "Quickly switch scenes without delay."
                  commentary: "Simplification for faster pace."
      responses:
        '201':
          description: The paraphrase has been successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Paraphrase'
              examples:
                createdParaphrase:
                  summary: Example of a created paraphrase
                  value:
                    paraphraseId: 2
                    originalId: 2
                    text: "Quickly switch scenes without delay."
                    commentary: "Simplification for faster pace."
  /generate_csound_file:
    post:
      summary: Generate Csound File
      operationId: generateCsoundFile
      description: |
        Generates a `.csd` file based on preset orchestration settings.
      responses:
        '201':
          description: Csound file successfully generated.
          content:
            application/json:
              schema:
                type: object
                properties:
                  csoundFilePath:
                    type: string
                    description: Path to the generated Csound file.
  /generate_lilypond_file:
    post:
      summary: Generate LilyPond File
      operationId: generateLilyPondFile
      description: |
        Generates a `.ly` file based on preset orchestration settings.
      responses:
        '201':
          description: LilyPond file successfully generated.
          content:
            application/json:
              schema:
                type: object
                properties:
                  lilyPondFilePath:
                    type: string
                    description: Path to the generated LilyPond file.
  /generate_midi_file:
    post:
      summary: Generate MIDI File
      operationId: generateMIDIFile
      description: |
        Generates a `.mid` file based on preset orchestration settings.
      responses:
        '201':
          description: MIDI file successfully generated.
          content:
            application/json:
              schema:
                type: object
                properties:
                  midiFilePath:
                    type: string
                    description: Path to the generated MIDI file.
  /execute_csound:
    post:
      summary: Execute Csound
      operationId: executeCsound
      description: |
        Processes an existing `.csd` file using Csound.
      requestBody:
        required: true
        description: JSON object specifying the path to the `.csd` file to process.
        content:
          application/json:
            schema:
              type: object
              properties:
                csoundFilePath:
                  type: string
                  description: Path to the existing `.csd` file for processing.
      responses:
        '200':
          description: Csound processing completed successfully.
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
                    description: Message indicating the success of Csound processing.
  /execute_lilypond:
    post:
      summary: Execute LilyPond
      operationId: executeLilyPond
      description: |
        Processes an existing `.ly` file using LilyPond.
      requestBody:
        required: true
        description: JSON object specifying the path to the `.ly` file for processing.
        content:
          application/json:
            schema:
              type: object
              properties:
                lilyPondFilePath:
                  type: string
                  description: Path to the existing `.ly` file for processing.
      responses:
        '200':
          description: LilyPond processing completed successfully.
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
                    description: Message indicating the success of LilyPond processing.

components:
  schemas:
    Script:
      type: object
      properties:
        scriptId:
          type: integer
          description: Unique identifier for the screenplay script.
        title:
          type: string
          description: Title of the screenplay script.
        description:
          type: string
          description: Brief description or summary of the screenplay script.
        author:
          type: string
          description: Author of the screenplay script.
        sequence:
          type: integer
          description: Sequence number representing the script's order or version.
      required:
        - title
        - author
    ScriptCreateRequest:
      type: object
      properties:
        title:
          type: string
        description:
          type: string
        author:
          type: string
        sequence:
          type: integer
      required:
        - title
        - author
    ScriptUpdateRequest:
      type: object
      properties:
        title:
          type: string
        description:
          type: string
        author:
          type: string
        sequence:
          type: integer
    SectionHeading:
      type: object
      description: Represents a structural element within a script, marking the beginning of a new section. Caching via Redis optimizes retrieval performance.
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
      required:
        - scriptId
        - title
        - sequence
    Action:
      type: object
      description: |
        Represents a single action within a script, detailing what happens at this step and its order relative to other actions. Caching via Redis optimizes retrieval.
      required:
        - description
        - sequence
      properties:
        actionId:
          type: integer
          format: int64
          description: The unique identifier for the Action, automatically generated upon creation.
        description:
          type: string
          description: A textual description outlining what happens in this action.
        sequence:
          type: integer
          format: int32
          description: The numerical order of the action within its script, used to organize actions sequentially.
        paraphrases:
          type: array
          items:
            $ref: '#/components/schemas/Paraphrase'
    Paraphrase:
      type: object
      description: |
        Represents a paraphrased version of a script element (e.g., action), including textual paraphrase and commentary on the connection to the original. Redis caching improves retrieval times.
      required:
        - originalId
        - text
        - commentary
      properties:
        paraphraseId:
          type: integer
          format: int64
          description: The unique identifier for the Paraphrase, automatically generated upon creation.
        originalId:
          type: integer
          description: The ID of the original action to which this paraphrase is linked.
        text:
          type: string
          description: The paraphrased text of the original action.
        commentary:
          type: string
          description: An explanatory note on why the paraphrase is linked to the original action.
    Character:
      type: object
      description: Represents a character entity within the screenplay application, containing details such as name, description, and associated script IDs. Caching via Redis optimizes retrieval performance.
      properties:
        characterId:
          type: integer
          description: Unique identifier for the character.
          example: 1
        name:
          type: string
          description: Name of the character.
          example: "Juliet"
        description:
          type: string
          description: A brief description of the character and their role within the screenplay.
          example: "The heroine of Romeo and Juliet."
        scriptIds:
          type: array
          description: Array of script IDs where the character appears, can be empty if the character is not currently part of any script.
          items:
            type: integer
          example: [2, 5, 7]
        paraphrases:
          type: array
          description: Array of paraphrases linked to this character, each with its own text and commentary.
          items:
            $ref: '#/components/schemas/Paraphrase'
      required:
        - name
    CharacterCreateRequest:
      type: object
      description: Schema defining the structure required to create a new character, including name and optionally a description.
      properties:
        name:
          type: string
          description: Name of the new character.
          example: "Juliet"
        description:
          type: string
          description: Description of the new character, outlining their role and significance.
          example: "The heroine of Romeo and Juliet."
      required:
        - name
    CharacterUpdateRequest:
      type: object
      description: Schema for updating the details of an existing character, allowing changes to the name, description, and associated script IDs.
      properties:
        name:
          type: string
          description: Updated name of the character.
          example: "Juliet Capulet"
        description:
          type: string
          description: Updated description of the character, providing a more detailed background and role in the story.
          example: "A detailed description of Juliet, including background and role in the story."
    SpokenWord:
      type: object
      description: Represents a dialogue or spoken word within the script, identified by a unique ID, text, and sequence order. Caching via Redis improves query performance.
      required:
        - dialogueId
        - text
        - sequence
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
    Transition:
      type: object
      properties:
        transitionId:
          type: integer
          description: The unique identifier for a Transition.
        description:
          type: string
          description: A description of the Transition.
        sequence:
          type: integer
          description: The sequence order of the Transition.
      required:
        - description
        - sequence
    Error:
      type: object
      description: Common error structure for the API.
      properties:
        message:
          type: string
          description: Description of the error encountered.
          example: "Required field missing: 'title'"

  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - BearerAuth: []
```

**Task:**

1. **Vapor Application:**
   - Create models, controllers, and migrations based on the OpenAPI specification.
   - Ensure all routes and endpoints are implemented as specified.
   - Use Redis for caching where applicable.
   - Implement validation and error handling as per the specification.
   - Ensure all models such as `Script`, `SectionHeading`, `Action`, `Character`, `SpokenWord`, `Transition`, `Paraphrase` are defined according to the schema provided in the OpenAPI.
   - Implement controllers for handling CRUD operations on these models.
   - Create migrations for setting up the database schema.

2. **CI/CD Pipeline:**
   - Set up GitHub Actions workflows for building, testing, and deploying the application.
   - Use the secrets manager command-line tool to manage secrets securely.
   - Ensure the pipeline includes steps for environment setup, running tests, building Docker images, and deploying to a specified environment.
   - The environment setup should include PostgreSQL, Redis, and any other services mentioned in the OpenAPI.
   - Include steps for running database migrations as part of the deployment process.

3. **Executable Shell Scripts:**
   - Provide the code in executable shell scripts that will produce the code correctly integrated into the FountainAI repository.
   - Ensure the scripts set up the project structure, create necessary files, and commit changes to the repository.
   - Scripts should include setup for directories, environment configuration, and integration with Docker Compose.

4. **Comments and Documentation:**
   - Provide comprehensive comments and documentation within the code to explain the implementation details.

### Example Shell Scripts:

**setup_project_structure.sh**
```sh
#!/bin/bash

# Ensure we're in the root directory of the existing repository
cd /path/to/your/fountainAI

# Create necessary directories for controllers, models, migrations, and tests
mkdir -p Sources/App/Controllers
mkdir -p Sources/App/Models
mkdir -p Sources/App/Migrations
mkdir -p Tests/AppTests

echo "Project structure setup complete."

# Commit the changes to the repository
git add Sources/App Tests/AppTests
git commit -m "Set up initial project structure"
git push origin development
```

**create_models.sh**
```sh
#!/bin/bash

# Navigate to the Models directory
cd Sources/App/Models

# Create models based on the OpenAPI specification
cat << 'EOF' > Script.swift
import Fluent
import Vapor

final class Script: Model, Content {
    static let schema = "scripts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "author")
    var author: String

    @Field(key: "sequence")
    var sequence: Int

    init() {}

    init(id: UUID? = nil, title: String, description: String, author: String, sequence: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.author = author
        self.sequence = sequence
    }
}
EOF

echo "Models created."

# Commit the changes to the repository
git add Script.swift
git commit -m "Create models based on OpenAPI specification"
git push origin development
```

**create_controllers.sh**
```sh
#!/bin/bash

# Navigate to the Controllers directory
cd Sources/App/Controllers

# Create controllers based on the OpenAPI specification
cat << 'EOF' > ScriptController.swift
import Vapor

struct ScriptController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let scripts = routes.grouped("scripts")
        scripts.get(use: index)
        scripts.post(use: create)
        scripts.group(":scriptID") { script in
            script.get(use: show)
            script.put(use: update)
            script.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Script]> {
        return Script.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Script> {
        let script = try req.content.decode(Script.self)
        return script.save(on: req.db).map { script }
    }

    func show(req: Request) throws -> EventLoopFuture<Script> {
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func update(req: Request) throws -> EventLoopFuture<Script> {
        let updatedScript = try req.content.decode(Script.self)
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { script in
                script.title = updatedScript.title
                script.description = updatedScript.description
                script.author = updatedScript.author
                script.sequence = updatedScript.sequence
                return script.save(on: req.db).map { script }
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { script in
                script.delete(on: req.db)
            }.transform(to: .noContent)
    }
}
EOF

echo "Controllers created."

# Commit the changes to the repository
git add ScriptController.swift
git commit -m "Create controllers based on OpenAPI specification"
git push origin development
```

**create_migrations.sh**
```sh
#!/bin/bash

# Navigate to the Migrations directory
cd Sources/App/Migrations

# Create migrations based on the OpenAPI specification
cat << 'EOF' > CreateScript.swift
import Fluent

struct CreateScript: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("scripts")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("author", .string, .required)
            .field("sequence", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("scripts").delete()
    }
}
EOF

echo "Migrations created."

# Commit the changes to

 the repository
git add CreateScript.swift
git commit -m "Create migrations based on OpenAPI specification"
git push origin development
```

**create_cicd_pipeline.sh**
```sh
#!/bin/bash

# Define the path for the custom action
ACTION_DIR=".github/actions/run-secret-manager"

# Create the directory for the custom action
mkdir -p ${ACTION_DIR}

# Create the action.yml file
cat <<EOF > ${ACTION_DIR}/action.yml
name: 'Run Secret Manager'
description: 'Action to run the Secret Manager command-line tool'
inputs:
  repo-owner:
    description: 'GitHub repository owner'
    required: true
  repo-name:
    description: 'GitHub repository name'
    required: true
  token:
    description: 'GitHub token'
    required: true
  secret-name:
    description: 'Name of the secret'
    required: true
  secret-value:
    description: 'Value of the secret'
    required: true
runs:
  using: 'docker'
  image: 'Dockerfile'
  args:
    - create
    - --repo-owner
    - \${{ inputs.repo-owner }}
    - --repo-name
    - \${{ inputs.repo-name }}
    - --token
    - \${{ inputs.token }}
    - --secret-name
    - \${{ inputs.secret-name }}
    - --secret-value
EOF

# Create the Dockerfile for the custom action
cat <<EOF > ${ACTION_DIR}/Dockerfile
# Use the official Swift image to build the app
FROM swift:5.3 as builder

# Copy the Swift package and build it
WORKDIR /app
COPY . .
RUN swift build --disable-sandbox --configuration release

# Create a slim runtime image
FROM swift:5.3-slim

# Copy the built executable
COPY --from=builder /app/.build/release/SecretManager /usr/local/bin/SecretManager

# Set the entry point
ENTRYPOINT ["SecretManager"]
EOF

echo "Custom GitHub action 'run-secret-manager' created successfully."

# Define the workflow paths
WORKFLOW_PATHS=(
  ".github/workflows/development.yml"
  ".github/workflows/testing.yml"
  ".github/workflows/staging.yml"
  ".github/workflows/production.yml"
)

# Define the workflow content
WORKFLOW_CONTENT=$(cat <<EOF
name: Manage Secrets Workflow

on:
  push:
    branches:
      - development
      - testing
      - staging
      - main

jobs:
  manage-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Run Secret Manager
        uses: ./.github/actions/run-secret-manager
        with:
          repo-owner: \${{ secrets.REPO_OWNER }}
          repo-name: \${{ secrets.REPO_NAME }}
          token: \${{ secrets.GITHUB_TOKEN }}
          secret-name: \${{ secrets.SECRET_NAME }}
          secret-value: \${{ secrets.SECRET_VALUE }}

  setup:
    needs: manage-secrets
    runs-on: ubuntu-latest
    steps:
      - name: Setup Environment
        uses: ./.github/actions/setup
        with:
          vps_ssh_key: \${{ secrets.VPS_SSH_KEY }}

  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - name: Build Project
        uses: ./.github/actions/build

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Project
        uses: ./.github/actions/deploy
        with:
          environment: staging
          vps_username: \${{ secrets.VPS_USERNAME }}
          vps_ip: \${{ secrets.VPS_IP }}
          deploy_dir: \${{ secrets.DEPLOY_DIR }}
EOF
)

# Update each workflow file
for WORKFLOW_PATH in "${WORKFLOW_PATHS[@]}"; do
  echo "${WORKFLOW_CONTENT}" > "${WORKFLOW_PATH}"
done

echo "CI/CD workflows updated successfully."