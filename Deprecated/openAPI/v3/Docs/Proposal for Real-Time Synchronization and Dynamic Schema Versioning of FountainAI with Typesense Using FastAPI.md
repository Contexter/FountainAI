
# Proposal for Real-Time Synchronization and Dynamic Schema Versioning of FountainAI with Typesense Using FastAPI

## 1. Executive Summary

This proposal outlines a solution to integrate **real-time synchronization** and **dynamic schema versioning** between **SQLite** and **Typesense** using **FastAPI** within the **FountainAI** platform. FastAPI will act as the intermediary service, ensuring that changes to data in SQLite are immediately synced with the corresponding Typesense collections and that Typesense schemas dynamically update when SQLite schema changes occur.

The solution will enable real-time reflection of SQLite data in Typesense, ensuring consistency and fast, accurate search results for FountainAI users. The system will also handle dynamic schema changes, automatically updating the Typesense schema without manual intervention when new fields are added or modified in the SQLite database.

---
![Event Driven Workflow](https://coach.benedikt-eickhoff.de/koken/storage/originals/bb/19/FoutainAI-System-Architecture-Event-Driven-Workflow-and-FastAPI-Sync-Process.png)



## 2. Background

**FountainAI** is a platform that handles complex storytelling workflows, including character management, script writing, and session context. The platform's microservices store data in **SQLite** databases, and Typesense is used for fast, typo-tolerant, real-time search across the data. Currently, syncing between SQLite and Typesense happens statically, leading to delays in reflecting data changes, and schema updates are manual, leading to additional maintenance overhead.

To enhance the system’s scalability and performance, this proposal suggests using **FastAPI** to implement a **real-time sync** and **dynamic schema versioning** mechanism between SQLite and Typesense, addressing both data consistency and schema adaptability in an automated manner.

---

## 3. Objectives

The primary goals of this proposal are:

1. **Implement Real-Time Data Synchronization**: Ensure that all data modifications in SQLite are immediately synced to the corresponding Typesense collections via FastAPI, allowing for real-time search and retrieval.
   
2. **Dynamic Schema Versioning**: Automatically detect changes in the SQLite schema and update the corresponding Typesense collection schemas, ensuring that any new or modified fields are reflected dynamically without requiring manual intervention.

3. **FastAPI-Based Architecture**: Leverage FastAPI for its performance and simplicity to create a service that listens to SQLite triggers and detects schema changes in real-time, syncing the changes with Typesense collections.

---

## 4. Proposed Solution

### 4.1 Real-Time Synchronization Using FastAPI

We propose using **FastAPI** to handle real-time synchronization between SQLite and Typesense. This will be accomplished using **SQLite triggers** to fire HTTP requests to FastAPI endpoints whenever a data modification occurs (insert, update, or delete).

**Key Steps**:

- **SQLite Triggers**: Triggers will detect data changes in key tables (e.g., `characters`, `scripts`, `sessions`) and fire HTTP requests to FastAPI.
  
- **FastAPI Endpoints**: These endpoints will receive the data from the triggers and send API requests to Typesense, ensuring that the corresponding collection is updated.

**Example Workflow**:
1. **INSERT, UPDATE, or DELETE**: When a row is inserted, updated, or deleted in SQLite, the trigger fires a request to the relevant FastAPI endpoint.
2. **FastAPI Sync**: The FastAPI service then formats the data and sends it to Typesense to either create, update, or delete the document in the appropriate collection.
3. **Immediate Reflection**: The Typesense collection is immediately updated, allowing real-time search to reflect the changes.

---

### 4.2 Dynamic Schema Versioning Using FastAPI

FastAPI will also be used to implement **dynamic schema versioning**. This service will periodically check for schema changes in SQLite and dynamically update the Typesense collection schema to ensure compatibility with any new fields or modified structures.

**Key Steps**:

- **Schema Monitoring**: FastAPI will periodically query SQLite to check the structure of key tables. When a new column is detected (e.g., a new field added to `characters`), FastAPI will initiate an update to the corresponding Typesense collection.

- **Schema Update in Typesense**: Once a schema change is detected, FastAPI will send a **PATCH** request to Typesense to add or modify the collection fields accordingly, ensuring seamless querying across both systems.

**Example Workflow**:
1. **Detect Schema Change**: FastAPI checks the SQLite schema using PRAGMA queries and detects that a new field (e.g., `age`) has been added.
2. **Typesense Update**: FastAPI sends a request to Typesense to update the schema of the relevant collection, adding the new `age` field.
3. **Search Continuity**: The system remains functional, with the Typesense schema dynamically updated to reflect the changes in SQLite, avoiding any query failures due to mismatched schemas.

---

## 5. Implementation Plan

### 5.1 Real-Time Synchronization

- **Define SQLite Triggers**: Triggers will be created for each key table to detect `INSERT`, `UPDATE`, and `DELETE` operations.
  
  Example Trigger:
  ```sql
  CREATE TRIGGER sync_insert AFTER INSERT ON characters
  BEGIN
      SELECT sync_data_to_fastapi('INSERT', NEW.characterId, NEW.name, NEW.description, NEW.dialogueText);
  END;
  ```

- **Develop FastAPI Endpoints**: FastAPI endpoints will be created to handle the real-time syncing by receiving data from the triggers and syncing it with Typesense.

  Example FastAPI Endpoint:
  ```python
  @app.post("/sync/insert")
  async def sync_insert(characterId: int, name: str, description: str, dialogueText: str):
      # Sync logic to Typesense
  ```

- **Test Data Sync**: Set up tests to ensure that data modifications in SQLite are immediately reflected in Typesense.

### 5.2 Dynamic Schema Versioning

- **Schema Monitoring Service**: FastAPI will periodically query SQLite to detect schema changes (e.g., every 24 hours) using PRAGMA queries:
  
  Example PRAGMA Query:
  ```sql
  PRAGMA table_info(characters);
  ```

- **Typesense Schema Update**: FastAPI will automatically detect when new fields are added in SQLite and send a **PATCH** request to Typesense to update the collection schema.

  Example PATCH Request to Typesense:
  ```python
  schema_update = {
      "fields": [{"name": "age", "type": "int32"}]  # Adding a new field
  }
  requests.patch(f"{TYPESENSE_HOST}/collections/characters", json=schema_update, headers=headers)
  ```

- **Test Schema Updates**: Ensure that when a new field is added in SQLite, it is automatically reflected in Typesense without requiring manual intervention.

---

## 6. Expected Results

By implementing real-time synchronization and dynamic schema versioning with FastAPI, the following outcomes are expected:

- **Immediate Data Sync**: Any change in the SQLite database (inserts, updates, deletes) will be instantly reflected in Typesense, ensuring real-time searchability for users.
  
- **Automated Schema Updates**: Typesense collections will be automatically updated when new fields are added or modified in SQLite, ensuring that schema mismatches are prevented, and the system remains flexible and scalable.

- **Improved Performance**: FastAPI’s asynchronous handling of HTTP requests will ensure that sync and schema updates are performed efficiently without blocking other operations, improving overall system responsiveness.

---

## 7. Timeline and Milestones

| **Milestone**                     | **Duration**         | **Details**                                       |
|------------------------------------|----------------------|---------------------------------------------------|
| Planning and Design                | 1 Week               | Finalize the design of triggers and FastAPI endpoints |
| Trigger and Sync Implementation    | 2 Weeks              | Develop SQLite triggers and FastAPI sync logic    |
| Dynamic Schema Versioning Setup    | 2 Weeks              | Implement schema detection and automatic updates |
| Testing and Integration            | 1 Week               | Test real-time sync and schema updates            |
| Deployment and Monitoring          | 1 Week               | Deploy the solution and monitor real-time syncing and schema versioning |

---

## 8. Resources and Tools

- **SQLite**: Used for database management in FountainAI.
- **Typesense**: The search engine for storing and retrieving indexed data in real-time.
- **FastAPI**: To handle HTTP requests for syncing data and updating schema dynamically.
- **Python**: To develop the sync and schema update logic.
- **PRAGMA Queries**: For detecting SQLite schema changes.
- **Requests Library**: To send API requests to Typesense.

---

## 9. Risks and Mitigation

| **Risk**                                    | **Likelihood**  | **Mitigation Strategy**                                                                 |
|---------------------------------------------|-----------------|-----------------------------------------------------------------------------------------|
| Data Sync Conflicts                         | Medium          | Implement error handling and retry mechanisms in FastAPI to resolve conflicts            |
| Schema Mismatches (SQLite ↔ Typesense)      | Low             | Automate schema detection and apply updates dynamically to avoid manual intervention     |
| FastAPI Performance Degradation             | Low             | Utilize FastAPI’s async capabilities to handle high-volume requests efficiently         |

---

## 10. Conclusion

By leveraging **FastAPI** for real-time synchronization and dynamic schema versioning, **FountainAI** will benefit from immediate data consistency between SQLite and Typesense and the flexibility to adapt to schema changes without downtime. This solution will enhance the platform’s scalability, improve user experience with real-time search, and simplify the maintenance of schema changes as the system evolves.

