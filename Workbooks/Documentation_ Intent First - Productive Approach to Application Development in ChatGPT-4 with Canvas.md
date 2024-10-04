# Documentation: Prompt First - A Productive Approach to Application Development in ChatGPT-4 with Canvas

>No text without context
Say "I want (...) " first in time
Before providing the single source of truth


## Introduction
Developing applications can often be a complex and error-prone process, especially when working with specific requirements like an OpenAPI specification. Using ChatGPT-4 with Canvas offers a unique opportunity to accelerate and streamline this process. This documentation outlines a productive approach for building a FastAPI application, detailing the advantages of iterative, prompt-driven development and breaking tasks into manageable steps. It also touches upon the history of productivity in conversational AI, highlighting how this method offers an ideal balance between automation and human oversight.

## The Problem
When attempting to develop a complex application like the FountainAI "Central Sequence Service," it is easy to miss key details and fail to meet specifications comprehensively. Given an extensive OpenAPI specification, ensuring that every endpoint, operation, summary, and functionality matches precisely can be challenging. A direct approach might lead to the omission of important attributes, like `operationId`, and the use of placeholders, which results in an incomplete product.

## Solution: A Structured, Controlled Prompt Sequence
To overcome these challenges, we propose breaking down the development process into a controlled sequence of prompts, each addressing specific aspects of the application based on the provided OpenAPI specification. This method offers the following key advantages:

1. **Granular Development**: Each part of the application is developed independently in response to targeted prompts. This makes it easier to focus on fulfilling the specific requirements and avoid missing details.

2. **Consistent Use of the OpenAPI Specification**: The OpenAPI spec serves as the single source of truth. All prompts and development steps reference the spec, ensuring that the final implementation is always aligned with the required functionalities, schemas, and operations.

3. **Iterative Refinement**: ChatGPT-4 with Canvas allows users to refine and adjust the generated output incrementally, improving quality and aligning closely with the desired outcome.

### History and Why This Works So Well
Historically, AI-driven development tools have suffered from issues of inconsistency and incomplete implementation. Early conversational AI models could assist in coding but often struggled with larger, multi-step development tasks, resulting in fragments that did not fit well together.

ChatGPT-4 with Canvas represents a significant leap forward. With a persistent workspace, Canvas helps maintain the continuity needed for complex projects. Unlike earlier models, which lost context between conversations, Canvas allows developers to build applications comprehensively by saving progress and iteratively enhancing each piece. This approach provides a significant productivity boost, making it possible to deliver complex applications in a controlled and reliable way.

## Steps to Building an Application Using This Approach
To create a fully functional, compliant FastAPI application, we break the process down into a sequence of prompts that are each based on a step of the OpenAPI specification.

### Step 1: Define Project Structure and Set Up Initial Files
The first prompt is designed to generate the complete folder structure, ensuring all components (`app`, `routers`, `models`, etc.) are properly defined, and that the file skeletons exist for further refinement.

### 2. API Entry Point and Metadata from OpenAPI
The second prompt focuses on setting up the FastAPI app in `app/main.py`. This includes using the `title`, `description`, and `version` from the OpenAPI specification to ensure compliance with provided requirements.

### 3. Create Pydantic Models for Schema Validation
The next prompt instructs ChatGPT to generate all Pydantic models for request and response validation. This ensures data integrity, with all fields, types, and required properties matching the OpenAPI specification.

### 4. Implement API Routes Using OpenAPI Details
API endpoints are created using a prompt that strictly adheres to the OpenAPI spec. Summaries, descriptions, operation IDs, and response models are all implemented based on the given OpenAPI. This guarantees that the final API will match the documentation precisely.

### 5. Define SQLAlchemy Models for Database Interaction
The database model prompt focuses on creating entities as defined in the specification. This ensures proper mapping between the data structure used in API requests and what is stored persistently.

### 6. Automate Directory and File Creation with a Shell Script
A shell script is generated to automate directory and file creation, including all components of the application. The script includes detailed comments and is designed to be idempotent—ensuring that running it multiple times won’t duplicate or overwrite existing structures inappropriately.

### 7. Containerization and Deployment Configuration
The Dockerfile and `docker-compose.yaml` are created, allowing for easy containerized deployment. This stage makes sure the environment matches both development and production needs and provides scalability options.

### 8. Add Logging and Error Handling
Another prompt is used to include detailed logging and error handling throughout the API endpoints. This ensures that the application is not only functional but also maintainable and easy to debug.

### 9. Testing Suite for Validation
The final set of prompts involves generating unit tests for the API endpoints, using `pytest` to validate that all scenarios—including edge cases—are handled correctly.

## Why This Approach Is Effective in ChatGPT-4 with Canvas
1. **Controlled Complexity**: By breaking down a complex specification into multiple focused prompts, this approach keeps each step manageable and ensures accuracy.

2. **Maintained Context**: Canvas allows the application to be built incrementally while preserving full context. This enables continuity, which is crucial for meeting all requirements.

3. **Iterative Refinement**: With Canvas, users can revisit each step, refine, and build on it, ensuring a complete implementation that adheres to specifications without compromising quality.

4. **Efficiency and Productivity**: The traditional way of developing complex software involves a lot of back-and-forth between documentation and code. Using ChatGPT-4 with Canvas accelerates this process by allowing for prompt-driven development that is directly influenced by the specification, reducing the risk of inconsistencies.

## Conclusion
The proposed approach provides a systematic method for generating a FastAPI application using ChatGPT-4 with Canvas, based on an OpenAPI specification. By breaking down the development into manageable steps that directly reference the spec, we ensure accuracy, completeness, and alignment with the initial requirements.

This approach is not just about generating code but about transforming how we work with AI, fostering a productive partnership where developers guide AI incrementally to achieve comprehensive results. With the capabilities of ChatGPT-4 and the continuity that Canvas provides, it's now possible to build reliable and production-ready software more efficiently than ever before.

## Specific Prompt Sequence for a True Creation Session

To ensure that the application is built fully in accordance with the OpenAPI specification, here is a detailed series of prompts that can be used in a true creation session. This sequence is designed for you to take control of the development process, expressing your intent and guiding the AI at each stage. Take your time with each prompt, and use the AI's assistance to build a robust application. Remember, each step is intended to fully leverage the OpenAPI specification as the source of truth, ensuring accuracy and consistency throughout the development.

### Initial Prompt: Set the Context
- **Prompt**: "I want to build a FastAPI application based on the OpenAPI specification I will provide. This specification should serve as the source of truth for the entire development process. Once pasted, I'd like to proceed step-by-step, generating each component of the application in alignment with the provided spec, ensuring full compliance and consistency throughout."
- **Goal**: Establish a clear intention for the development session and ensure the AI understands that the OpenAPI specification is the foundation for all subsequent prompts.

### 1. Define Project Structure
- **Prompt**: "Generate the complete project directory structure for a FastAPI application based on an OpenAPI specification. Include folders such as `app`, `routers`, `models`, `schemas`, `utils`, `tests`, as well as essential files like `Dockerfile`, `docker-compose.yaml`, and `requirements.txt`."
- **Goal**: Set up the entire file structure needed for further development.

### Step 2: Create API Entry Point and Metadata
- **Prompt**: "Create a FastAPI application entry point in `app/main.py` that uses the OpenAPI specification for metadata. Include the `title`, `description`, and `version` as described in the OpenAPI spec."
- **Goal**: Ensure that the API has accurate metadata, laying the foundation for correct documentation.

### Step 3: Generate Pydantic Models for Schema Validation
- **Prompt**: "Generate all Pydantic models in `schemas/sequence.py` that correspond to the request and response schemas described in the OpenAPI specification. Include every field, type, and required property."
- **Goal**: Ensure that request and response validation matches the OpenAPI specification exactly.

### Step 4: Implement API Routes Using OpenAPI Specifications
- **Prompt**: "In `routers/sequence.py`, implement the API routes (`/sequence`, `/sequence/reorder`, `/sequence/version`) with correct `operationId`, `summary`, `description`, and response models as described in the OpenAPI spec. Ensure the logic adheres to the requirements for sequence number generation, reordering, and version creation."
- **Goal**: Implement each route comprehensively, making sure all aspects (summaries, descriptions, etc.) match the OpenAPI.

### Step 5: Create SQLAlchemy Models for Database Representation
- **Prompt**: "Create a SQLAlchemy model named `Sequence` in `models/sequence.py` that represents the entities defined in the OpenAPI specification. Include fields such as `elementType`, `elementId`, and `sequenceNumber`."
- **Goal**: Persist the application data in a structured way that corresponds to the OpenAPI requirements.

### Step 6: Define Utility Functions for Database Access
- **Prompt**: "Set up the database connection utilities in `utils/db.py` using SQLAlchemy. Create a `get_db()` function that can be used as a dependency for accessing the database in API routes."
- **Goal**: Facilitate database access, ensuring consistency and ease of reuse.

### Step 7: Write Deployment Shell Script
- **Prompt**: "Write a deployment shell script (`deployment.sh`) that automates the creation of the necessary project files and directories. The script should be idempotent and should fill in all boilerplate code for initial setup."
- **Goal**: Make deployment easy, consistent, and repeatable, ensuring that re-running the script does not lead to issues.

### Step 8: Generate Dockerfile for Containerization
- **Prompt**: "Create a `Dockerfile` that builds the FastAPI application using Python 3.11. Set it up to run the application using Uvicorn."
- **Goal**: Enable easy containerization of the application, readying it for deployment.

### Step 9: Create Docker Compose Configuration
- **Prompt**: "Write a `docker-compose.yaml` file to deploy the FastAPI application with a database. Include environment variables for configuration and ensure compatibility with both development and production setups."
- **Goal**: Simplify the deployment of the entire stack, including any dependencies.

### Step 10: Add Detailed Logging and Error Handling
- **Prompt**: "Add detailed logging to all endpoints in `routers/sequence.py` using Python's `logging` module. Implement error handling to match the responses described in the OpenAPI specification."
- **Goal**: Make the application easy to monitor and debug, ensuring errors are reported in a clear and informative way.

### Step 11: Write Unit Tests for Endpoints
- **Prompt**: "Create unit tests in `tests/test_sequence.py` for each endpoint, using `pytest`. Make sure to test all expected scenarios, including edge cases and potential errors, as outlined in the OpenAPI specification."
- **Goal**: Validate that each endpoint works correctly and that all functionalities align with the specifications.

### Step 12: Execute End-to-End Testing and Refinement
- **Prompt**: "Perform end-to-end testing of the entire application, ensuring that all functionalities, including logging, database interactions, and API responses, align with the OpenAPI specification. Refine as necessary based on testing results."
- **Goal**: Ensure that the entire application functions as expected, providing the intended features with no errors or inconsistencies.

## Next Steps
- **Define Specific Prompts**: Use the detailed prompt sequence provided above to begin building each component of your application, starting with the project structure.
- **Iterate and Refine**: Use the Canvas to iteratively refine each component, ensuring all aspects of the OpenAPI specification are implemented correctly.
- **Test and Deploy**: Use the generated Docker and test configurations to deploy and validate the application.
