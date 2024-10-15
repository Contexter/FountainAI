# FountainAI System Role Prompting: Dynamic Integration with OpenAPI Specifications

![FountainAI Operational Complexity](https://coach.benedikt-eickhoff.de/koken/storage/originals/1d/ca/FountainAI-operational-complexity.png)

## Abstract

This paper presents a comprehensive approach to system role prompting within FountainAI, leveraging dynamic generation of prompts based on OpenAPI specifications. The goal is to enhance the assistant's contextual understanding, streamline operations, and provide a robust mechanism for integrating dynamic services within FountainAI. 
## 1. Introduction

FountainAI is a modular AI-driven system that integrates several distinct microservices, each with its own operations and functionality. To facilitate interaction with these services, the assistant requires a robust and adaptive system role prompt that informs it about the capabilities and operations of each service. System role prompts are crucial for defining the behavior and scope of the assistant, ensuring that it can accurately and efficiently respond to user requests. This paper details how system role prompting can be dynamically updated using OpenAPI specifications and explains the role of system prompts within the broader OpenAI API framework.

## 2. System Roles in OpenAI API Context

The OpenAI API utilizes roles as a way to structure conversations between the assistant and users. The primary roles are "system," "user," and "assistant":

- **System Role**: Sets the behavior and scope of the assistant. It provides essential context about the assistant's purpose, expertise, and available functionalities.
  - **Example**: "You are a helpful assistant specialized in providing information about FountainAI services. You will interpret user requests and provide appropriate responses based on the available operations."
- **User Role**: Represents inputs from the user, conveying their queries or requests.
  - **Example**: "What characters are available in the current script?"
- **Assistant Role**: Outputs responses, performing tasks based on both user inputs and the instructions provided by the system role.
  - **Example**: "The following characters are available: Alice, Bob, and Charlie."

The system role is pivotal in guiding the assistant's interactions, defining its expertise, and enabling a controlled interaction experience. It acts as a reference point for the assistant, ensuring that every action is aligned with the intended capabilities.

## 3. Challenges in Static System Role Prompting

In a dynamic system like FountainAI, static system prompts quickly become outdated, as services evolve and new capabilities are added. Relying on a fixed system prompt can lead to the following issues:

- **Stale Information**: As new APIs are introduced or updated, the system prompt can become outdated, causing the assistant to lack awareness of current capabilities.
- **Ambiguity**: Overlapping or similar operations across different services may lead to confusion, resulting in incorrect responses or misrouted actions.
- **Maintenance Overhead**: Manually updating system prompts every time a new operation is introduced can be cumbersome and error-prone.

## 4. Dynamic System Role Prompting Using OpenAPI

To address these challenges, the proposed approach involves dynamically generating system role prompts using OpenAPI specifications. OpenAPI is a standard format for defining RESTful APIs, making it an ideal source of structured information about the capabilities of each microservice within FountainAI.

### 4.1 Extracting OpenAPI Elements

The key elements that are dynamically extracted from the OpenAPI specifications include:

- **Operation IDs**: Unique identifiers for each endpoint in the API.
- **Summaries and Descriptions**: Provide concise and detailed information about the purpose and function of each operation.
- **Endpoints and Methods**: Indicate how to interact with the API and what kind of operations (GET, POST, etc.) are supported.

These elements are extracted programmatically using scripts that parse the OpenAPI specifications and collect relevant information about each operation, including its context and parameters.

### 4.2 System Prompt Generation

The extracted information is then used to generate a comprehensive system prompt. This prompt includes an introduction to FountainAI and a list of all available services and their operations. Each operation is described with its operation ID, endpoint, HTTP method, and a brief summary.

**Example System Prompt Structure**:

```
You are the system interface for FountainAI. Your task is to facilitate access to different services offered by FountainAI by interpreting user requests and executing the appropriate operations.

FountainAI offers the following services and operations:

1. **Character Service**:
   - **getCharacter** (GET `/characters/{characterId}`): Retrieves character details based on character ID.
   - **createCharacter** (POST `/characters`): Creates a new character in the system.

2. **Action Service**:
   - **createAction** (POST `/actions`): Records a new action, specifying details like character involvement and timing.
   - **listActionsByContext** (GET `/actions`): Lists actions filtered by context such as `sceneId` or `characterId`.
```

### 4.3 Dynamic Updates

Since all FountainAI services are implemented as FastAPI apps, we can leverage FastAPI's automatic publishing of OpenAPI specifications. By dynamically parsing these OpenAPI specifications, we can generate the system role prompt to reflect the current state of available operations without manual intervention. This ensures that the assistant remains up-to-date with the latest capabilities of each service.  The FountainAI local client FastAPI app will provide an endpoint to initiate this dynamic parsing of FountainAI openAPI updates.   

## 5. Handling Operation IDs by the Model

The model utilizes the operation IDs, summaries, and descriptions provided in the prompt to understand the full context of each operation. This ensures that:

- **Accurate Reasoning**: The assistant can reason about which service to call, even if operations across different services have similar functionality.
- **Disambiguation**: If the user request is ambiguous, the model can use the context from the system prompt to disambiguate and choose the correct operation based on service-specific details.
- **Scalable Interaction**: The model can handle a growing number of services and operations without requiring manual intervention, as long as the prompt generation remains automated.

## 6. Conclusion

Dynamic system role prompting provides a scalable and effective way to manage the complexity of multiple services in FountainAI. By leveraging OpenAPI specifications, the system prompt can be continuously updated to reflect the latest state of available operations, avoiding ambiguity and ensuring consistency. This approach allows the assistant to effectively and reliably interact with a wide range of services, ultimately improving the user experience.

## References

- OpenAI API Documentation. [[https://beta.openai.com/docs/](https://beta.openai.com/docs/)]
- OpenAPI Specification. [[https://swagger.io/specification/](https://swagger.io/specification/)]
