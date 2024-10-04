## Documentation: Central Sequence Service API v2

### Update Report: Central Sequence Service API v1 to v2

#### Overview
The Central Sequence Service API has been updated from version 1.0.0 to version 1.1.0 to address several areas for improvement, including error handling, security, adherence to REST principles, and additional features to improve functionality and scalability. Below is a detailed report of the changes made.

#### Major Changes

1. **Version Update**
   - The API version has been updated from `1.0.0` to `1.1.0`.

2. **Servers Section**
   - Added a new staging server (`https://staging.centralsequence.fountain.coach`) for testing purposes. This provides more flexibility for testing environments in addition to production and local development.

3. **Paths and Endpoints**
   - **/sequence (POST)**
     - **Request Body Schema**: Defined the schema directly in the request body instead of using a reference component. This includes properties such as `elementType` and `elementId`, with appropriate constraints and an enumeration for `elementType` to restrict acceptable values.
     - **Response Schema**: Defined the response schema directly, detailing the structure of the success response with `sequenceNumber` as an integer.
     - **Error Responses**: Added standard error responses (`400`, `401`, `500`) for improved error handling.

   - **/sequence/reorder (PUT)**
     - **HTTP Method Change**: Updated the HTTP method from `POST` to `PUT` to align with RESTful principles, as reordering is an update operation.
     - **Request Body Schema**: Defined the schema directly for properties like `elementType` and `elements` array, specifying constraints such as `minimum` for numeric fields and adding an enumeration for `elementType`.
     - **Response Schema**: Defined the schema for the success response directly, including `message` and `updatedElements` with their new sequence numbers.
     - **Error Responses**: Added error responses (`400`, `401`, `404`, `500`) for better error handling and to provide more context in case of failures.

   - **/sequence/version (POST)**
     - **Request Body Schema**: Defined the schema directly for `elementType`, `elementId`, and `newVersionData`, ensuring each field has clear constraints and descriptions.
     - **Response Schema**: The success response now includes `versionNumber` and `timestamp` to provide more information about the created version.
     - **Error Responses**: Added error responses (`400`, `401`, `404`, `500`) to standardize error handling.

   - **/sequence/version (GET)**
     - Added a new `GET` method to list all versions for a specified element. This new functionality enhances the API's capabilities in handling version history.
     - **Parameters**: Includes `elementId` as a query parameter to identify the element for which versions are being retrieved.
     - **Response Schema**: Defined a response schema that lists versions, including `versionNumber` and `timestamp` for each version.
     - **Error Responses**: Added error responses (`400`, `401`, `404`, `500`) for comprehensive error management.

4. **Component Updates**
   - **Error Responses**
     - Standardized error responses (`BadRequest`, `Unauthorized`, `NotFound`, `InternalServerError`) were defined in the `components.responses` section. These responses utilize the `ErrorResponse` schema for consistency.
   - **ErrorResponse Schema**
     - Added an `ErrorResponse` schema to the `components.schemas` section, which includes `errorCode`, `message`, and `details`. This helps in providing consistent and informative error messages across all endpoints.

#### Improvements and Fixes

- **Direct Schema Definitions**: Instead of referencing schemas like `SequenceRequest`, `SequenceResponse`, `ReorderRequest`, etc., the request and response schemas are now defined directly within each endpoint. This change addresses the issue of unrecognized component references, ensuring that the schema definitions are explicit and easily accessible.

- **Enumeration and Constraints**: Added enumerations for the `elementType` field across multiple endpoints to limit acceptable values, and added constraints such as `minimum: 1` to ensure data integrity.

- **Enhanced REST Compliance**: Updated HTTP methods to better follow REST conventions, such as changing `/sequence/reorder` from `POST` to `PUT` for an update operation.

- **Expanded Endpoint Functionality**: Added a new `GET` method for `/sequence/version` to provide the ability to retrieve a list of all versions for an element, which enhances the API's support for version management.

- **Detailed Success Responses**: Enhanced success responses to provide more detailed information, such as `timestamp` for version creation and `updatedElements` for reordering. This improves the clarity and usefulness of responses for clients.

#### Conclusion
The updates from version 1.0.0 to 1.1.0 of the Central Sequence Service API improve its robustness, error handling, and compliance with RESTful principles. The introduction of direct schema definitions, expanded endpoint functionality, and more informative responses significantly enhance the usability and scalability of the API for developers and consumers. These changes provide a solid foundation for the continued evolution of the Central Sequence Service API.

---

### Central Sequence Service API v2 OpenAPI Specification

```yaml
openapi: 3.1.0
info:
  title: Central Sequence Service API
  description: >
    This API manages the assignment and updating of sequence numbers for various elements within a story, ensuring logical order and consistency.
  version: 1.1.0
servers:
  - url: https://centralsequence.fountain.coach
    description: Production server for Central Sequence Service API
  - url: http://localhost:8080
    description: Development server
  - url: https://staging.centralsequence.fountain.coach
    description: Staging server for testing
paths:
  /sequence:
    post:
      summary: Generate Sequence Number
      operationId: generateSequenceNumber
      description: Generates a new sequence number for a specified element type.
      requestBody:
        required: true
        description: Details of the element requesting a sequence number.
        content:
          application/json:
            schema:
              type: object
              properties:
                elementType:
                  type: string
                  description: Type of the element (e.g., script, section, character, action, spokenWord).
                  enum: ["script", "section", "character", "action", "spokenWord"]
                elementId:
                  type: integer
                  description: Unique identifier of the element.
                  minimum: 1
              required: [elementType, elementId]
            examples:
              example:
                value:
                  elementType: script
                  elementId: 1
      responses:
        '201':
          description: Sequence number successfully generated.
          content:
            application/json:
              schema:
                type: object
                properties:
                  sequenceNumber:
                    type: integer
                    description: The generated sequence number.
                    minimum: 1
              examples:
                example:
                  value:
                    sequenceNumber: 1
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '500':
          $ref: '#/components/responses/InternalServerError'
  /sequence/reorder:
    put:
      summary: Reorder Elements
      operationId: reorderElements
      description: Reorders elements by updating their sequence numbers.
      requestBody:
        required: true
        description: Details of the reordering request.
        content:
          application/json:
            schema:
              type: object
              properties:
                elementType:
                  type: string
                  description: Type of elements being reordered.
                  enum: ["script", "section", "character", "action", "spokenWord"]
                elements:
                  type: array
                  items:
                    type: object
                    properties:
                      elementId:
                        type: integer
                        description: Unique identifier of the element.
                        minimum: 1
                      newSequence:
                        type: integer
                        description: New sequence number for the element.
                        minimum: 1
              required: [elementType, elements]
            examples:
              example:
                value:
                  elementType: section
                  elements:
                    - elementId: 1
                      newSequence: 2
                    - elementId: 2
                      newSequence: 1
      responses:
        '200':
          description: Elements successfully reordered.
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
                    description: Success message.
                  updatedElements:
                    type: array
                    items:
                      type: object
                      properties:
                        elementId:
                          type: integer
                          description: Unique identifier of the element.
                        sequenceNumber:
                          type: integer
                          description: Updated sequence number of the element.
              examples:
                example:
                  value:
                    message: Reorder successful.
                    updatedElements:
                      - elementId: 1
                        sequenceNumber: 2
                      - elementId: 2
                        sequenceNumber: 1
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'
  /sequence/version:
    post:
      summary: Create New Version
      operationId: createVersion
      description: Creates a new version of an element.
      requestBody:
        required: true
        description: Details of the versioning request.
        content:
          application/json:
            schema:
              type: object
              properties:
                elementType:
                  type: string
                  description: Type of the element (e.g., script, section, character, action, spokenWord).
                  enum: ["script", "section", "character", "action", "spokenWord"]
                elementId:
                  type: integer
                  description: Unique identifier of the element.
                  minimum: 1
                newVersionData:
                  type: object
                  description: Data for the new version of the element.
              required: [elementType, elementId, newVersionData]
            examples:
              example:
                value:
                  elementType: dialogue
                  elementId: 1
                  newVersionData:
                    text: "O Romeo, Romeo! wherefore art thou Romeo?"
      responses:
        '201':
          description: New version successfully created.
          content:
            application/json:
              schema:
                type: object
                properties:
                  versionNumber:
                    type: integer
                    description: The version number of the new version.
                  timestamp:
                    type: string
                    format: date-time
                    description: Timestamp of when the new version was created.
              examples:
                example:
                  value:
                    versionNumber: 2
                    timestamp: "2024-10-04T12:34:56Z"
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'
    get:
      summary: List Versions
      operationId: listVersions
      description: Retrieves a list of versions for a specified element.
      parameters:
        - name: elementId
          in: query
          required: true
          schema:
            type: integer
          description: Unique identifier of the element.
      responses:
        '200':
          description: List of versions successfully retrieved.
          content:
            application/json:
              schema:
                type: object
                properties:
                  versions:
                    type: array
                    items:
                      type: object
                      properties:
                        versionNumber:
                          type: integer
                          description: The version number of the element.
                        timestamp:
                          type: string
                          format: date-time
                          description: Timestamp of when the version was created.
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'
components:
  responses:
    BadRequest:
      description: Bad request due to invalid input.
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    Unauthorized:
      description: Unauthorized request due to missing or invalid authentication.
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    NotFound:
      description: The requested resource was not found.
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    InternalServerError:
      description: Internal server error occurred.
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
  schemas:
    ErrorResponse:
      type: object
      properties:
        errorCode:
          type: string
          description: Application-specific error code.
        message:
          type: string
          description: Human-readable error message.
        details:
          type: array
          items:
            type: string
          description: Additional details about the error, if available.
```