**Prompt for Generalized Version 4 Implementation Across All APIs**

> Update all nine APIs in the FountainAI system to version 4.0.0 by implementing the "comment-on" feature for every CRUD operation. The "comment-on" feature requires that every action taken by the system's APIs is accompanied by a contextual explanation. This explanation should provide the reasoning behind the action, generated dynamically by the GPT model using real-time data, ensuring enhanced accountability, transparency, and compliance.
>
> The nine APIs are as follows:
> 1. **Action Service**: Manages actions associated with characters and spoken words within a story.
> 2. **Central Sequence Service**: Manages sequence numbers to ensure proper ordering of elements like actions, characters, and story events.
> 3. **Character Service**: Handles character creation, updates, retrievals, and management, ensuring consistent narrative roles.
> 4. **Core Script Management**: Manages script content, including filtering by author, title, characters, and actions, enabling coherent storytelling.
> 5. **Paraphrase Service**: Manages paraphrases for dialogues, characters, actions, and spoken words, allowing for creative variations.
> 6. **Performer Service**: Manages performers, linking them with characters, including creation, updates, and role management.
> 7. **Session and Context Management**: Handles user sessions and manages narrative context, linking various storytelling elements cohesively.
> 8. **Spoken Word Service**: Manages lines of spoken words in a narrative, supporting retrieval and CRUD operations on lines or speeches.
> 9. **Story Factory API**: Integrates data from other services to assemble, manage, and maintain the logical flow of stories.
>
> **Implementation Requirements**:
> - **Add the "comment-on" Feature**: Each CRUD operation across all nine APIs must include the "comment" attribute in request and response schemas. This attribute will store a real-time contextual explanation generated by the GPT model, explaining why the action is being taken.
> - **Request and Response Schemas**: Add the `comment` field to all request and response schemas associated with `create`, `update`, and `delete` endpoints. Ensure that the explanation is part of every relevant operation.
> - **CRUD Operations**: Ensure that each of the following operations includes the "comment-on" feature:
>   - **Create** (`POST` endpoints): The GPT model must provide an explanation for creating new entities, such as characters, actions, sequences, etc.
>   - **Update** (`PATCH` endpoints): When updating an entity, the GPT model must generate an explanation for the modification, ensuring the context of the change is clear.
>   - **Delete** (`DELETE` endpoints): Any deletion must include an explanation, such as compliance reasons (e.g., GDPR requests) or narrative adjustments.
>
> **Integration Considerations**:
> - **No Omissions**: Retain all existing properties, paths, parameters, and responses in the current OpenAPI specifications. Only add new properties and features needed to meet the version 4 requirements. Ensure that no information is removed or altered unintentionally.
> - **Real-Time Data Context**: The "comment-on" explanations must be generated based on real-time system states. Ensure that each API is enhanced to provide the necessary data to the GPT model for context generation, such as active sessions, roles, resource statuses, and compliance requirements.
> - **Security and Permissions Context**: The explanations must take into account the user's role and permissions. The GPT model should include details about user roles (e.g., admin, regular user) to clarify why an action was performed, ensuring that the comment-on feature reflects the security context of each action.
> - **Error Handling Explanations**: Include the "comment-on" feature in error handling scenarios. When an error occurs, the system should generate a comment explaining why the action failed, providing additional transparency and aiding in compliance, especially for operations involving data modifications or deletions.
> - **Logging, SQLite, and Typesense Synchronization**: Maintain compliance with existing standards for logging, SQLite persistence, and Typesense synchronization. Incorporate the "comment-on" feature seamlessly into the existing mechanisms to maintain consistency and reliability.
>
> **Testing and Compliance**:
> - Each updated API must be tested to ensure that the GPT model correctly generates the real-time explanations for each operation.
> - All changes must be fully compliant with relevant data privacy regulations, such as GDPR, ensuring that explanations for actions like data deletion are logged and traceable for audit purposes.
>
> **Output Sequence**:
> 1. **Action Service**:
>    - Update `createAction`, `updateAction`, and `deleteAction` endpoints to include the `comment` field in request and response schemas.
>    - Ensure every action, including error scenarios, has a contextual explanation generated by the GPT model.
>    - Request the existing OpenAPI v3 specification from the provided repository URL: [Action Service API v3](https://github.com/Contexter/FountainAI/tree/main/openAPI/v3).
> 2. **Central Sequence Service**:
>    - Add `comment` to sequence operations (`createSequence`, `updateSequence`, `deleteSequence`).
>    - Provide real-time explanations for sequence management actions.
>    - Request the existing OpenAPI v3 specification from the provided repository URL: [Central Sequence Service API v3](https://github.com/Contexter/FountainAI/tree/main/openAPI/v3).
> 3. **Character Service**:
>    - Update all character CRUD endpoints (`createCharacter`, `updateCharacter`, `deleteCharacter`) to include the `comment` field.
>    - Ensure the explanations account for character interactions within the narrative context.
>    - Request the existing OpenAPI v3 specification from the provided repository URL: [Character Service API v3](https://github.com/Contexter/FountainAI/tree/main/openAPI/v3).
> 4. **Core Script Management**:
>    - Add `comment` to script management operations (`createScript`, `updateScript`, `deleteScript`).
>    - Ensure that the GPT model generates context-aware explanations for script modifications and deletions.
>    - Request the existing OpenAPI v3 specification from the provided repository URL: [Core Script Management API v3](https://github.com/Contexter/FountainAI/tree/main/openAPI/v3).
> 5. **Paraphrase Service**:
>    - Update paraphrasing operations (`createParaphrase`, `updateParaphrase`, `deleteParaphrase`) to include the `comment` field.
>    - Provide explanations that clarify why specific paraphrases are generated or modified.
>    - Request the existing OpenAPI v3 specification from the provided repository URL: [Paraphrase Service API v3](https://github.com/Contexter/FountainAI/tree/main/openAPI/v3).
> 6. **Performer Service**:
>    - Add `comment` to performer CRUD operations (`createPerformer`, `updatePerformer`, `deletePerformer`).
>    - Ensure explanations reflect the relationship between performers and characters.
>    - Request the existing OpenAPI v3 specification from the provided repository URL: [Performer Service API v3](https://github.com/Contexter/FountainAI/tree/main/openAPI/v3).
> 7. **Session and Context Management**:
>    - Update session and context operations (`createSession`, `updateSession`, `deleteSession`) to include the `comment` field.
>    - Ensure the GPT model generates explanations that capture session context and user roles.
>    - Request the existing OpenAPI v3 specification from the provided repository URL: [Session and Context Management API v3](https://github.com/Contexter/FountainAI/tree/main/openAPI/v3).
> 8. **Spoken Word Service**:
>    - Add `comment` to spoken word operations (`createLine`, `updateLine`, `deleteLine`).
>    - Provide explanations for managing lines within speeches, including interleaved actions.
>    - Request the existing OpenAPI v3 specification from the provided repository URL: [Spoken Word Service API v3](https://github.com/Contexter/FountainAI/tree/main/openAPI/v3).
> 9. **Story Factory API**:
>    - Update story assembly operations (`createStory`, `updateStory`, `deleteStory`) to include the `comment` field.
>    - Ensure that explanations reflect the integration of multiple services to maintain story flow.
>    - Request the existing OpenAPI v3 specification from the provided repository URL: [Story Factory API v3](https://github.com/Contexter/FountainAI/tree/main/openAPI/v3).
>
> **Final Deliverables**:
> - Provide the updated OpenAPI specification for each of the nine services, including the "comment-on" feature as described.
> - Ensure that the updated version is compatible with the overall FountainAI architecture, maintaining seamless integration between all services.
> - Confirm that all features continue to work as intended, with additional explanations enhancing user understanding and compliance readiness.

The updated version must provide full accountability, transparency, and ensure compliance across all services, supporting both the narrative requirements of FountainAI and regulatory obligations. Use the outlined requirements to iteratively build and refine the APIs to achieve a robust and comprehensive version 4 implementation.