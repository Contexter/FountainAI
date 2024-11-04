# The FountainAI Mock Server

>Project Paper

## Overview

The goal of this project is to develop a **Typer-based OpenAPI parser CLI** tool to consolidate multiple OpenAPI specifications into a single, unified mock server specification. This solution is designed for the FountainAI ecosystem, which comprises multiple services with individual APIs. By unifying these APIs, the tool will enable a mock server that replicates the full functionality of the FountainAI services in a single API endpoint, ideal for testing and integration workflows.

---

## Problem Statement

Developing and maintaining a unified mock server for the FountainAI ecosystem involves several challenges:

1. **Route and Schema Duplication**:
   - Each service has its own routes, often with overlapping paths or similar schemas. Manually resolving these overlaps in a unified API document is error-prone.
   
2. **Dependency Consistency**:
   - Ensuring all dependencies and schemas align without conflicts across services is crucial for accurate testing.

3. **Scalability and Automation**:
   - Every time an individual service API is updated, the mock server’s unified API needs updating. Automating this process is essential for scalability and reliability.

---

## Solution Path: OpenAPI Parser CLI with Typer

We will implement a **Python CLI tool using Typer** to parse, merge, and validate multiple OpenAPI files. This CLI will generate a single YAML document representing the FountainAI ecosystem’s mock server API, with Typer offering distinct benefits:

### Benefits of Typer

1. **Automatic CLI Generation**: Typer converts functions into CLI commands with minimal code, making it easy to define command-line arguments.
2. **Automatic Help Messages**: Typer provides `--help` options for each command, displaying available arguments and options, which enhances user experience.
3. **Type-Safe and Readable Code**: Typer’s reliance on Python’s type hints promotes type safety and readability, reducing potential runtime errors.
4. **Modularity and Maintainability**: Typer enables modular code, allowing easy additions of new CLI options or commands.

---

## Project Requirements

The OpenAPI parser CLI tool will perform the following tasks:

### 1. Directory Parsing and File Loading
- **Load** all `.yml` and `.yaml` files from a specified input directory.
- Parse each OpenAPI file into a Python dictionary for merging.

### 2. Maintaining OpenAPI Structure
- **Base Structure**: Use OpenAPI 3.1.0 as the base for the merged output.
- **Tags**: Include tags for each service to categorize routes by origin.
- **Server URL**: Add a `servers` entry with `http://localhost:8000` for local testing.

### 3. Deduplication and Path Organization
- **Path Prefixing**: Prefix each service’s routes with a unique identifier to avoid conflicts (e.g., `/action-service/actions`).
- **Schema Deduplication**: Deduplicate shared schemas by merging identical definitions and prefixing names where necessary.

### 4. Validation and Output
- **Validation**: Use `openapi-schema-validator` to ensure the final document adheres to OpenAPI 3.1.0 standards.
- **Output**: Write the unified OpenAPI document to a specified output path.

---

## Typer CLI Specifications

### CLI Command

The main command for the CLI will be `merge-openapi`, which will take the following arguments:

```bash
python merge_openapi.py merge-openapi --input-directory ./openapi_files --output-file mock_server_openapi.yml --validate --verbose
```

### Parameters and Options

- `--input-directory`: Path to the directory containing OpenAPI files (required).
- `--output-file`: Path to save the unified OpenAPI file (default: `mock_server_openapi.yml`).
- `--validate/--no-validate`: Enables or disables validation of the final OpenAPI document (default: `--validate`).
- `--verbose`: Provides detailed output during merging, showing each step and any deduplications.

---

## Comprehensive Prompt for GPT-4 (Markdown Format)

> You are tasked with creating a **Python-based OpenAPI parser CLI** using **Typer**. This CLI will merge multiple OpenAPI YAML files into a single, unified OpenAPI document. The merged file will represent a comprehensive mock server specification for testing purposes, simulating multiple services within a single API. Here are the detailed requirements:
> 
> ### CLI Interface:
> - **Create a CLI using Typer** that allows users to:
>   - Specify an input directory containing multiple OpenAPI YAML files (10 files).
>   - Set the path for the output YAML file (`mock_server_openapi.yml` by default).
>   - Toggle options for validation and verbosity.
> 
> ### CLI Commands:
> - **Main Command**: `merge-openapi`
>   - **Parameters**:
>     - `--input-directory`: Path to the directory containing OpenAPI files. Required.
>     - `--output-file`: Path to the output YAML file for the unified specification (default is `mock_server_openapi.yml`).
>     - `--validate/--no-validate`: Flag to enable or disable validation of the final OpenAPI document (default is `--validate`).
>     - `--verbose`: Flag for verbose output, providing step-by-step details of the merging process.
> 
> ### Functional Requirements:
> 
> 1. **Directory Parsing and File Loading**:
>    - The tool should load all `.yml` and `.yaml` files from the specified directory.
>    - Parse each file individually into a Python dictionary format.
> 
> 2. **Maintaining OpenAPI Structure**:
>    - Use OpenAPI 3.1.0 as the base structure for the output file.
>    - Include a main **`info` section** with basic metadata for the mock server, such as title, description, and version.
>    - Add a **`servers`** field with a single entry pointing to `http://localhost:8000`.
>    - Implement **tags** based on service names to categorize each endpoint according to its originating service (e.g., `Action Service`, `Character Service`).
> 
> 3. **Path Deduplication and Prefixing**:
>    - For each service, add a prefix to its routes (derived from the service name) to prevent path conflicts (e.g., `/actions` becomes `/action-service/actions`).
>    - Include all HTTP methods for each path (GET, POST, PUT, DELETE, etc.) as defined in the individual specs.
> 
> 4. **Components Deduplication**:
>    - **Schemas**:
>      - Maintain unique schema names by prefixing them with the service name when necessary (e.g., `ActionService_ActionSchema`).
>      - Merge schemas with identical names but identical structures across services to avoid redundancy.
>    - **Responses, Parameters, and Request Bodies**:
>      - Deduplicate and prefix these components similarly to schemas, ensuring they are unique.
>    - Add all deduplicated components to the `components` section of the final OpenAPI file.
> 
> 5. **Exact Matching for Parameters and Responses**:
>    - Ensure each endpoint in the final document has exactly the parameters, request bodies, and responses specified in the original OpenAPI files.
>    - Replicate path and query parameters as defined, including optional and required fields.
>    - Populate each response object with example data as specified in the original schemas to ensure realistic mock responses.
> 
> 6. **Validation**:
>    - If `--validate` is enabled, validate the final OpenAPI document to confirm it conforms to OpenAPI 3.1.0 standards.
>    - Use `openapi-schema-validator` or equivalent to validate the generated YAML structure before saving.
>    - If validation fails, print validation errors in the output and exit with an error code.
> 
> 7. **Output**:
>    - The final output should be written to the specified `--output-file`.
>    - Structure the YAML output to ensure human readability, maintaining consistent indentation and ordering for easy reference.
>    - If `--verbose` is enabled, print a summary report to the console, listing each service’s paths and components added to the unified spec.
> 
> ### Example Workflow:
> - Run the tool with the following command:
> 
>   ```bash
>   python merge_openapi.py merge-openapi --input-directory ./openapi_files --output-file mock_server_openapi.yml --validate --verbose
>   ```
> 
> - For each service:
>   - Parse the file and identify tags, paths, schemas, responses, etc.
>   - Prefix paths with the service name to avoid route conflicts.
>   - Add each component to the `components` section, ensuring unique naming.
> - After merging all services:
>   - Validate the final OpenAPI specification.
>   - Write the merged document to `mock_server_openapi.yml`.
> 
> ### Additional Instructions:
> - **Modularity**: Organize the parser functions into sections (`parse_file`, `merge_paths`, `deduplicate_components`, `write_output`, etc.) for readability and maintainability.
> - **Error Handling**: Implement robust error handling for missing fields, schema conflicts, and validation errors, printing useful messages when `--verbose` is set.
> - **Documentation**: Write a detailed docstring for each function, describing its purpose, parameters, and return values.
> - **Testing**: Include optional test functions to confirm that the merged OpenAPI file can be used with standard OpenAPI tools like Swagger or Postman without issues.

---

This prompt will guide the development of a **comprehensive and Typer-based CLI tool** for merging OpenAPI specifications, generating a unified, validated mock server specification for the FountainAI ecosystem.