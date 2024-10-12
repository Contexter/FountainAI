![The FountainAI Document Assembling](https://coach.benedikt-eickhoff.de/koken/storage/originals/78/2e/FountainAI-Document-Assembly.png)

The document assembly features of **FountainAI** provide a cohesive system for integrating various parts of a story  into a complete, commonly formatted document. This system relies on several microservices that manage content storage, retrieval, and contextual linking, all accessible through an intuitive API interface. Here's an in-depth look at how FountainAI's document assembly features work and how you can leverage them.

## Overview

FountainAI is designed to facilitate the **sequential upload, storage, and assembly** of narrative content. Each part of a narrative, including **dialogues, actions, and scenes**, is uploaded in a segmented format through dedicated services. These segments are then **reassembled** by the FountainAI system into a complete, cohesive document. This process is optimized by leveraging the capabilities of various FountainAI APIs, with an emphasis on **consistency, ordering, and retrieval**.

## Key Microservices Involved in Document Assembly

FountainAI uses a set of microservices to handle different narrative components, ensuring that the document assembly process is modular and efficient:

- **Core Script Management Service**: Manages the sections and structural hierarchy of the story, such as Acts and Scenes. It provides the foundational segments that form the backbone of a complete narrative.
- **Spoken Word Service**: Manages individual **lines of spoken words** within the story. These lines are grouped into speeches, and this service ensures the correct sequencing of dialogues, incorporating **CRUD operations** that allow for modifications as needed.
- **Character Service**: Manages character-specific information, linking lines of dialogue to specific characters. It allows for a cohesive understanding of who is speaking at any given point.
- **Action Service**: Handles the **actions and stage directions** associated with different scenes and dialogues, ensuring that all non-verbal components of the narrative are captured accurately.
- **Central Sequence Service**: Guarantees that all elements, such as lines and actions, are in the correct **logical sequence**, providing consistency in the ordering of events.
- **Session and Context Management Service**: Manages user sessions and the **contextual relationships** between narrative elements, ensuring that continuity is maintained throughout the assembly process.
- **Story Factory API**: Provides a high-level endpoint to **assemble and retrieve** the complete story, drawing from all other services to ensure that the document is cohesive and correctly formatted.

## Document Assembly Process

### Segmentation and Storage
When a story is uploaded, FountainAI adapts to different types of content. If the uploaded text is simply a collection of unrelated notes, FountainAI will treat it as a set of **independent text segments**. The system dynamically segments the content into logical units, based on structure or paragraph breaks. This segmentation process ensures that each note is stored and can be retrieved independently, while still being accessible through the same overarching story context if needed.

### Storing and Contextual Linking
Each part is stored with unique identifiers, regardless of its traditional or non-traditional nature. The **Character Service** links dialogues (or other segments) to specific characters, while the **Central Sequence Service** maintains the correct order of segments to ensure narrative coherence. For unrelated notes, the system can store them without strict relationships, allowing them to be linked or grouped later if a connection becomes evident.

### Handling Token Limits and Errors
The **Session and Context Management Service** helps manage issues such as token limits by tracking progress, logging where the last processed portion ended, and enabling resumption from the correct point. This service also manages **error handling**, such as identifying missing content and prompting the user to re-upload if necessary.

### Retrieval and Assembly
The **Story Factory API** is used to retrieve all segmented parts and assemble them into a complete story, regardless of the structure of the original content. For unrelated notes, the assembly process can be customized to organize these notes in a meaningful way, such as grouping by topics or creating a chronological order. This API integrates with the **Core Script Management**, **Character**, and **Spoken Word Services** to gather all relevant parts, ensuring they are organized logically.

### Formatting the Final Document
Once all parts are retrieved, the document is formatted into a **commonly recognized format** (e.g., PDF or plain text) that preserves the integrity of the story. FountainAI's adaptability ensures that non-traditional segments, such as unrelated notes, are presented in a reader-friendly manner, with all elements logically aligned or grouped as needed.

## Special Upload: Scientifically Encoded .tei XML Version of a Story

### What is .tei XML?
**TEI (Text Encoding Initiative)** is an XML-based standard used primarily for encoding literary and linguistic texts. It provides a rich and detailed way to represent the structural and semantic aspects of texts, making it especially useful for scholarly editing, analysis, and digital preservation of historical documents, such as plays, poems, and manuscripts.

### Upload and Parsing
When a .tei XML file is uploaded, FountainAI first parses the XML structure to identify key narrative elements. The tags in the .tei XML format (e.g., `<div>`, `<sp>`, `<stage>`) are mapped to the appropriate FountainAI services, such as **Core Script Management**, **Spoken Word**, and **Action Services**. This ensures that all encoded metadata and relationships are preserved during storage.

### Segmentation and Storage with Semantic Tags
The content is segmented based on the XML tags, ensuring that each part, whether a line of dialogue, action, or structural element, is stored with its **semantic meaning** intact. For example, `<div>` tags might correspond to Acts or Scenes, while `<sp>` tags would represent spoken lines. These segments are then stored using the appropriate microservice.

### Contextual Linking and Metadata Preservation
FountainAI leverages the **Character Service** and **Central Sequence Service** to establish relationships between the different segments. The **tei XML** inherently contains rich metadata, which FountainAI uses to link characters, actions, and dialogue, maintaining coherence throughout the narrative.

### Handling Token Limits and Errors
As with other content, the **Session and Context Management Service** handles issues like token limits or interrupted uploads. The XML structure makes it easier to log specific segments, allowing FountainAI to resume from the exact point where it left off, ensuring that no part of the scientifically encoded document is lost.

### Reassembly and Formatting
During reassembly, the **Story Factory API** pulls all relevant parts, using the XML tags to ensure that all segments are placed in the correct order. The formatting process involves transforming the XML-based structure into a **commonly recognized format**, such as PDF or plain text, while retaining the richness of the original XML encoding.

## Conclusion

FountainAI's document assembly features make it easy to upload, store, and retrieve complex narrative content in a structured and consistent manner. By utilizing the various microservices, each part of the narrative is handled independently, but they come together seamlessly to form a cohesive document. When integrated with a custom GPT model, this process becomes even more powerful, allowing for dynamic retrieval, formatting, and error management, ultimately ensuring a rich and coherent storytelling experience.

