# **API-Driven Sequencing Logic of FountainAI**

## **Overview**
FountainAI implements an **API-driven sequencing logic** to manage **narrative structures**, **workflow execution**, and **version control** within its microservices architecture. This document details the sequencing model, API interactions, and synchronization mechanisms used to maintain **strict order integrity** while enabling **flexible search and filtering**.

---

## **1. Key Sequencing APIs in FountainAI**

### **1.1 Generate Sequence Number**
- **Endpoint:** `POST /sequence`
- **Purpose:** Generates a unique sequence number for an element (e.g., a section, character, or scene).
- **Use Case:** Used to enforce strict order placement within narratives.
- **Example Request:**
```json
{
    "elementType": "section",
    "elementId": 123,
    "comment": "Initializing Section 1 as the moment the protagonist confronts their internal conflict after discovering the antagonist's betrayal."
}
```
- **Example Response:**
```json
{
    "sequenceNumber": 1,
    "comment": "Sequence created successfully to establish the turning point in Act 1."
}
```

---

### **1.2 Reorder Sequences**
- **Endpoint:** `PUT /sequence/reorder`
- **Purpose:** Reorders sequence numbers dynamically across multiple elements.
- **Use Case:** Used for modifying the order of scenes or dialogues.
- **Example Request:**
```json
{
    "elementType": "section",
    "elements": [
        { "elementId": 1, "newSequence": 2 },
        { "elementId": 2, "newSequence": 1 }
    ],
    "comment": "Reordering sections to build suspense before the protagonist's realization that their closest ally has turned against them."
}
```
- **Example Response:**
```json
{
    "updatedElements": [
        { "elementId": 1, "newSequence": 2 },
        { "elementId": 2, "newSequence": 1 }
    ],
    "comment": "Reordered successfully to align with the protagonist’s emotional descent into doubt."
}
```

---

### **1.3 Version Management**
- **Endpoint:** `POST /sequence/version`
- **Purpose:** Creates a new version of an element while preserving its prior sequence.
- **Use Case:** Enables rollback and auditing of previous versions.
- **Example Request:**
```json
{
    "elementType": "section",
    "elementId": 123,
    "comment": "Creating an alternate version where the protagonist confesses their guilt, providing an alternative resolution to the climax."
}
```
- **Example Response:**
```json
{
    "versionNumber": 2,
    "comment": "Version created successfully to explore character vulnerability in the final act."
}
```

---

## **2. Architecture Overview**

### **Transactional Storage (SQLite):**
- Maintains **strict ordering** and **transactional integrity**.
- Serves as the **source of truth** for sequence data.
- Ensures relationships (parent-child hierarchy) and dependencies are preserved.

### **Search and Filtering (Typesense):**
- Provides **flexible search** capabilities by keywords, tags, or metadata.
- Supports **real-time indexing** for fast updates and dynamic queries.
- Allows **semantic filtering** for contextual discovery beyond strict order.

### **Sync Workflow:**
- SQLite writes data first to enforce consistency.
- Changes are **synced to Typesense** immediately for search indexing.
- Typesense allows **search by relevance**, but sequence order is always validated against SQLite.

---

## **3. Query Workflow**

### **3.1 Exact Sequence Queries**
- Use SQLite for strict order lookups.
- Example: Fetch *Act 3, Scene 1.*
```json
POST /sequence
{
    "elementType": "scene",
    "elementId": 3,
    "comment": "Retrieving Scene 3 where Hamlet begins his soliloquy, reflecting his doubts about revenge and mortality."
}
```

### **3.2 Flexible Search Queries**
- Use Typesense for tag-based or keyword searches.
- Example: Search *speeches about mortality.*
```json
POST /typesense/search
{
    "q": "mortality",
    "query_by": "content,tags",
    "sort_by": "sequenceNumber:asc"
}
```

### **3.3 Hybrid Queries**
1. Search in **Typesense** for contextual matches.
2. Validate sequence order using **SQLite**.
3. Combine results for presentation.

---

## **4. Key Features**

1. **Strict Order Enforcement:** SQLite enforces sequence order for transactional consistency.
2. **Dynamic Reordering:** Sequences can be reordered without breaking structural integrity.
3. **Version Control:** Historical data is preserved, enabling iterative development and rollbacks.
4. **Flexible Discovery:** Typesense enhances searchability for themes, tags, and keywords.
5. **Scalable Architecture:** Combines strict storage with flexible indexing for scalability.

---

## **5. Example: Hamlet’s Soliloquy**

**Scenario 1: Exact Retrieval**
- Query: *Fetch Act 3, Scene 1.*
```json
POST /sequence
{
    "elementType": "scene",
    "elementId": 3,
    "comment": "Retrieving Hamlet’s soliloquy as the emotional climax where he questions the purpose of existence."
}
```

**Scenario 2: Semantic Search**
- Query: *Find all speeches about mortality.*
```json
POST /typesense/search
{
    "q": "mortality",
    "query_by": "content,tags",
    "sort_by": "sequenceNumber:asc"
}
```

**Scenario 3: Reordering Scenes**
- Query: *Adjust dramatic tension by reordering scenes.*
```json
PUT /sequence/reorder
{
    "elements": [
        { "elementId": 3, "newSequence": 2 },
        { "elementId": 2, "newSequence": 3 }
    ],
    "comment": "Reordering scenes to amplify tension before Hamlet’s confrontation with Claudius."
}
```

---

## **6. Conclusion**
FountainAI’s **API-driven sequencing logic** combines **transactional consistency** with **flexible search** capabilities. The hybrid approach leverages **SQLite** for data integrity and **Typesense** for advanced filtering and indexing. This ensures scalability, dynamic updates, and semantic query support for complex workflows.



