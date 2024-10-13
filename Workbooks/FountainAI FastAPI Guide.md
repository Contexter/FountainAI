# FountainAI FastAPI Guide
> Prompting a Modular Shell Script Approach for Building FastAPI Applications with ChatGPT-4

## Introduction

Developing applications can often be a complex and error-prone process, especially when working with specific requirements like an OpenAPI specification. Given an extensive OpenAPI specification, ensuring that every endpoint, operation, summary, and functionality matches precisely can be challenging. A direct approach might lead to the omission of important attributes, like `operationId`, and the use of placeholders, which results in an incomplete product.

Using ChatGPT-4 with Canvas offers a unique opportunity to accelerate and streamline this process. This guide outlines a productive approach for building a FastAPI application, detailing the advantages of iterative, prompt-driven development and breaking tasks into manageable steps. It also highlights how this method offers an ideal balance between automation and human oversight, making application development more efficient and reliable.

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

### Step 4: Create Database Models for Data Representation

- **Prompt**: "Generate a shell script (`create_models.sh`) that creates the database models in `models/` to represent the entities defined in the OpenAPI specification. Include all fields, types, and relationships as specified. Document any relevant extensions (`x-*`). Set up SQLite for persistence and ensure data is synchronized with Typesense where specified. Ensure the script is callable from a main script."
- **Output**: `create_models.sh`
- **Goal**: Persist the application data in a structured way that corresponds to the OpenAPI requirements, including custom extensions and synchronization with Typesense.

### Step 5: Define Utility Functions for Database Access and Syncing

- **Prompt**: "Generate a shell script (`create_utils.sh`) that sets up utility functions in `utils/` for database access and Typesense syncing. Create a `get_db()` function for accessing the database in API routes and a `sync_to_typesense()` utility for syncing changes. Ensure the script is callable from a main script."
- **Output**: `create_utils.sh`
- **Goal**: Facilitate database access, ensuring consistency and ease of reuse, and include mechanisms for search synchronization with Typesense, ensuring data consistency between SQLite and Typesense.

### Step 6: Implement API Security

- **Prompt**: "Generate a shell script (`add_security.sh`) that adds API key security to all routes in the FastAPI application. The security implementation must align with the OpenAPI specification provided, including defining an API key header (`X-API-KEY`) and applying it to all routes in the application. Ensure the script is callable from a main script."
- **Output**: `add_security.sh`
- **Goal**: Implement API key security to ensure compliance with the OpenAPI specification, securing all endpoints from unauthorized access.

### Step 7: Implement API Routes Using OpenAPI Specifications

- **Prompt**: "Generate a shell script (`create_routers.sh`) that creates the API routes in `routers/` with correct `operationId`, `summary`, `description`, response models, and custom extensions (`x-*`) as described in the OpenAPI spec. Ensure the logic adheres to the requirements for functionality described.  Utilize the Central Sequence Service where sequence management is required. Ensure the script is callable from a main script."
- **Output**: `create_routers.sh`
- **Goal**: Implement each route comprehensively, making sure all aspects (summaries, descriptions, custom fields, etc.) match the OpenAPI, including the use of external services like the Central Sequence Service.

### Step 8: Generate Dockerfile for Containerization

- **Prompt**: "Generate a shell script (`create_dockerfile.sh`) that creates a `Dockerfile` to build the application using the appropriate language and version. Set it up to run the application using a server suitable for the application type. Ensure compatibility with the OpenAPI specification and prepare for deployment using AWS Copilot. Ensure the script is callable from a main script."
- **Output**: `create_dockerfile.sh`
- **Goal**: Enable easy containerization of the application, readying it for deployment using AWS Copilot.

### Step 9: Create Docker Compose Configuration

- **Prompt**: "Generate a shell script (`create_docker_compose.sh`) that writes a `docker-compose.yaml` file to deploy the application with a database. Include environment variables for configuration and ensure compatibility with both development and production setups. Ensure the script is callable from a main script."
- **Output**: `create_docker_compose.sh`
- **Goal**: Simplify the deployment of the entire stack, including any dependencies, and prepare for cloud deployment.

### Step 10: Integrate AWS Copilot for Deployment

- **Prompt**: "Generate a shell script (`create_copilot_configs.sh`) that generates AWS Copilot configuration files (`copilot/`) to deploy the application to AWS. Define services, environments, and pipelines that match the OpenAPI requirements, including staging and production setups. Ensure the script is callable from a main script."
- **Output**: `create_copilot_configs.sh`
- **Goal**: Automate deployment using AWS Copilot to streamline infrastructure management, enabling easy cloud deployment and scaling for each service.

### Step 11: Create Main Shell Script to Orchestrate All Steps

- **Prompt**: "Generate a main shell script (`generate_full_api.sh`) that calls each of the individual creation shell scripts in sequence to generate the entire API. Ensure that all steps are executed in the correct order and provide feedback for each completed step."
- **Output**: `generate_full_api.sh`
- **Goal**: Orchestrate the entire code generation process by calling each of the individual scripts in the correct order, ensuring the complete project is generated with minimal manual intervention.

### Step 12: Add Detailed Logging and Error Handling

- **Prompt**: "Generate a shell script (`add_logging_and_error_handling.sh`) that adds detailed logging and error handling for each endpoint. Ensure logs are added for successful operations, errors, and synchronization activities. Use the appropriate logging library to capture these details in the application code. Make sure the script is callable from the main script."
- **Output**: `add_logging_and_error_handling.sh`
- **Goal**: Make the application easy to monitor and debug by adding comprehensive logging and error handling. Ensure the main script can call this to integrate logging into the generated application.

### Step 13: Execute End-to-End Testing and Refinement

- **Prompt**: "Generate a shell script (`run_e2e_tests.sh`) that runs end-to-end tests for the entire API, ensuring the correct functioning of each component, including API endpoints, database operations, and Typesense synchronization. Ensure the script is callable from the main script."
- **Output**: `run_e2e_tests.sh`
- **Goal**: Ensure that the entire application functions as expected, providing the intended features with no errors or inconsistencies.

### Step 14: Perform Security Scan and Apply Best Practices

- **Prompt**: "Generate a shell script (`perform_security_scan.sh`) that runs a security scan on the entire FastAPI application to identify potential vulnerabilities. Apply best practices to address these vulnerabilities, including updating configurations, adding missing security measures, and ensuring compliance with industry standards. Ensure the script is callable from the main script."
- **Output**: `perform_security_scan.sh`
- **Goal**: Ensure that the application meets security best practices and addresses any vulnerabilities discovered during the end-to-end testing phase.

### Step 15: Verify OpenAPI Specification Match

- **Prompt**: "After running end-to-end tests, raise the question: 'Does the resulting OpenAPI specification exactly match the input OpenAPI - the one we based the code creation process on? If not, identify where and why it does not match, and ask for suggestions on exactly meeting this requirement of an exact match.' Ensure this analysis is documented for further refinement of the FastAPI app."
- **Output**: Documentation of OpenAPI compliance analysis
- **Goal**: Ensure that the final OpenAPI specification is an exact match with the input OpenAPI to guarantee compliance and completeness.

## Conclusion

The modular approach outlined in this guide provides a structured and effective method for building a fully functional FastAPI application for FountainAI. By leveraging a series of targeted shell scripts, each step is made modular and callable, ensuring a transparent and easily adjustable development process. This iterative methodology guarantees that every aspect of the application aligns with the OpenAPI specification, providing consistency and reducing errors.

By integrating API security, logging, error handling, and focusing on security best practices, the resulting application is robust, secure, and production-ready. The combination of ChatGPT-4's AI-driven automation with human oversight throughout the process allows for a significant productivity boost, ultimately making the application development experience efficient, dependable, and comprehensive.

## Appendix: Quick Reference Table

| Tool/Framework        | Documentation Link                                             |
| --------------------- | -------------------------------------------------------------- |
| FastAPI               | [FastAPI Documentation](https://fastapi.tiangolo.com)          |
| OpenAPI Specification | [OpenAPI Specification](https://swagger.io/specification)      |
| SQLite                | [SQLite Documentation](https://www.sqlite.org/docs.html)       |
| Typesense             | [Typesense Documentation](https://typesense.org/docs/)         |
| AWS Copilot           | [AWS Copilot Documentation](https://aws.github.io/copilot-cli) |
| Docker                | [Docker Documentation](https://docs.docker.com)                |
| Pytest                | [Pytest Documentation](https://docs.pytest.org/en/stable/)     |