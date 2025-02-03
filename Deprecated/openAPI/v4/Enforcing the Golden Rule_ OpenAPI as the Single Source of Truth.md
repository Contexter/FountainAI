
# Enforcing the Golden Rule: OpenAPI as the Single Source of Truth  

This document outlines the **enforcement of the OpenAPI specification as the single source of truth** for all FountainAI services. Any configuration, functionality, or rule that is **normative but not yet represented in the OpenAPI** must be **integrated into the OpenAPI specification**.  

---

## **The Rule**

**If it’s normative, it must be in the OpenAPI specification.**  
This rule ensures that all aspects of API functionality, configuration, and behavior are captured explicitly in the OpenAPI file, leaving no room for ambiguity, undocumented features, or assumptions.

---

## **Why OpenAPI as the Single Source of Truth?**

1. **Consistency Across Environments**:  
   All API behaviors, endpoints, and configurations are defined and validated from one central document.
   
2. **Machine-Readable Clarity**:  
   OpenAPI allows tools to **automatically generate code, documentation, and client libraries**, ensuring consistency with minimal manual intervention.

3. **Prevents Guessing**:  
   Relying on paths, behavior, or configurations that are not explicitly defined in the OpenAPI leads to **ambiguity and potential runtime errors**.

4. **Backward Compatibility Management**:  
   Changes are explicitly versioned and tested through the OpenAPI specification.

5. **Developer Trust**:  
   Ensures that all stakeholders—developers, testers, and consumers—have an authoritative source for understanding the API.

---

## **Key Normative Areas to Enforce**

### **1. Resource Paths**  

Paths for essential files and resources (e.g., `openapi.yml`, templates, databases) must be explicitly defined in the OpenAPI. This eliminates ambiguity in runtime configurations.

#### **Schema Example for Resource Paths**:  

```yaml
components:
  schemas:
    ResourcePath:
      description: Path configuration for critical files used by the service.
      type: object
      properties:
        openapiFile:
          type: string
          description: Path to the OpenAPI specification file.
          example: "Sources/App/Resources/openapi.yml"
        viewsDirectory:
          type: string
          description: Path to the Views directory for templates.
          example: "Sources/App/Resources/Views/"
        databaseFile:
          type: string
          description: Path to the SQLite database file.
          example: "db.sqlite"
      required: [openapiFile, viewsDirectory, databaseFile]
```

#### **Path Endpoint**:  

A new endpoint must be introduced to provide resource path information dynamically:  

```yaml
paths:
  /paths:
    get:
      summary: Retrieve service resource paths
      operationId: getResourcePaths
      tags:
        - Configuration
      description: Returns the paths for critical resources required by the service.
      responses:
        '200':
          description: Successfully retrieved resource paths.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ResourcePath'
```

---

### **2. Monitoring and Health Checks**  

Normative rules around **monitoring and health check endpoints** must be incorporated into the OpenAPI:  

#### **Schema for Health Check Response**:  

```yaml
components:
  schemas:
    HealthCheckResponse:
      description: Schema representing the health check response.
      type: object
      properties:
        status:
          type: string
          description: Current health status of the service.
          example: "healthy"
        uptime:
          type: string
          description: Service uptime.
          example: "3 days, 4 hours, 21 minutes"
        timestamp:
          type: string
          format: date-time
          description: Timestamp of the health check.
          example: "2024-11-21T14:35:00Z"
```

#### **Health Check Endpoint**:  

```yaml
paths:
  /health:
    get:
      summary: Perform a health check on the service
      operationId: healthCheck
      tags:
        - Monitoring
      description: Provides a health check for the API, returning uptime and status.
      responses:
        '200':
          description: Service is healthy.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/HealthCheckResponse'
        '500':
          description: Service is unhealthy.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
```

---

### **3. Middleware and Functional Configurations**  

If middleware configurations (e.g., OpenAPI middleware, database drivers) are required, they must be represented explicitly in the OpenAPI.  

#### **Schema Example for Middleware Configuration**:  

```yaml
components:
  schemas:
    MiddlewareConfig:
      description: Middleware configuration details.
      type: object
      properties:
        openapiMiddleware:
          type: object
          description: Configuration for OpenAPI middleware.
          properties:
            filePath:
              type: string
              description: Path to the OpenAPI file.
              example: "Sources/App/Resources/openapi.yml"
        database:
          type: object
          description: Configuration for database connections.
          properties:
            type:
              type: string
              description: Type of database.
              example: "SQLite"
            path:
              type: string
              description: Path to the database file.
              example: "db.sqlite"
      required: [openapiMiddleware, database]
```

#### **Middleware Configuration Endpoint**:  

```yaml
paths:
  /config:
    get:
      summary: Retrieve middleware configuration
      operationId: getMiddlewareConfig
      tags:
        - Configuration
      description: Returns the configuration for middleware used by the service.
      responses:
        '200':
          description: Successfully retrieved middleware configuration.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/MiddlewareConfig'
```

---

### **4. Error Handling and Missing Resources**

All errors, including missing resources and invalid configurations, must be captured in the OpenAPI.  

#### **Updated Error Schema**:  

```yaml
components:
  schemas:
    ErrorResponse:
      description: Error schema including resource context.
      type: object
      properties:
        errorCode:
          type: string
          description: Application-specific error code.
        message:
          type: string
          description: Error message describing the issue.
        resource:
          type: string
          description: Resource causing the error.
          example: "openapi.yml"
        expectedPath:
          type: string
          description: Expected path for the missing resource.
          example: "Sources/App/Resources/openapi.yml"
        details:
          type: string
          description: Additional context about the error.
      required: [errorCode, message]
```

---

## **Mandatory Updates Checklist**

1. **Paths**:  
   - Resource paths must be explicitly defined in both code and the OpenAPI specification.

2. **Monitoring and Documentation**:  
   - Add `/health` and `/docs` endpoints to all APIs.  

3. **Configuration Endpoints**:  
   - Introduce `/paths` and `/config` endpoints to expose runtime configurations.

4. **Error Handling**:  
   - Update error responses to include `resource` and `expectedPath` details.

5. **Schemas**:  
   - Add `ResourcePath`, `MiddlewareConfig`, and `HealthCheckResponse` schemas.

---

## **Implementation Plan**

1. **Schema Updates**:  
   Update all FountainAI OpenAPIs with the required schemas (`ResourcePath`, `MiddlewareConfig`, `HealthCheckResponse`, `ErrorResponse`).

2. **New Endpoints**:  
   Add `/health`, `/docs`, `/paths`, and `/config` endpoints to all APIs.

3. **Path Standardization**:  
   Ensure all critical paths are statically defined and verifiable in the OpenAPI.

4. **Testing and Validation**:  
   - Use automated tools to validate OpenAPI compliance.  
   - Test configurations for all environments (staging and production).

---

## **Conclusion**

By adhering to these guidelines, FountainAI enforces the **OpenAPI as the single source of truth** across all services. This ensures consistency, reliability, and maintainability, reducing ambiguity and increasing developer trust.
