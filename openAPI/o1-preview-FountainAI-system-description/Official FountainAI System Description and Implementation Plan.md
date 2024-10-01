# Official FountainAI System Description and Implementation Plan

---

## Table of Contents

1. [Introduction](#introduction)
2. [System Overview](#system-overview)
3. [Architecture Summary](#architecture-summary)
4. [Implementation Steps](#implementation-steps)
   - [1. Develop Independent Microservices](#1-develop-independent-microservices)
   - [2. Containerize Microservices with Docker](#2-containerize-microservices-with-docker)
   - [3. Set Up Docker Compose](#3-set-up-docker-compose)
   - [4. Configure Kong API Gateway](#4-configure-kong-api-gateway)
   - [5. Set Up DNS with Amazon Route 53](#5-set-up-dns-with-amazon-route-53)
   - [6. Deploy the Stack](#6-deploy-the-stack)
   - [7. Test the Setup](#7-test-the-setup)
   - [8. Implement GPT Model Orchestration](#8-implement-gpt-model-orchestration)
   - [9. Security Considerations](#9-security-considerations)
5. [Additional Considerations](#additional-considerations)
6. [Conclusion](#conclusion)

---

## Introduction

This document serves as the **Official FountainAI System Description and Implementation Plan**. It outlines the architecture and step-by-step implementation strategy for the FountainAI system, focusing on creating independent microservices using FastAPI and SQLite, orchestrated by a GPT model, and managed through Docker Compose, Kong API Gateway, and Amazon Route 53.

The goal is to build a modular, scalable, and maintainable system where each microservice is self-contained, aligning with modern microservices best practices. The GPT model acts as the orchestrator, using OpenAPI specifications to interact with the services. Kong API Gateway provides a unified entry point and API management features, while Amazon Route 53 ensures that services are accessible via DNS names as specified in the OpenAPI specifications.

---

## System Overview

**FountainAI** is designed to manage story elements such as scripts, characters, actions, spoken words, sessions, context, and the logical flow of stories. The system comprises several components:

1. **Independent Microservices**: Five FastAPI applications, each handling specific aspects of screenplay management.
2. **Kong API Gateway**: Routes requests to the appropriate microservices and manages API features like authentication and rate limiting.
3. **Docker Compose**: Orchestrates the deployment of microservices and Kong.
4. **Amazon Route 53**: Manages DNS records, mapping domain names to services.
5. **GPT Model**: Acts as the orchestrator, using OpenAPI specifications to interact with the services.

---

## Architecture Summary

### Components:

1. **Independent Microservices:**

   - **Technologies:** FastAPI, SQLite
   - **Characteristics:**
     - Each microservice is self-contained.
     - Manages its own database (SQLite).
     - Exposes RESTful APIs as per its OpenAPI specification.
     - Does not assume the existence of other services.
     - Focuses on a specific domain or functionality.

2. **Kong API Gateway:**

   - Acts as a single entry point for all API requests.
   - Routes requests to the appropriate microservice based on hostnames.
   - Provides features like authentication, rate limiting, logging, and SSL termination.

3. **Docker Compose:**

   - Orchestrates the deployment of microservices, Kong, and any other required services.
   - Defines service configurations, networks, and volumes.

4. **Amazon Route 53:**

   - Manages DNS records for the domain (`fountain.coach`).
   - Maps domain names to the Kong API Gateway or load balancer.

5. **GPT Model:**

   - Orchestrates interactions between microservices by making API calls.
   - Uses the OpenAPI specifications to understand and interact with the APIs.

---

## Implementation Steps

### 1. Develop Independent Microservices

#### a. Define OpenAPI Specifications

- **Objective:** Create comprehensive OpenAPI specifications for each microservice.
- **Actions:**
  - Define all endpoints, request and response models, authentication requirements, and examples.
  - Ensure specifications are accurate, complete, and serve as the single source of truth.

#### b. Implement FastAPI Applications

- **Structure:**
  - Each microservice has its own codebase and repository.
  - Organize code with routers, models, schemas, and main application files.

- **Database Setup:**
  - Use SQLite as the database for simplicity and self-containment.
  - Implement SQLAlchemy models corresponding to data models.
  - Initialize the database schema using `Base.metadata.create_all(bind=engine)`.

- **Dependency Injection:**
  - Use FastAPI's dependency injection system to manage database sessions.
  - Example:
    ```python
    def get_db():
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()
    ```

- **Implement Endpoints:**
  - Use Pydantic models for request validation and response serialization.
  - Ensure each endpoint adheres strictly to the OpenAPI specification.

#### c. Test Microservices Individually

- Use unit tests to test individual components.
- Use integration tests to test API endpoints.
- Ensure each microservice functions correctly in isolation.

### 2. Containerize Microservices with Docker

- **Dockerfile for Each Microservice:**

  ```dockerfile
  FROM python:3.9-slim

  WORKDIR /app

  COPY requirements.txt ./
  RUN pip install --no-cache-dir -r requirements.txt

  COPY . .

  CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
  ```

- **Build Docker Images:**
  - Build an image for each microservice.
    ```bash
    docker build -t microservice-name .
    ```

### 3. Set Up Docker Compose

- **Compose File Structure (`docker-compose.yml`):**

  ```yaml
  version: '3.8'

  services:
    # Example for one microservice
    central_sequence_service:
      build: ./central_sequence_service
      volumes:
        - central_sequence_data:/app/data  # Persist SQLite database
      networks:
        - fountainai-network

    # Kong API Gateway
    kong:
      image: kong:2.4
      environment:
        KONG_DATABASE: 'off'
        KONG_DECLARATIVE_CONFIG: /kong/declarative/kong.yml
      volumes:
        - ./kong.yml:/kong/declarative/kong.yml
      ports:
        - '80:8000'    # Proxy
        - '8001:8001'  # Admin API (secure this in production)
      networks:
        - fountainai-network

  volumes:
    central_sequence_data:

  networks:
    fountainai-network:
  ```

- **Define Networks and Volumes:**
  - Use Docker networks to allow communication between services.
  - Use volumes to persist data for each microservice.

### 4. Configure Kong API Gateway

#### a. Declarative Configuration

- Use a declarative configuration file (`kong.yml`) to define services, routes, and plugins.

- **Example `kong.yml`:**

  ```yaml
  _format_version: '2.1'
  services:
    - name: central-sequence-service
      url: http://central_sequence_service:8000
      routes:
        - name: central-sequence-route
          hosts:
            - centralsequence.fountain.coach
  ```

- **Define Services and Routes for Each Microservice:**
  - Map the hostnames to the appropriate services.
  - Configure required plugins (e.g., authentication, rate limiting).

#### b. SSL/TLS Configuration

- **Generate SSL Certificates:**
  - Use Let's Encrypt or another CA to obtain certificates for your domain and subdomains.
  - Alternatively, use wildcard certificates.

- **Mount Certificates in Kong:**
  - Configure Kong to use the SSL certificates for the appropriate hostnames.

#### c. Secure the Admin API

- Ensure that the Kong Admin API (`8001`) is not publicly accessible or is secured with authentication.

### 5. Set Up DNS with Amazon Route 53

#### a. Domain Registration and Hosted Zone

- **Objective:** Ensure control over the domain `fountain.coach`.
- **Actions:**
  - Register the domain if not already done.
  - Create a public hosted zone in Route 53 for `fountain.coach`.

#### b. Create DNS Records

- **A or CNAME Records:**
  - Point `centralsequence.fountain.coach` to the public IP address or DNS name of your Kong API Gateway (e.g., an Elastic IP or Load Balancer in AWS).
  - Repeat for other services:
    - `character.fountain.coach`
    - `scriptmanagement.fountain.coach`
    - `sessioncontext.fountain.coach`
    - `storyfactory.fountain.coach`

#### c. Update Nameservers

- Ensure that your domain's nameservers are set to the ones provided by Route 53.

### 6. Deploy the Stack

- **Run Docker Compose:**

  ```bash
  docker-compose up -d
  ```

- **Ensure Services Are Running:**
  - Verify that all microservices and Kong are running correctly.

### 7. Test the Setup

#### a. Access Services via DNS Names

- From a client, send requests to the services using their DNS names:

  - `https://centralsequence.fountain.coach/sequence`
  - `https://character.fountain.coach/characters`

#### b. Validate SSL Certificates

- Ensure that the SSL certificates are valid and that the connections are secure.

#### c. Verify Routing Through Kong

- Confirm that Kong is correctly routing requests to the appropriate microservices based on the hostnames.

### 8. Implement GPT Model Orchestration

- **Access OpenAPI Specifications:**
  - Provide the GPT model with the OpenAPI specifications for each service.

- **Configure API Endpoints:**
  - Ensure the GPT model uses the correct DNS names and endpoints.

- **Authentication:**
  - Provide the GPT model with any necessary API keys or tokens if authentication is enabled.

### 9. Security Considerations

#### a. API Authentication

- Implement authentication mechanisms using Kong plugins (e.g., Key Authentication, OAuth2).

- **Example: Enable Key Authentication Plugin:**

  ```yaml
  services:
    - name: central-sequence-service
      url: http://central_sequence_service:8000
      plugins:
        - name: key-auth
  ```

- **Create Consumers and Credentials:**
  - Define consumers in Kong and associate API keys with them.

#### b. Rate Limiting

- Use Kong's rate limiting plugin to protect services from abuse.

#### c. Secure Admin Interfaces

- Ensure that the Admin APIs of Kong and other services are secured and not exposed publicly.

#### d. Logging and Monitoring

- Enable logging in Kong and microservices to monitor access and errors.

- Integrate with monitoring tools like Prometheus and Grafana if needed.

---

## Additional Considerations

### Scaling

- **Horizontal Scaling:**
  - Services can be scaled independently by running multiple instances.
  - Update Kong's configuration to load balance between instances.

### Persistence

- **SQLite Databases:**
  - Since SQLite databases are file-based, use Docker volumes to persist data between container restarts.

### Backups

- **Database Backups:**
  - Implement backup strategies for the SQLite database files if data persistence is critical.

### Continuous Integration/Deployment

- **CI/CD Pipelines:**
  - Set up pipelines to automate building, testing, and deploying services.

### Monitoring and Logging

- **Centralized Logging:**
  - Implement solutions like ELK Stack (Elasticsearch, Logstash, Kibana) or cloud-based logging services.

- **Monitoring:**
  - Use tools like Prometheus and Grafana to monitor service health and performance.

### Documentation

- **API Documentation:**
  - Host Swagger UI or ReDoc for each microservice if needed.
  - Ensure documentation is accessible and up-to-date.

### Error Handling

- **Consistent Error Responses:**
  - Standardize error response formats across services for easier handling by the GPT model.

### Testing

- **End-to-End Testing:**
  - Test workflows that involve multiple services to ensure the GPT model orchestrates interactions correctly.

---

## Conclusion

The **Official FountainAI System Description and Implementation Plan** outlines a robust, scalable, and maintainable architecture for the FountainAI system. By implementing independent microservices with their own SQLite databases, using Docker Compose for orchestration, Kong API Gateway for request routing and API management, and Amazon Route 53 for DNS management, the system aligns with modern microservices best practices.

This approach simplifies development and maintenance, reduces the risk of cross-service dependencies causing issues, and ensures that each service can be developed, tested, and deployed independently. The GPT model orchestrates interactions between services using the OpenAPI specifications, allowing for complex workflows without tightly coupling the services.

By following the detailed implementation steps and considering the additional factors outlined, you can build a system that is not only functional but also resilient, secure, and ready to scale as needed.

---

**Next Steps:**

1. **Finalize OpenAPI Specifications.**
2. **Develop and Test Each Microservice Individually.**
3. **Set Up Docker Compose and Configure Kong.**
4. **Configure DNS Records in Amazon Route 53.**
5. **Deploy the Entire Stack and Perform Thorough Testing.**
6. **Implement Security Measures and Monitoring Tools.**
7. **Integrate the GPT Model for Orchestration.**
8. **Plan for Scaling and Future Enhancements.**

---

