# FountainAI  
> Managing Story

## **Overview** (DRAFT)

**FountainAI** is an AI-powered platform designed to generate, manage, and evolve interactive stories in real-time. It leverages artificial intelligence to create dynamic, adaptable narratives where characters, events, and plots shift based on user interactions or predefined inputs.

At its core, FountainAI focuses on storytelling that can evolve continuously, making it ideal for applications like video games, virtual storytelling environments, educational simulations, or even interactive fiction. Users can interact with the narrative, and the system responds by adapting characters, actions, and story arcs, offering a unique, ever-changing experience each time.

The platform uses advanced AI, such as GPT-4, to creatively handle open-ended story elements, filling in gaps where needed, which allows for more organic and less rigid storytelling. Whether the focus is on characters' development, plot twists, or evolving contexts, FountainAI ensures that the story remains cohesive, engaging, and immersive.

In short, **FountainAI** is a storytelling engine designed to create flexible, AI-driven narratives that adapt and respond dynamically to inputs, making it ideal for applications where interactivity and adaptability are key.

---

## **Core Services Overview**

FountainAI is built around several key microservices, each responsible for managing a crucial part of the storytelling process. These services are linked through a unified API system, allowing developers to seamlessly orchestrate dynamic and interactive stories.

### 1. **Action Service**  
The **Action Service** manages actions performed by characters within the story, such as behaviors, movements, and interactions. This service supports full **CRUD** (Create, Read, Update, Delete) operations, enabling the creation and management of actions while ensuring that they are properly sequenced in the narrative.

- [Action Service API (v3)](openAPI/v3/Action-Service.yml)

---

### 2. **Central Sequence Service**  
The **Central Sequence Service** manages sequence numbers for all storytelling elements like scripts, characters, and actions. It ensures that all components of the story progress in a logical order, maintaining narrative consistency.

- [Central Sequence Service API (v3)](openAPI/v3/Central-Sequence-Service-API.yml)

---

### 3. **Character Management Service**  
The **Character Management Service** is responsible for creating, updating, and tracking the development of characters within the story. Characters are linked to their actions, interactions, and evolution within the narrative.

- [Character Service API (v3)](openAPI/v3/Character-Service.yml)

---

### 4. **Core Script Management Service**  
The **Core Script Management Service** handles the structure and evolution of the overarching story. It dynamically adapts the script based on the characters, actions, and other elements in real-time, ensuring the narrative remains cohesive and engaging.

- [Core Script Management Service API (v3)](openAPI/v3/Core-Script-Management-API.yaml)

---

### 5. **Paraphrase Service**  
The **Paraphrase Service** allows for dynamic variations in character dialogues, ensuring that characters’ spoken lines can be adapted for different contexts or user inputs. This adds flexibility and diversity to the dialogue system.

- [Paraphrase Service API (v3)](openAPI/v3/Paraphrase-Service.yml)

---

### 6. **Performer Service**  
The **Performer Service** manages virtual actors or performers within the narrative, tracking their actions and behaviors to ensure they align with the evolving story and interactions. 

- [Performer Service API (v3)](openAPI/v3/Performer-Service.yml)

---

### 7. **Session and Context Management Service**  
The **Session and Context Management Service** is responsible for preserving the context of storytelling sessions, ensuring that the narrative adapts and evolves as users interact with characters, actions, and events.

- [Session and Context Management API (v3)](openAPI/v3/Session-And-Context-Management-API.yml)

---

### 8. **Spoken Word Service**  
The **Spoken Word Service** handles the management and sequencing of character dialogues. It ensures that all spoken elements are integrated logically into the narrative, supporting real-time interactions between characters.

- [Spoken Word Service API (v3)](openAPI/v3/Spoken-Word-Service.yml)

---

### 9. **Story Factory Service**  
The **Story Factory Service** is the central engine of FountainAI, assembling all storytelling elements—characters, actions, contexts—into a cohesive narrative. The service dynamically adjusts the story in real-time based on user inputs and events, ensuring an interactive and evolving experience.

- [Story Factory Service API (v3)](openAPI/v3/Story-Factory-API.yml)

---

## **Security Model**

All services in FountainAI are secured using a **unified API key security** mechanism. This ensures that only authorized users can access the APIs, protecting all storytelling elements such as characters, actions, and scripts from unauthorized manipulation.

---

## **Documentation and Proposals**

In addition to the core services, the **openAPI/v3** directory contains several key documents that outline the refactoring process, integration improvements, and the role of **GPT-4** in enhancing the platform:

1. **Critique of v2 FountainAI OpenAPI Specifications: Towards Enhanced Integration and Consistency**  
   [Read Document](openAPI/v3/Docs/Critique%20of%20v2%20FountainAI%20OpenAPI%20Specifications_%20Towards%20Enhanced%20Integration%20and%20Consistency.md)

2. **FountainAI v3 - Integrating the Shakespeare Drama Corpus with TypeSense**  
   [Read Document](openAPI/v3/Docs/FountainAI%20v3%20-%20Integrating%20the%20Shakespeare%20Drama%20Corpus%20with%20TypeSense.md)

3. **FountainAI v3 Documentation: Balancing API Modifications with GPT-4 Reasoning - "What If?"**  
   [Read Document](openAPI/v3/Docs/FountainAI%20v3%20Documentation_%20Balancing%20API%20Modifications%20with%20GPT-4%20Reasoning%20-%20%E2%80%9CWhat%20If%E2%80%9D.md)

4. **FountainAI v3 OpenAPI Implementation Plan: Enhancing Integration for GPT-4 Compatibility**  
   [Read Document](openAPI/v3/Docs/FountainAI%20v3%20OpenAPI%20Implementation%20Plan_%20Enhancing%20Integration%20for%20GPT-4%20Compatibility.md)

5. **FountainAI v3: Enhanced Integration and GPT-4 Compatibility**  
   [Read Document](openAPI/v3/Docs/FountainAI%20v3_%20Enhanced%20Integration%20and%20GPT-4%20Compatibility.md)

6. **Official FountainAI Proposal for Refactoring Character Management API**  
   [Read Document](openAPI/v3/Docs/Official%20FountainAI%20Proposal%20for%20Refactoring%20Character%20Management%20API.md)

7. **Proposal for Real-Time Synchronization and Dynamic Schema Versioning of FountainAI with Typesense Using FastAPI**  
   [Read Document](openAPI/v3/Docs/Proposal%20for%20Real-Time%20Synchronization%20and%20Dynamic%20Schema%20Versioning%20of%20FountainAI%20with%20Typesense%20Using%20FastAPI.md)



