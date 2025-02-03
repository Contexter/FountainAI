
# Comprehensive Update Plan for Service A 
> ...and **Future FountainAI Services** with SQLite Persistence and Typesense Integration

This plan incorporates the SQLite persistence layer as the central component for handling data in **Service A** and similar applications. It outlines how data should flow from SQLite to Typesense, ensuring robust local handling, synchronization, and schema alignment.

---

## **Table of Contents**
1. [Goals](#1-goals)
2. [Core Principles](#2-core-principles)
3. [Updates for Service A](#3-updates-for-service-a)
   - a. [SQLite Persistence Layer](#a-sqlite-persistence-layer)
   - b. [Typesense Collection Lifecycle Management](#b-typesense-collection-lifecycle-management)
   - c. [Synchronization Workflow](#c-synchronization-workflow)
   - d. [Resilience and Retry Mechanisms](#d-resilience-and-retry-mechanisms)
   - e. [Integration with Key Management Service (KMS)](#e-integration-with-key-management-service-kms)
   - f. [API Gateway Integration](#f-api-gateway-integration)
   - g. [Monitoring and Logging](#g-monitoring-and-logging)
4. [Blueprint for Future Services](#4-blueprint-for-future-services)
5. [Deployment and Testing Strategy](#5-deployment-and-testing-strategy)
6. [Documentation and Maintenance](#6-documentation-and-maintenance)

---

### **1. Goals**

1. Integrate a **local SQLite database** as the single source of truth for each service, ensuring:
   - Robust local data management.
   - Reliable synchronization with Typesense.
2. Ensure Typesense collections map directly to SQLite tables, providing consistency and ease of use.
3. Enable each service to:
   - Create and manage its Typesense collection dynamically based on the SQLite schema.
   - Handle retries, conflicts, and schema changes gracefully.
4. Provide a **blueprint** for future services, maintaining consistency across the FountainAI ecosystem.

---

### **2. Core Principles**

1. **SQLite as the Source of Truth**:
   - All service data is persisted to a local SQLite database.
   - Typesense collections act as searchable mirrors of this local database.

2. **Typesense Mapping**:
   - Service schemas define both the SQLite table structure and the Typesense collection structure.

3. **Synchronization First**:
   - Changes in SQLite are automatically propagated to Typesense.

4. **Robustness**:
   - Services are resilient to synchronization failures, ensuring data consistency.

5. **Modularity**:
   - Each service independently manages its SQLite database, Typesense schema, and synchronization logic.

---

### **3. Updates for Service A**

#### a. **SQLite Persistence Layer**

##### **Schema Definition**

The SQLite database schema serves as the foundation for both data persistence and Typesense synchronization. It should define the structure, types, and constraints for the data.

**Example Schema**:
```python
from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Element(Base):
    __tablename__ = "elements"

    id = Column(Integer, primary_key=True, index=True)
    element_type = Column(String, nullable=False)
    element_id = Column(Integer, nullable=False)
    sequence_number = Column(Integer, nullable=False)
    version_number = Column(Integer, nullable=False)
    comment = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
```

##### **Local CRUD Operations**

- **Create, Update, Delete**:
   - All operations should first persist changes to SQLite before attempting to sync with Typesense.

**Example Service Logic**:
```python
from sqlalchemy.orm import Session
from .models import Element

def create_element(db: Session, element_data: dict):
    element = Element(**element_data)
    db.add(element)
    db.commit()
    db.refresh(element)
    return element
```

- **Querying Data**:
   - SQLite provides robust querying capabilities for local operations, reducing the load on Typesense.

**Example**:
```python
def get_element_by_id(db: Session, element_id: int):
    return db.query(Element).filter(Element.element_id == element_id).first()
```

##### **Change Logging**

- Add a **changes table** to log operations (create, update, delete). This log ensures that any missed syncs can be retried.

**Example Changes Table**:
```python
class ChangeLog(Base):
    __tablename__ = "change_log"

    id = Column(Integer, primary_key=True, index=True)
    operation = Column(String, nullable=False)  # "create", "update", "delete"
    element_id = Column(Integer, nullable=False)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
```

---

#### b. **Typesense Collection Lifecycle Management**

##### **Schema Alignment**

Each service should define a Typesense schema that maps directly to the SQLite schema.

**Example Mapping**:
```python
SERVICE_A_COLLECTION_SCHEMA = {
    "name": "service_a_collection",
    "fields": [
        {"name": "id", "type": "string"},
        {"name": "element_type", "type": "string"},
        {"name": "element_id", "type": "int32"},
        {"name": "sequence_number", "type": "int32"},
        {"name": "version_number", "type": "int32"},
        {"name": "comment", "type": "string"},
        {"name": "created_at", "type": "string", "facet": True},
        {"name": "updated_at", "type": "string", "facet": True},
    ],
    "default_sorting_field": "sequence_number"
}
```

##### **Ensure Collection**

During service startup:
1. Check if the collection exists in Typesense.
2. If it doesn’t, create it using the schema.

**Implementation**:
```python
def ensure_collection_exists(client, schema):
    try:
        client.collections[schema["name"]].retrieve()
    except ObjectNotFound:
        client.collections.create(schema)
```

---

#### c. **Synchronization Workflow**

1. **Push Changes to Typesense**:
   - For every create, update, or delete operation in SQLite, log the change and push it to Typesense.

2. **Two-Way Sync** (Optional):
   - Sync changes back from Typesense to SQLite if needed.

**Example Sync Logic**:
```python
def sync_to_typesense(db: Session, client, element: Element):
    document = {
        "id": str(element.id),
        "element_type": element.element_type,
        "element_id": element.element_id,
        "sequence_number": element.sequence_number,
        "version_number": element.version_number,
        "comment": element.comment or "",
        "created_at": element.created_at.isoformat(),
        "updated_at": element.updated_at.isoformat(),
    }
    client.collections[SERVICE_A_COLLECTION_SCHEMA["name"]].documents.upsert(document)
```

---

#### d. **Resilience and Retry Mechanisms**

- Use the **change log** to track failed syncs.
- Retry failed syncs using exponential backoff.

**Example Retry Logic**:
```python
def retry_failed_syncs(db: Session, client, max_retries=3):
    failed_changes = db.query(ChangeLog).all()
    for change in failed_changes:
        try:
            # Reattempt synchronization
            element = get_element_by_id(db, change.element_id)
            sync_to_typesense(db, client, element)
            db.delete(change)
            db.commit()
        except Exception as e:
            continue
```

---

#### e. **Integration with Key Management Service (KMS)**

Ensure each service retrieves its Typesense API key from the KMS at startup and rotates it periodically.

**Key Retrieval Example**:
```python
def get_typesense_key_from_kms():
    response = httpx.get(f"{KMS_URL}/keys/service_a", headers={"Authorization": f"Bearer {ADMIN_TOKEN}"})
    return response.json()["api_key"]
```

---

#### f. **API Gateway Integration**

- Enforce JWT validation for all requests routed through the API Gateway.
- Use role-based access control to restrict synchronization operations.

---

#### g. **Monitoring and Logging**

- Use Prometheus for metrics.
- Add structured logging to track Typesense sync operations and retry workflows.

---

### **4. Blueprint for Future Services**

Follow the same architecture:
1. **SQLite for local persistence**.
2. **Typesense as a searchable mirror**.
3. **Change logging for resilience**.
4. **Seamless KMS and API Gateway integration**.

---

### **5. Deployment and Testing Strategy**

- **Unit Tests**: Test SQLite CRUD operations and Typesense sync logic.
- **Integration Tests**: Validate end-to-end workflows between SQLite, Typesense, and KMS.
- **Load Tests**: Ensure the service handles high data volumes.

---

### **6. Documentation and Maintenance**

- Maintain detailed schema documentation.
- Provide operational guides for schema changes, sync monitoring, and troubleshooting.

---

By adhering to this plan, **Service A** and similar services will achieve robust, scalable, and maintainable integrations with SQLite and Typesense, ensuring consistency across the FountainAI ecosystem.