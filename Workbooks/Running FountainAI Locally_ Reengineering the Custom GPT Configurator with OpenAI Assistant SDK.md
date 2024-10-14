# Running FountainAI Locally: Reengineering the Custom GPT Configurator with OpenAI Assistant SDK

![Local Fountain](https://coach.benedikt-eickhoff.de/koken/storage/originals/40/d5/FountainAI-Locally.png)

## Objective

The goal of this guide is to outline a path for running FountainAI locally by **reengineering the Custom GPT Configurator** using the OpenAI Assistant SDK and a FastAPI client application. This approach enables developers to simulate the configurator's behavior locally, allowing for efficient testing and integration without relying on cloud-based configurations.

## Solution: Reengineering the Custom GPT Configurator Locally

To achieve this, we present a structured approach that involves two key components:

1. **The Assistant**: The GPT model configured via the OpenAI Assistant SDK to replicate the functionality of the Custom GPT Configurator.

2. **The Client**: A FastAPI application that orchestrates communication between the user, the assistant, and the FountainAI services.

By clearly defining these components, we ensure clarity in their roles and prevent misunderstandings about their interactions.

### The Assistant

- **Role**: Acts as the intelligent component that processes prompts and generates appropriate API requests based on the OpenAPI specifications.

- **Functionality**:

  - Understands FountainAI's OpenAPI specifications.

  - Generates HTTP requests and responses according to user prompts.

  - Replicates the behavior of the Custom GPT Configurator.

### The Client

- **Role**: Serves as the intermediary between the user, the assistant, and the FountainAI services.

- **Functionality**:

  - Accepts user inputs or triggers (e.g., API calls or chat messages).

  - Sends prompts to the assistant and receives responses.

  - Parses the assistant's responses to extract actionable information (e.g., HTTP request details).

  - Executes the generated API requests against the local FountainAI services.

  - Manages application logic, including routing, error handling, and logging.

  - Returns results back to the user.

### Key Advantages of This Approach

1. **Consistency with OpenAPI Specifications**: Ensures predictable behavior aligned with the expected functionality of each service.

2. **Local Simulation of the Custom GPT Configurator**: Enables testing and refinement without relying on external configurations.

3. **Modular and Scalable Development**: Provides a structure that is easy to scale and allows for programmatic testing of different scenarios.

## Step-by-Step Guide to Reengineering the Custom GPT Configurator

### Step 1: Set Up the Local Environment

- **Deploy FountainAI Services Locally**: Use Docker Compose to deploy all FountainAI microservices locally. Ensure that services like the Character Service, Action Service, and Spoken Word Service are accessible via their respective APIs.

### Step 2: Configure the Assistant via OpenAI Assistant SDK

- **Set Up the Assistant**: Configure the OpenAI Assistant SDK with your API key to interact with GPT-4.

- **Define System Prompts**: Provide system prompts that include a comprehensive understanding of FountainAI's OpenAPI specifications.

  ```
  You are an assistant that replicates the behavior of the Custom GPT Configurator for FountainAI. Use the provided OpenAPI documentation to construct appropriate HTTP requests for FountainAI services and provide responses accordingly.
  ```

### Step 3: Generate the FastAPI Client Application Using Prompts

To create the FastAPI client application that interfaces with both the assistant and the local FountainAI services, use the following prompts:

#### Prompt 1: Create the Project Structure

**Prompt**:

"Generate a shell script (`create_project_structure.sh`) that creates the project directory structure for a FastAPI client application. Include directories like `app`, `app/routers`, `app/models`, `app/schemas`, and essential files like `main.py` and `Dockerfile`. Ensure the script is callable from a main script."

**Expected Output**: `create_project_structure.sh`

Sample `create_project_structure.sh` Script:

```bash
#!/bin/bash

mkdir -p app/routers
mkdir -p app/models
mkdir -p app/schemas

touch app/main.py
touch Dockerfile

echo "Project structure created."
```

#### Prompt 2: Implement the Main FastAPI Client Application

**Prompt**:

"Generate the code for `main.py` in the `app` directory. This FastAPI client application should:

- Interact with both the assistant (via the OpenAI Assistant SDK) and the local FountainAI services.

- Include endpoints for `/api/characters`, `/api/chat`, and `/api/generate-request` as defined in the OpenAPI specification.

- Handle application logic, including routing, error handling, and integration with the assistant and services."

**Expected Output**: `app/main.py`

Sample `main.py` Code:

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import requests
import openai
import logging

app = FastAPI()

# Initialize OpenAI API key
openai.api_key = 'your_openai_api_key'

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ChatMessage(BaseModel):
    message: str

def query_assistant(prompt: str) -> str:
    response = openai.Completion.create(
        engine="text-davinci-003",
        prompt=prompt,
        max_tokens=500,
        n=1,
        stop=None,
        temperature=0.7,
    )
    return response.choices[0].text.strip()

def parse_assistant_response(response_text: str) -> dict:
    # Implement parsing logic to extract method, URL, headers, and body
    # For simplicity, assume the assistant returns a JSON with these fields
    import json
    return json.loads(response_text)

def execute_request(request_details: dict):
    method = request_details.get('method')
    url = request_details.get('url')
    headers = request_details.get('headers', {})
    data = request_details.get('body', {})
    return requests.request(method, url, headers=headers, json=data)

@app.get("/api/characters")
async def get_characters():
    try:
        prompt = "As the Custom GPT Configurator, generate an HTTP GET request to retrieve all characters from the Character Service according to the OpenAPI specification."
        assistant_response = query_assistant(prompt)
        logger.info(f"Assistant response: {assistant_response}")
        request_details = parse_assistant_response(assistant_response)
        response = execute_request(request_details)
        response.raise_for_status()
        logger.info("Successfully retrieved characters.")
        return response.json()
    except Exception as e:
        logger.error(f"Error retrieving characters: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/chat")
async def chat_with_assistant(chat_message: ChatMessage):
    prompt = f"As the Custom GPT Configurator, {chat_message.message}"
    assistant_response = query_assistant(prompt)
    return {"response": assistant_response}
```

#### Prompt 3: Create the Endpoint for Retrieving Characters

**Prompt**:

"Generate the code for the `/api/characters` endpoint in the FastAPI client application. This endpoint should:

- Use the assistant to generate an HTTP GET request to retrieve characters from the Character Service based on the OpenAPI specification.

- Parse the assistant's response to extract the request details.

- Execute the request against the local Character Service.

- Return the list of characters as the response.

Ensure proper error handling and logging are included."

**Expected Output**: Code for the `/api/characters` endpoint in `app/main.py` (already included above).

#### Prompt 4: Create the Chat Interface Endpoint

**Prompt**:

"Generate the code for the `/api/chat` endpoint in the FastAPI client application. This endpoint should:

- Accept a user message as input.

- Use the assistant to generate a response based on the message and the OpenAPI specifications.

- Return the assistant's response to the user.

Ensure that the assistant can understand and generate appropriate API requests or instructions based on the user's input."

**Expected Output**: Code for the `/api/chat` endpoint in `app/main.py` (already included above).

#### Prompt 5: Implement the Function to Query the Assistant

**Prompt**:

"Generate a function `query_assistant(prompt: str)` that:

- Takes a prompt string as input.

- Sends the prompt to the assistant via the OpenAI Assistant SDK.

- Returns the assistant's response.

Ensure that the function handles any necessary formatting and error handling."

**Expected Output**: `query_assistant` function in `app/main.py` (already included above).

#### Prompt 6: Implement Request Parsing and Execution

**Prompt**:

"Generate functions to:

- Parse the assistant's response to extract HTTP request details (method, URL, headers, body).

- Execute the HTTP request against the specified FountainAI service.

- Return the service's response.

Ensure proper error handling and logging are included."

**Expected Output**: `parse_assistant_response` and `execute_request` functions in `app/main.py` (already included above).

#### Prompt 7: Add Error Handling and Logging

**Prompt**:

"Enhance the FastAPI client application by adding detailed error handling and logging for each endpoint. Use appropriate logging levels to capture successful operations, warnings, and errors."

**Expected Output**: Updated `app/main.py` with error handling and logging (already included above).

#### Prompt 8: Create a Main Script to Run the Application

**Prompt**:

"Generate a main script (`run_app.sh`) that starts the FastAPI client application using Uvicorn. Ensure the script sets the necessary environment variables and configurations."

**Expected Output**: `run_app.sh`

Sample `run_app.sh` Script:

```bash
#!/bin/bash

export OPENAI_API_KEY='your_openai_api_key'

uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Step 4: Validate Functionality

- **Test Interactions**: Run the FastAPI client application and test the endpoints to ensure they function as expected.

  - Start the application: `bash run_app.sh`

  - Send a GET request to `http://localhost:8000/api/characters`.

  - Verify that the assistant generates the correct request to the Character Service.

  - Ensure the list of characters is returned successfully.

- **Debug and Refine**: If any issues are encountered, refine the prompts and code accordingly.

## Conclusion

By following this guide and using the provided prompts, developers can reengineer the Custom GPT Configurator locally using the OpenAI Assistant SDK and a FastAPI client application. This approach allows for efficient local development and testing of FountainAI, ensuring that interactions are consistent with the OpenAPI specifications and the configurator's intended behavior.

- **The Assistant**: Acts as the intelligent component generating API requests.

- **The Client**: Manages application logic and orchestrates communication between the user, the assistant, and the FountainAI services.

## Next Steps

1. **Set Up the Local Environment**: Ensure all FountainAI microservices are running locally using Docker Compose.

2. **Use the Prompts to Generate the FastAPI Client Application**: Apply the prompts provided to create the client app and its components.

3. **Test and Refine**: Run the application and test the endpoints, refining the code as necessary.

4. **Expand Functionality**: Add additional endpoints and features to cover more of FountainAI's capabilities.

## Appendix: OpenAPI Specification for the Local Client Application

```yaml
openapi: 3.1.0
info:
  title: FountainAI Local Client API
  version: 1.0.0
  description: |
    This OpenAPI specification defines the endpoints for the local FastAPI client application that reengineers the Custom GPT Configurator by interacting with FountainAI services via the OpenAI Assistant SDK.
servers:
  - url: http://localhost:8000
    description: Local development server
paths:
  /api/characters:
    get:
      summary: Retrieve characters
      description: |
        Retrieve a list of characters from the Character Service using the assistant to generate the request, simulating the Custom GPT Configurator.
      responses:
        '200':
          description: A list of characters
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Character'
        '400':
          description: Bad request
        '500':
          description: Internal server error
  /api/chat:
    post:
      summary: Chat with the assistant
      description: |
        Interact with the assistant using natural language, simulating the behavior of the Custom GPT Configurator.
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  description: The user's message
              required:
                - message
      responses:
        '200':
          description: Assistant's response
          content:
            application/json:
              schema:
                type: object
                properties:
                  response:
                    type: string
                    description: The assistant's reply
        '400':
          description: Bad request
        '500':
          description: Internal server error
components:
  schemas:
    Character:
      type: object
      properties:
        id:
          type: string
          description: Unique identifier for the character
        name:
          type: string
          description: The character's name
```

---

By introducing the client as a distinct functional concept and clearly defining its role alongside the assistant, we prevent misunderstandings about their interactions. This ensures that developers can effectively reengineer the Custom GPT Configurator and run FountainAI locally with confidence.

