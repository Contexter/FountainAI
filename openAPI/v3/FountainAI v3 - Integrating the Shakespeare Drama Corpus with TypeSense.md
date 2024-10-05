# FountainAI - Integrating the Shakespeare Drama Corpus with TypeSense
> Managing Story

## **Introduction**

FountainAI is designed to manage complex storytelling workflows, with a focus on creative writing, narrative assembly, and text management. This documentation describes the **integration of TypeSense** as a full-text search engine to efficiently store, index, and retrieve texts from the **Shakespeare Drama Corpus** (a collection of Shakespeare’s plays, following the scientific standard set by the DraCor project). By utilizing **TypeSense**, FountainAI offers enhanced capabilities for quickly searching, ordering, and retrieving specific sections, dialogues, and sequences across large datasets within the Shakespeare Drama Corpus.

### **Objective**

The key objective is to seamlessly integrate **TypeSense** into the existing APIs of FountainAI to:
- Efficiently **store and index large texts**, such as the Shakespeare Drama Corpus.
- Provide **dynamic retrieval** of specific lines, sections, or actions within the narrative.
- Allow **full-text search** capabilities to explore themes, characters, and dialogues.
- Ensure a **coherent sequencing** of story elements with support for reordering, versioning, and context-aware sessions.

### **Use Cases**
1. **Retrieve Specific Lines or Sections**: Fetch lines from any Shakespeare play (e.g., sections of *Romeo and Juliet* or *Hamlet*) by line number or dialogue from the Shakespeare Drama Corpus.
2. **Full-Text Search**: Quickly search for keywords, characters, or themes across the Shakespeare Drama Corpus.
3. **Efficient Story Assembly**: Dynamically retrieve and sequence story elements in real time, allowing for flexible narration.
4. **Session-Specific Context**: Track user or character sessions to retrieve their last position in a story or scene, supporting contextual storytelling.

---

## **Architecture Overview**

### **Components**

1. **TypeSense Instance**:
   - **TypeSense** acts as the search engine backend, where the Shakespeare Drama Corpus is indexed and stored. It provides fast full-text search and retrieval, supporting queries based on line numbers, characters, or actions.
   - TypeSense can handle large datasets, making it ideal for indexing the entire Shakespeare Drama Corpus and providing efficient access to specific sections.

2. **FountainAI APIs**:
   - FountainAI is composed of several core APIs that manage characters, scripts, sequences, and sessions. TypeSense seamlessly integrates with these APIs to provide optimized text retrieval and management.
   - Each API utilizes TypeSense to handle specific elements of storytelling, such as character management, script ordering, and session tracking.

---

## **FountainAI Integration Points**

### **1. Story Factory API** ([source](https://github.com/Contexter/FountainAI/blob/main/openAPI/v2/Story-Factory-API.yml))

The **Story Factory API** integrates data from various services to assemble and manage the logical flow of stories, including scripts, characters, spoken words, and actions.

- **TypeSense Role**: TypeSense stores and indexes full texts from the **Shakespeare Drama Corpus**. It enables fast retrieval of story elements (e.g., lines, scenes, or specific dialogues) by querying the TypeSense instance based on the play name or specific line numbers.
  
- **API Enhancements**: When retrieving a full story or a portion of it, TypeSense enables efficient fetching of text-based elements, such as:
  - Specific sections of a script (e.g., Act 1, Scene 1 of *Romeo and Juliet*).
  - Character-specific dialogues or actions.
  - Contextual data (e.g., mood, location) associated with story elements.

- **Example Use Case**: A user requests lines 1-50 from a play within the Shakespeare Drama Corpus, which are efficiently retrieved by querying the TypeSense instance and assembling the result in logical order.

---

### **2. Central Sequence Service API** ([source](https://github.com/Contexter/FountainAI/blob/main/openAPI/v2/Central-Sequence-Service-API.yml))

The **Central Sequence Service API** manages the sequence of elements (scripts, sections, actions, etc.) to maintain logical order and consistency within a story.

- **TypeSense Role**: TypeSense supports dynamic reordering and retrieval of sequences by enabling fast updates and reindexing of story elements.
  
- **API Enhancements**: By integrating with TypeSense, the sequence service can efficiently:
  - Update the sequence numbers of elements (e.g., changing the order of scenes).
  - Retrieve ordered sections or dialogues from large texts within the Shakespeare Drama Corpus, ensuring proper flow.
  - Support versioning of scripts or elements by quickly fetching new versions from TypeSense.

- **Example Use Case**: Reordering sequences within a Shakespearean play from the Shakespeare Drama Corpus to change the order of actions or dialogues dynamically.

---

### **3. Character Management API** ([source](https://github.com/Contexter/FountainAI/blob/main/openAPI/v2/Chatacter-Management-API.yml))

The **Character Management API** handles the creation and management of characters, their actions, and spoken words within a story.

- **TypeSense Role**: TypeSense indexes character dialogues, actions, and paraphrases, allowing for fast and flexible searching across entire works. This enables querying character-specific lines, actions, and paraphrases.

- **API Enhancements**: The API leverages TypeSense to:
  - Allow full-text search for character lines (e.g., "O Romeo, Romeo, wherefore art thou Romeo?").
  - Fetch character-specific actions and paraphrases across multiple scenes or plays.
  - Enable filtering by character name to retrieve all spoken words or actions performed by a specific character.

- **Example Use Case**: A user requests all spoken words by Juliet from the Shakespeare Drama Corpus, and the system efficiently retrieves these lines from TypeSense.

---

### **4. Core Script Management API** ([source](https://github.com/Contexter/FountainAI/blob/main/openAPI/v2/Core-Script-Management-API.yml))

The **Core Script Management API** manages scripts, section headings, and transitions, supporting reordering and versioning of scripts and sections.

- **TypeSense Role**: TypeSense serves as a backend for storing entire scripts from the Shakespeare Drama Corpus, enabling efficient querying and retrieval of sections based on line numbers or headings.

- **API Enhancements**: TypeSense enhances the API by:
  - Allowing dynamic reordering of script sections, ensuring logical flow even as sections are rearranged.
  - Supporting pagination and filtering to retrieve only specific portions of a script.
  - Providing fast access to specific parts of a script, such as Act 3, Scene 2 of *Hamlet*.

- **Example Use Case**: A user requests a portion of a play from the Shakespeare Drama Corpus (e.g., Act 1, Scene 1), and TypeSense efficiently returns the relevant section.

---

### **5. Session and Context Management API** ([source](https://github.com/Contexter/FountainAI/blob/main/openAPI/v2/Session-And-Context-Management-API.yml))

The **Session and Context Management API** handles session-specific data, allowing users or characters to track their progress in a story or maintain context.

- **TypeSense Role**: TypeSense can store session-specific data (e.g., the last retrieved line or section) and enable fast retrieval of context within a session.

- **API Enhancements**: TypeSense enhances this API by:
  - Storing session-specific context, such as the last line or action a user interacted with in a play.
  - Allowing efficient retrieval of the user’s position in a play, enabling them to resume from where they left off.
  - Supporting context-aware storytelling by maintaining session history and tracking progress dynamically.

- **Example Use Case**: A user resumes a session, and TypeSense retrieves the last dialogue or scene from a play within the Shakespeare Drama Corpus that the user viewed.

---

## **TypeSense Integration Workflow**

1. **Text Indexing**:
   - Plays within the **Shakespeare Drama Corpus** are read line-by-line and indexed into TypeSense.
   - Each line, action, or spoken word is stored as a document, allowing for precise querying by line number, character, or dialogue.

2. **Querying and Retrieval**:
   - Users query the TypeSense instance through FountainAI APIs to retrieve specific sequences, lines, or character actions.
   - The APIs integrate TypeSense to fetch only the relevant portions of a script, enhancing performance and flexibility.

3. **Reordering and Versioning**:
   - TypeSense supports dynamic reordering of elements within a script, ensuring logical consistency as sections or dialogues are rearranged.
   - Versioning of scripts or individual elements is managed by the APIs and supported by TypeSense for fast retrieval of previous versions.

---

## **Conclusion**

Integrating **TypeSense** into FountainAI provides a scalable, efficient solution for managing large text corpora like the **Shakespeare Drama Corpus**. By leveraging TypeSense’s full-text search capabilities, FountainAI enables rapid retrieval, flexible reordering, and efficient session management, enhancing storytelling workflows for creators, scholars, and users alike.

### **Key Benefits**:
- **High Performance**: TypeSense enables fast retrieval of large texts, improving performance for both querying and reordering operations.
- **Full-Text Search**: Users can perform detailed searches for specific lines, characters, or actions across large datasets.
- **Dynamic Storytelling**: FountainAI can dynamically assemble stories and sequences, leveraging TypeSense to handle large texts efficiently.

This approach supports future scalability and enhanced storytelling capabilities, making FountainAI a robust platform for creative text management and narrative assembly.

---

Let me know if there’s anything else you’d like to adjust!