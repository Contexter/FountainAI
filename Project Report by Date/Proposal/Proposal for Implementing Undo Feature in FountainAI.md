# Proposal for Implementing Undo Feature in FountainAI

## Overview
This proposal outlines the implementation of an **Undo feature** within FountainAI. The feature aims to provide users with a safe and user-friendly way to revert any potentially destructive actions, such as editing scripts, characters, dialogues, or actions. By leveraging the existing **versioning capabilities** of FountainAI's APIs, users will have the ability to undo changes, ensuring that the integrity of their data is preserved.

**Note**: The sole client to these APIs is a **GPT model**, which has been specifically configured based on the **FountainAI openAPIs**. This GPT model is responsible for enforcing **destructive action awareness** and managing the **Undo feature**, ensuring users can safely revert changes.

---

## GPT Model Interaction with FountainAI Services

The **GPT model** plays a central role in coordinating various services within the FountainAI system. It acts as the interface between the user and the APIs, ensuring that any destructive actions (e.g., updating or deleting data) are monitored and can be undone through version control.

The following diagram provides a visual representation of the interaction between the GPT model and the key services in FountainAI:
![GPT Model Interaction with FountainAI Services](https://coach.benedikt-eickhoff.de/koken/storage/originals/3d/73/FountainAI-v3.png)

![Undo with FountainAI Services](https://coach.benedikt-eickhoff.de/koken/storage/originals/a8/fe/undo.png)

### Explanations:

- **GPT Model (Center)**: The GPT model acts as the orchestrator, handling all interactions with the various FountainAI services. It enforces the logic behind undo actions, ensuring that destructive operations are reversible.
  
- **Core Script Management API**: Manages the creation, updating, and deletion of scripts and sections. The GPT model ensures that versioning is applied before changes to scripts are made.
  
- **Character Service**: Manages characters within the narrative. Any modifications to character data are logged by the GPT model, allowing users to undo changes.
  
- **Action Service**: Handles character actions in the story. The GPT model tracks these actions and allows them to be reverted if necessary.

- **Paraphrase Service**: Responsible for managing paraphrased dialogue. The GPT model enforces undo capabilities when paraphrasing or editing dialogue content.
  
- **Central Sequence Service**: Ensures that the sequence of events in the narrative is preserved. The GPT model uses this service to maintain the correct sequence during undo operations.
  
- **Story Factory API**: Provides orchestration and context for the story. The GPT model interacts with this service to manage and revert content changes in the storyline.

- **Spoken Word Service**: Manages the dialogue lines spoken by characters. Changes to spoken words are versioned, ensuring they can be reverted.

- **Session and Context Management API**: Tracks the session and context for user interactions, ensuring that undo requests are tied to the appropriate session context.

- **Performer Service**: Manages the performers involved in the story. The GPT model ensures any updates to performers can be reversed if necessary.

### Enforcing Undo and Destructive Action Awareness

The GPT model is configured to ensure that all potentially destructive actions, such as updating or deleting characters, scripts, or actions, are preceded by versioning through the **version control APIs**. Before any changes are finalized, the model:
1. Creates a **version** of the current state.
2. Allows the user to proceed with the changes.
3. Provides the option to **undo** those changes if needed.

This ensures that **data integrity** is maintained, and any accidental or undesired modifications can be easily reversed.

---

## Key Components of the Undo Feature

### 1. Versioning Before Every Destructive Action
For any update or deletion action that could overwrite or remove data, a **new version** of the entity will be created and stored by the GPT model. This version will act as the **undo point**, allowing users to revert to the previous state.

   **APIs Used**:  
   - `createVersion`: To create a version of an entity (script, section, character, etc.) before making changes.

   Example:
   ```typescript
   await createVersion({
       elementType: "script",  // or "section", "character", etc.
       elementId: scriptId,    // ID of the entity being modified
   });
   ```

### 2. Reverting to a Previous Version
When a user requests an "Undo," the system, via the GPT model, will retrieve the last saved version of the entity and restore it. This operation uses the version history saved through the `createVersion` API.

   **APIs Used**:
   - `getScriptById`, `getCharacterById`, etc.: To retrieve the last version saved.
   - `updateScript`, `patchCharacter`: To revert to the previous version using the data retrieved.

   Example:
   ```typescript
   await updateScript({
       scriptId: previousScriptId,  // ID of the script to be reverted
       title: previousTitle,
       author: previousAuthor,
       sections: previousSections,
   });
   ```

### 3. User Interaction with Undo
After every potentially destructive action (e.g., updates, deletions), the GPT model will prompt the user with the option to **undo** the change. The action will be **reversible** until the user confirms or continues without undoing.

   Example user interaction:
   ```plaintext
   "The character has been updated. Do you want to undo this change? (Yes/No)"
   ```

### 4. Multiple-Level Undo
If needed, the system can also allow for **multiple levels of undo** by keeping a **version history** for each entity. Users could revert changes beyond just the last action, enabling restoration to earlier points in the development of scripts, characters, or dialogue.

---

## Conclusion

By utilizing FountainAI's existing versioning APIs, the **Undo feature** can be seamlessly integrated into the system, providing users with the flexibility and safety they need when making changes to scripts, characters, and other story elements. The GPT model plays a central role in enforcing destructive action awareness and ensuring that all actions are reversible, improving the overall user experience.

---

**Authors**:  
- Benedikt Eickhoff
- mail@benedikt-eickhoff.de

**Date**:  
- October 8, 2024

---

This document serves as the formal proposal for the Undo feature implementation in FountainAI, with the GPT model enforcing awareness of destructive actions and enabling the Undo functionality.

