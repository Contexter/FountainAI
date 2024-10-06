# FountainAI FastAPI Guide: A Modular Shell Script Approach for Building Applications with ChatGPT-4

> Say "I want!" in time

## Introduction
Developing applications can often be a complex and error-prone process, especially when working with specific requirements like an OpenAPI specification. Using ChatGPT-4 with Canvas offers a unique opportunity to accelerate and streamline this process. This guide outlines a productive approach for building a FastAPI application, detailing the advantages of iterative, prompt-driven development and breaking tasks into manageable steps. It also highlights how this method offers an ideal balance between automation and human oversight, making application development more efficient and reliable.

## The Problem
When attempting to develop a complex application, it is easy to miss key details and fail to meet specifications comprehensively. Given an extensive OpenAPI specification, ensuring that every endpoint, operation, summary, and functionality matches precisely can be challenging. A direct approach might lead to the omission of important attributes, like `operationId`, and the use of placeholders, which results in an incomplete product.

## Solution: A Structured, Controlled Prompt Sequence
To overcome these challenges, we propose breaking down the development process into a controlled sequence of prompts, each addressing specific aspects of the application based on the provided OpenAPI specification. This method offers the following key advantages:

1. **Granular Development**: Each part of the application is developed independently in response to targeted prompts. This makes it easier to focus on fulfilling the specific requirements and avoid missing details.

2. **Consistent Use of the OpenAPI Specification**: The OpenAPI spec serves as the single source of truth. All prompts and development steps reference the spec, ensuring that the final implementation is always aligned with the required functionalities, schemas, and operations.

3. **Iterative Refinement**: ChatGPT-4 with Canvas allows users to refine and adjust the generated output incrementally, improving quality and aligning closely with the desired outcome.

### History and Why This Works So Well
Historically, AI-driven development tools have suffered from issues of inconsistency and incomplete implementation. Early conversational AI models could assist in coding but often struggled with larger, multi-step development tasks, resulting in fragments that did not fit well together.

ChatGPT-4 with Canvas represents a significant leap forward. With a persistent workspace, Canvas helps maintain the continuity needed for complex projects. Unlike earlier models, which lost context between conversations, Canvas allows developers to build applications comprehensively by saving progress and iteratively enhancing each piece. This approach provides a significant productivity boost, making it possible to deliver complex applications in a controlled and reliable way.

## Modular Shell Script-Based Approach for Building an Application
To create a fully functional, compliant FastAPI application for FountainAI, we break the process down into a generalized series of prompts that guide the development step-by-step based on the OpenAPI specifications. Each step fully leverages the OpenAPI specifications as the source of truth, ensuring accuracy, consistency, and inclusion of all custom fields.

Each step produces callable shell scripts that generate the specific part of the application, ensuring modularity and the ability to orchestrate the entire process through a main script.

### Step 1: Define Project Structure
- **Prompt**: "Generate a shell script (`create_directory_structure.sh`) that creates the complete project directory structure for an application based on the OpenAPI specification. Include folders such as `app`, `routers`, `models`, `schemas`, `utils`, `tests`, as well as essential files like `Dockerfile`, `docker-compose.yaml`, and configuration files for AWS Copilot. Ensure the script is callable from a main script."
- **Output**: `create_directory_structure.sh`
- **Goal**: Set up the entire file structure needed for further development, including cloud deployment considerations and reflecting the individual services in the OpenAPI.

### Step 2: Create API Entry Point and Metadata
- **Prompt**: "Generate a shell script (`create_main_app.sh`) that creates the main application entry point in `app/main.py` using the OpenAPI specification for metadata. Include the `title`, `description`, `version`, and any custom extensions (`x-*`) as described in the OpenAPI spec. Ensure the server URLs match the staging and production environments defined in the OpenAPI. Ensure the script is callable from a main script."
- **Output**: `create_main_app.sh`
- **Goal**: Ensure that the API has accurate metadata, including any custom fields, laying the foundation for correct documentation.

### Step 3: Generate Data Models for Schema Validation
- **Prompt**: "Generate a shell script (`create_schemas.sh`) that creates all data models in `schemas/` corresponding to the request and response schemas described in the OpenAPI specification. Include every field, type, and required property. Ensure that custom extensions (`x-*`) are included as comments or metadata. Integrate SQLite as the database for persistence, with Typesense for search synchronization where applicable. Ensure the script is callable from a main script."
- **Output**: `create_schemas.sh`
- **Goal**: Ensure that request and response validation matches the OpenAPI specification exactly, including any extensions, and that the data is ready for persistence and search.

### Step 4: Implement API Routes Using OpenAPI Specifications
- **Prompt**: "Generate a shell script (`create_routers.sh`) that creates the API routes in `routers/` with correct `operationId`, `summary`, `description`, response models, and custom extensions (`x-*`) as described in the OpenAPI spec. Ensure the logic adheres to the requirements for functionality described. For each route, implement endpoints like `/performers`, `/characters`, `/scripts`, `/paraphrases`, and `/lines` as specified. Utilize the Central Sequence Service where sequence management is required. Ensure the script is callable from a main script."
- **Output**: `create_routers.sh`
- **Goal**: Implement each route comprehensively, making sure all aspects (summaries, descriptions, custom fields, etc.) match the OpenAPI, including the use of external services like the Central Sequence Service.

### Step 5: Create Database Models for Data Representation
- **Prompt**: "Generate a shell script (`create_models.sh`) that creates the database models in `models/` to represent the entities defined in the OpenAPI specification. Include all fields, types, and relationships as specified. Document any relevant extensions (`x-*`). Set up SQLite for persistence and ensure data is synchronized with Typesense where specified. Ensure the script is callable from a main script."
- **Output**: `create_models.sh`
- **Goal**: Persist the application data in a structured way that corresponds to the OpenAPI requirements, including custom extensions and synchronization with Typesense.

### Step 6: Define Utility Functions for Database Access and Syncing
- **Prompt**: "Generate a shell script (`create_utils.sh`) that sets up utility functions in `utils/` for database access and Typesense syncing. Create a `get_db()` function for accessing the database in API routes and a `sync_to_typesense()` utility for syncing changes. Ensure the script is callable from a main script."
- **Output**: `create_utils.sh`
- **Goal**: Facilitate database access, ensuring consistency and ease of reuse, and include mechanisms for search synchronization with Typesense, ensuring data consistency between SQLite and Typesense.

### Step 7: Generate Dockerfile for Containerization
- **Prompt**: "Generate a shell script (`create_dockerfile.sh`) that creates a `Dockerfile` to build the application using the appropriate language and version. Set it up to run the application using a server suitable for the application type. Ensure compatibility with the OpenAPI specification and prepare for deployment using AWS Copilot. Ensure the script is callable from a main script."
- **Output**: `create_dockerfile.sh`
- **Goal**: Enable easy containerization of the application, readying it for deployment using AWS Copilot.

### Step 8: Create Docker Compose Configuration
- **Prompt**: "Generate a shell script (`create_docker_compose.sh`) that writes a `docker-compose.yaml` file to deploy the application with a database. Include environment variables for configuration and ensure compatibility with both development and production setups. Ensure the script is callable from a main script."
- **Output**: `create_docker_compose.sh`
- **Goal**: Simplify the deployment of the entire stack, including any dependencies, and prepare for cloud deployment.

### Step 9: Integrate AWS Copilot for Deployment
- **Prompt**: "Generate a shell script (`create_copilot_configs.sh`) that generates AWS Copilot configuration files (`copilot/`) to deploy the application to AWS. Define services, environments, and pipelines that match the OpenAPI requirements, including staging and production setups. Ensure the script is callable from a main script."
- **Output**: `create_copilot_configs.sh`
- **Goal**: Automate deployment using AWS Copilot to streamline infrastructure management, enabling easy cloud deployment and scaling for each service.

### Step 10: Create Main Shell Script to Orchestrate All Steps
- **Prompt**: "Generate a main shell script (`generate_full_api.sh`) that calls each of the individual creation shell scripts in sequence to generate the entire Character Management API. Ensure that all steps are executed in the correct order and provide feedback for each completed step."
- **Output**: `generate_full_api.sh`
- **Goal**: Orchestrate the entire code generation process by calling each of the individual scripts in the correct order, ensuring the complete project is generated with minimal manual intervention.

### Step 11: Add Detailed Logging and Error Handling
- **Prompt**: "Generate a shell script (`add_logging_and_error_handling.sh`) that adds detailed logging and error handling for each endpoint. Ensure logs are added for successful operations, errors, and synchronization activities. Use the appropriate logging library to capture these details in the application code. Make sure the script is callable from the main script."
- **Output**: `add_logging_and_error_handling.sh`
- **Goal**: Make the application easy to monitor and debug by adding comprehensive logging and error handling. Ensure the main script can call this to integrate logging into the generated application.

### Step 12: Write Unit Tests for Endpoints and Syncing
- **Prompt**: "Generate a shell script (`create_tests.sh`) that writes unit tests in the `tests/` directory for each endpoint. Ensure that tests cover all expected scenarios, including edge cases and validation errors. Include tests for SQLite and Typesense synchronization as well. Ensure the script is callable from a main script."
- **Output**: `create_tests.sh`
- **Goal**: Validate that each endpoint works correctly and that all functionalities align with the OpenAPI specification, including synchronization between SQLite and Typesense.

### Step 13: Execute End-to-End Testing and Refinement
- **Prompt**: "Generate a shell script (`run_e2e_tests.sh`) that runs end-to-end tests for the entire Character Management API, ensuring the correct functioning of each component, including API endpoints, database operations, and Typesense synchronization. Ensure the script is callable from the main script."
- **Output**: `run_e2e_tests.sh`
- **Goal**: Ensure that the entire application functions as expected, providing the intended features with no errors or inconsistencies.

### Conclusion
This guide presented a modular, shell script-based approach for building a FastAPI application for FountainAI using ChatGPT-4 with Canvas. By breaking down the development process into discrete, manageable steps, each producing callable shell scripts, the approach ensures flexibility, ease of debugging, and accuracy. The main shell script orchestrates the entire process, enabling automated, error-free code generation from start to finish.

With these shell scripts and prompts, developers can maintain a structured development process that leverages the full capabilities of ChatGPT-4, ensuring compliance with OpenAPI specifications and providing a clear, repeatable workflow. This approach not only accelerates development but also reduces the risk of human error, resulting in a robust and production-ready FastAPI application.

