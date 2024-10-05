# Documentation: Prompt First - A Productive Approach to Application Development in ChatGPT-4 with Canvas

> No text without context
Say "I want (...) " first in time
Before providing the single source of truth

## Introduction
Developing applications can often be a complex and error-prone process, especially when working with specific requirements like an OpenAPI specification. Using ChatGPT-4 with Canvas offers a unique opportunity to accelerate and streamline this process. This documentation outlines a productive approach for building a FastAPI application, detailing the advantages of iterative, prompt-driven development and breaking tasks into manageable steps. It also highlights how this method offers an ideal balance between automation and human oversight, making application development more efficient and reliable.

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

## Generalized Prompt Sequence for Building an Application
To create a fully functional, compliant FastAPI application, we break the process down into a generalized series of prompts that guide the development step-by-step based on the OpenAPI specification. Each step fully leverages the OpenAPI specification as the source of truth, ensuring accuracy, consistency, and inclusion of all custom fields.

### Initial Prompt: Set the Context
- **Prompt**: "I want to build an application based on the OpenAPI specification I will provide. This specification should serve as the source of truth for the entire development process, including all custom extensions (`x-*`). Once pasted, I'd like to proceed step-by-step, generating each component of the application in alignment with the provided spec, ensuring full compliance and consistency throughout."
- **Goal**: Establish a clear intention for the development session and ensure the AI understands that the OpenAPI specification, including custom extensions, is the foundation for all subsequent prompts.

### Step 1: Define Project Structure
- **Prompt**: "Generate the complete project directory structure for an application based on an OpenAPI specification. Include folders such as `app`, `routers`, `models`, `schemas`, `utils`, `tests`, as well as essential files like `Dockerfile`, `docker-compose.yaml`, and `requirements.txt`."
- **Goal**: Set up the entire file structure needed for further development.

### Step 2: Create API Entry Point and Metadata
- **Prompt**: "Create an application entry point in `app/main.py` that uses the OpenAPI specification for metadata. Include the `title`, `description`, `version`, and any custom extensions (`x-*`) as described in the OpenAPI spec."
- **Goal**: Ensure that the API has accurate metadata, including any custom fields, laying the foundation for correct documentation.

### Step 3: Generate Data Models for Schema Validation
- **Prompt**: "Generate all data models in `schemas/` that correspond to the request and response schemas described in the OpenAPI specification. Include every field, type, and required property. Ensure that custom extensions (`x-*`) are included as comments or metadata."
- **Goal**: Ensure that request and response validation matches the OpenAPI specification exactly, including any extensions.

### Step 4: Implement API Routes Using OpenAPI Specifications
- **Prompt**: "In `routers/`, implement the API routes with correct `operationId`, `summary`, `description`, response models, and custom extensions (`x-*`) as described in the OpenAPI spec. Ensure the logic adheres to the requirements for functionality described."
- **Goal**: Implement each route comprehensively, making sure all aspects (summaries, descriptions, custom fields, etc.) match the OpenAPI.

### Step 5: Create Database Models for Data Representation
- **Prompt**: "Create database models in `models/` that represent the entities defined in the OpenAPI specification. Include all fields, types, and relationships as specified. Document any relevant extensions (`x-*`)."
- **Goal**: Persist the application data in a structured way that corresponds to the OpenAPI requirements, including custom extensions.

### Step 6: Define Utility Functions for Database Access
- **Prompt**: "Set up the database connection utilities in `utils/db.py`. Create a `get_db()` function that can be used as a dependency for accessing the database in API routes."
- **Goal**: Facilitate database access, ensuring consistency and ease of reuse.

### Step 7: Generate Dockerfile for Containerization
- **Prompt**: "Create a `Dockerfile` that builds the application using the appropriate language and version. Set it up to run the application using a server suitable for the application type. Ensure compatibility with the OpenAPI specification."
- **Goal**: Enable easy containerization of the application, readying it for deployment.

### Step 8: Create Docker Compose Configuration
- **Prompt**: "Write a `docker-compose.yaml` file to deploy the application with a database. Include environment variables for configuration and ensure compatibility with both development and production setups."
- **Goal**: Simplify the deployment of the entire stack, including any dependencies.

### Step 9: Add Detailed Logging and Error Handling
- **Prompt**: "Add detailed logging to all endpoints in `routers/` using the appropriate logging library. Implement error handling to match the responses described in the OpenAPI specification. Ensure any custom extensions related to error handling are included."
- **Goal**: Make the application easy to monitor and debug, ensuring errors are reported in a clear and informative way.

### Step 10: Write Unit Tests for Endpoints
- **Prompt**: "Create unit tests in `tests/` for each endpoint, using the appropriate testing framework. Make sure to test all expected scenarios, including edge cases and potential errors, as outlined in the OpenAPI specification. Ensure that any custom extensions (`x-*`) that affect endpoint behavior are tested."
- **Goal**: Validate that each endpoint works correctly and that all functionalities align with the specifications, including custom fields.

### Step 11: Write Shell Script to Generate FastAPI Code (Final Step)
- **Prompt**: "At the conclusion of the session, write a shell script (`generate_fastapi_code.sh`) that outputs the exact FastAPI code developed throughout this session, including all files and components (`app`, `routers`, `models`, etc.). The script should capture all the generated code step-by-step as discussed in the session, ensuring full alignment with the OpenAPI specification, including custom extensions (`x-*`). The script must follow the FountainAI standard of shell scripting, ensuring reproducibility without inventing new or additional code."
- **Goal**: Ensure that the shell script captures and outputs all FastAPI code generated during the session, adhering strictly to the OpenAPI specification and following the FountainAI scripting standards.

### Step 12: Execute End-to-End Testing and Refinement
- **Prompt**: "Perform end-to-end testing of the entire application, ensuring that all functionalities, including logging, database interactions, and API responses, align with the OpenAPI specification. Refine as necessary based on testing results, ensuring the output matches the input spec 1-to-1, including custom extensions."
- **Goal**: Ensure that the entire application functions as expected, providing the intended features with no errors or inconsistencies.

## Why This Approach Is Effective in ChatGPT-4 with Canvas
1. **Controlled Complexity**: By breaking down a complex specification into multiple focused prompts, this approach keeps each step manageable and ensures accuracy.

2. **Maintained Context**: Canvas allows the application to be built incrementally while preserving full context. This enables continuity, which is crucial for meeting all requirements.

3. **Iterative Refinement**: With Canvas, users can revisit each step, refine, and build on it, ensuring a complete implementation that adheres to specifications without compromising quality.

4. **Efficiency and Productivity**: The traditional way of developing complex software involves a lot of back-and-forth between documentation and code. Using ChatGPT-4 with Canvas accelerates this process by allowing for prompt-driven development that is directly influenced by the specification, reducing the risk of inconsistencies.

## Conclusion
The proposed approach provides a systematic method for generating a FastAPI application using ChatGPT-4 with Canvas, based on an OpenAPI specification. By breaking down the development into manageable steps that directly reference the spec, we ensure accuracy, completeness, and alignment with the initial requirements.

This approach is not just about generating code but about transforming how we work with AI, fostering a productive partnership where developers guide AI incrementally to achieve comprehensive results. With the capabilities of ChatGPT-4 and the continuity that Canvas provides, it's now possible to build reliable and production-ready software more efficiently than ever before.

## Next Steps
- **Define Specific Prompts**: Use the detailed prompt sequence provided above to begin building each component of your application, starting with the project structure.
- **Iterate and Refine**: Use the Canvas to iteratively refine each component, ensuring all aspects of the OpenAPI specification, including custom extensions, are implemented correctly.
- **Test and Deploy**: Use the generated Docker and test configurations to deploy and validate the application, ensuring that the output OpenAPI schema matches the original input specification 1-to-1, including all extensions.