# Official FountainAI Proposal for Refactoring Character Management API

## Introduction
The Character Management API currently handles multiple functionalities, including character management, actions, spoken words, and paraphrases. This comprehensive approach makes the service monolithic, affecting scalability, maintainability, and adherence to microservice principles. This proposal recommends a refactoring of the Character Management API into smaller, independent microservices to ensure better scalability, maintainability, and a clearer separation of concerns.

## Problem Statement
The current version of the Character Management API has become increasingly complex as it manages a broad range of functionalities that extend beyond a single responsibility. As new versions are introduced, it becomes challenging to scale, maintain, and modify the API without affecting unrelated parts of the system. These issues are exacerbated by:

- **Monolithic Nature**: The API is currently responsible for managing characters, actions, spoken words, and paraphrases, making it more like a monolith rather than a microservice.
- **Scalability Challenges**: As new functionalities are added, the entire service needs to be deployed, which can be problematic and costly, especially when changes are isolated to a single functionality.
- **Maintenance Complexity**: Bug fixes or enhancements in one part of the API might have unintended side effects on unrelated areas, increasing the risk of errors.
- **Versioning Limitations**: Evolving the service by introducing new versions for different functionalities results in a more complicated API that is harder to manage and prone to compatibility issues.

## Proposed Solution
Refactor the Character Management API into smaller microservices, each focused on a specific domain, including:

1. **Character Service**: Dedicated to handling all character-related operations, such as creation, retrieval, and paraphrasing.
2. **Action Service**: Responsible for creating, managing, and retrieving actions related to the characters or story.
3. **Spoken Word Service**: Handles the creation and management of spoken word entities, ensuring that dialogue can be stored and managed independently.
4. **Paraphrase Service**: A separate service that manages paraphrases for characters, actions, and spoken words.

## Benefits of Proposed Changes
1. **Single Responsibility Principle**: Each microservice will have a specific domain of responsibility, making it easier to understand, modify, and extend functionality.
2. **Scalability**: Smaller services can be scaled independently based on their load and usage requirements. For example, the character service can be scaled independently of the action service if necessary.
3. **Independent Versioning**: Each microservice can evolve at its own pace. Changes in one service will not require versioning changes in unrelated services, ensuring stability and simplifying upgrades.
4. **Reduced Complexity**: By breaking down the monolithic API, each microservice becomes easier to develop, test, and maintain. Teams can work in parallel without worrying about conflicting changes.
5. **Improved Resilience**: Issues in one microservice are less likely to impact others, leading to increased resilience of the overall system.

## Implementation Strategy
- **Step 1**: Identify and isolate the different functionalities within the current Character Management API. Define clear boundaries and responsibilities for each microservice.
- **Step 2**: Develop independent OpenAPI specifications for each of the following services:
  - Character Service
  - Action Service
  - Spoken Word Service
  - Paraphrase Service
- **Step 3**: Implement the microservices while ensuring integration through well-defined APIs. All services should interact seamlessly with the Central Sequence Service to maintain a consistent logical flow.
- **Step 4**: Transition clients from using the monolithic API to individual microservices in a phased manner to ensure a smooth migration and minimal disruption.

## Next Steps
To implement the changes as modeled by the Central Sequence Service update, the following must be carried out:
1. **Refactor OpenAPI Specifications**: Develop individual OpenAPI specifications for each new microservice (Character, Action, Spoken Word, and Paraphrase).
2. **API Key Security Implementation**: Ensure that all services use API key security to secure endpoints, as outlined in the revised Central Sequence Service model.
3. **Error Handling and Retry Mechanisms**: Introduce consistent error handling and retry mechanisms across all microservices to improve reliability, especially when interacting with external services like the Central Sequence Service.
4. **Integration with Central Sequence Service**: Ensure that each microservice integrates with the Central Sequence Service for sequence number assignments, maintaining logical consistency across all story elements.
5. **SQLite and Typesense Integration**: Implement SQLite as the primary data store for each service, and synchronize with Typesense for real-time search and retrieval capabilities. Each microservice should have its SQLite database that syncs data to Typesense, ensuring efficient search functionality.
6. **Testing and Validation**: Rigorously test each microservice independently and validate their interaction to ensure they work seamlessly together.
7. **Migration Plan**: Develop a detailed migration plan to transition from the monolithic Character Management API to the new microservices with minimal disruption to existing users.

## Conclusion
Refactoring the Character Management API into independent microservices will bring significant advantages in scalability, maintainability, and clarity of the system. This approach aligns with the principles of microservice architecture, providing a more resilient and flexible infrastructure to support future growth and evolving requirements.

This proposal aims to ensure that the evolution of the Character Management API is carried out in a structured manner, resulting in a robust and adaptable system capable of meeting the needs of FountainAI as it continues to grow.

## Next Steps
Please review this proposal and provide feedback or approval to proceed with breaking down the existing API into the proposed microservices.
