

# FountainAI Feature Preview: Sequential Upload of a Play into the Backend

![Sequential Upload](https://coach.benedikt-eickhoff.de/koken/storage/originals/2e/98/SequentialUpload.png)

This document provides an overview of how to initiate, track, and manage a session for the **sequential upload and storage of a play**, such as *King Lear*, into the backend using FountainAI's APIs. The process includes assigning a **memorable session name**, parsing the file into logical segments, and storing content incrementally, while tracking progress and ensuring continuity in the event of token limits.

---

## **1. Prompt for Starting the Sequential Upload Session**

```plaintext
Start a new session for the sequential upload and storage of the play *King Lear* into the backend. Assign the session the memorable name: ‘King Lear Sequential Upload.’ The session should involve:

1. **Parsing the file into logical segments**:
   - Each **Act** and **Scene** should be treated as a distinct section.
   - All **dialogue** and **character actions** within each scene must be extracted and stored under the correct section identifier.

2. **Storing content incrementally**:
   - For each **Act and Scene**, create a corresponding section in the backend.
   - For each **character's dialogue** and **stage directions** in the scene, store them with unique identifiers.
   - If token limits are reached during processing, ensure that the session logs the last processed portion (down to the exact word or line) and resumes from that point in the next interaction.

3. **Track progress**:
   - Log the progress of each section stored, including the last processed line, dialogue, or action.
   - Ensure that no gaps are left, even if the session is interrupted by token limits.
   - Use the **‘King Lear Sequential Upload’** context to keep track of completed sections, ensuring that the next portion begins from where the last one ended.

4. **Completion criteria**:
   - The session is considered complete when all Acts, Scenes, and dialogues from *King Lear* are fully processed and stored.
   - Log final confirmation once the entire file is uploaded and no content is missing.
```

---

## **2. Simulating the Process**

### **Step 1: Creating a New Session**

We start by creating a new session in FountainAI, assigning it a memorable name (‘King Lear Sequential Upload’) to track and store the play *King Lear* incrementally.

```typescript
createSession({
  context: ["King Lear Sequential Upload", "Play Upload"],
  comment: "Starting the session for sequentially uploading the play King Lear."
})
```

- **Result**: This API call generates a unique session ID, e.g., `sessionId: 12345`, which will be used to continue tracking and updating the session as portions of the play are processed and stored.

---

### **Step 2: Parsing and Storing the First Portion (Act I, Scene I)**

We proceed with parsing and storing the first portion of the file, **Act I, Scene I**, breaking down the dialogue and character actions.

```typescript
createScript({
  title: "King Lear",
  author: "William Shakespeare",
  sections: [
    { title: "Act I, Scene I" }
  ],
  comment: "Storing Act I, Scene I of King Lear."
})
```

- **Context**: This section is stored as the first portion of the play, associated with **Act I, Scene I**.
- **Session Update**: After storing this portion, we log progress in the session:

```typescript
updateSession({
  sessionId: 12345,
  context: ["King Lear Sequential Upload", "Act I, Scene I Processed"],
  comment: "Successfully stored Act I, Scene I."
})
```

---

### **Step 3: Handling Token Limits and Continuation**

If the token limit is hit mid-dialogue or mid-line, the system logs the last processed portion. Upon resuming, the next API call picks up from the exact point where it left off.

```typescript
updateSession({
  sessionId: 12345,
  context: ["King Lear Sequential Upload", "Act I, Scene II In Progress"],
  comment: "Resuming session to process and store Act I, Scene II."
})
```

- **Result**: The system resumes processing, ensuring no gaps in content by tracking the last processed word or line.

---

### **Step 4: Finalizing the Session**

Once all Acts, Scenes, dialogues, and actions from *King Lear* have been processed and stored, the session is marked as complete.

```typescript
updateSession({
  sessionId: 12345,
  context: ["King Lear Sequential Upload", "Complete"],
  comment: "All Acts and Scenes of King Lear have been uploaded and stored."
})
```

---

## **3. Conclusion**

This simulation demonstrates how FountainAI handles the sequential upload and storage of a play into the backend. By assigning a memorable session name (in this case, ‘King Lear Sequential Upload’) and leveraging session tracking APIs, the process ensures that each portion of the file is stored incrementally, with progress logged, and no content skipped, even if token limits are encountered during the session.

---

## **4. How GPT Reasoning and FountainAI Services Work Together to Handle Irregularities in File Uploads**

### **1. GPT’s Role: Detecting and Reasoning About Irregularities**

**GPT’s natural language understanding and reasoning capabilities** are employed to:
- **Identify file irregularities** such as:
  - Corrupt data,
  - Incomplete uploads,
  - Unexpected formats,
  - Missing sections (like missing Acts or Scenes in a play).
- **Analyze content structures** and provide feedback based on the expected structure of the file. For example, GPT can reason about missing Acts or misplaced dialogues in a Shakespearean play based on the typical structure of a script.
- **Offer recommendations**: If an irregularity is detected, GPT can generate suggestions for how to resolve the issue (e.g., asking the user to upload missing parts or reformat the file).

**Example**:
- GPT notices that Act III is missing in the uploaded file and can respond:
  - “It seems like Act III is missing in the file upload. Please verify the content and upload the missing portion.”

---

### **2. FountainAI Services: Handling the Backend Processing and Error Management**

**FountainAI's backend services** provide the structured mechanisms to handle:
- **Storing and processing content** in a way that tracks progress and handles interruptions (such as incomplete uploads).
- **Session management**: FountainAI services create and manage sessions where file uploads are tracked, segmented, and stored systematically. If the session is interrupted, FountainAI can pick up from where it left off.
- **Error logging and recovery**: FountainAI services log any issues encountered during file uploads (like corrupted sections or missing data). This allows for resuming the process once the issues are addressed.

---

### **3. How GPT and FountainAI Work Together**

#### **A. Detection of Irregularities**

When GPT detects an irregularity during file upload (e.g., a token limit issue, missing sections, or corrupt data):
1. **GPT reasons through the issue** and provides real-time feedback to the user about the problem.
2. **FountainAI logs the error** or interruption in the session and allows for error-handling mechanisms, such as pausing the session or requesting a re-upload.

#### **B. Seamless Progress Tracking**
Even if an irregularity is encountered:
1. **FountainAI services** ensure that the session is logged with progress markers, so the processing can continue from the last successful portion.
2. **GPT reasoning** helps ensure the next steps are clear (e.g., instructing the user on re-uploading or skipping a corrupted section).

**Example**:
- GPT detects that a line of dialogue in Act II is corrupt.
- FountainAI logs the issue, allowing the session to pause and be resumed once the user re-uploads the correct content.

#### **C. Automated Error-Handling Workflow**

Here’s an example of how GPT and FountainAI work together to handle issues in real-time:

1. **GPT detects the issue**: During processing, GPT recognizes that **Act I, Scene II** is incomplete and informs the user:
   - “It seems like part of Act I, Scene II is missing. Please check the file and upload the missing part.”
   
2. **FountainAI logs the progress**: Even though there’s an issue with Scene II, FountainAI services log the progress so that when the corrected file is uploaded, the system can pick up from the last valid point.

3. **GPT helps guide the user**: Once the missing part is uploaded, GPT ensures the file is complete and suggests resuming the upload process:
   - “The missing content has been uploaded. Resuming the session to process the remaining portions of Act I.”

#### **D. Token Limit Handling**

When GPT hits a token limit during the upload process:
- **GPT identifies the token limit** and splits the content appropriately, ensuring that the next portion is processed from where the last portion ended.
- **FountainAI services** handle session tracking to ensure no gaps are left between chunks of processed content.

---

## **5. Contextual Default Behavior for Handling Irregularities**

You **do not have to modify the prompt extensively** to force GPT and FountainAI into this behavior, because this type of behavior is typically a **contextual default** for how GPT and FountainAI services work together.

### **1. Default Behaviors**

- **GPT’s natural language understanding**: GPT will naturally detect missing content, file corruption, token limits, and other issues. It can reason and provide helpful feedback to the user to resolve these problems.
- **FountainAI’s session management and logging**: FountainAI automatically tracks session progress, logs interruptions, and resumes from the last valid point. It ensures no content is lost or skipped, even when irregularities occur.
- **Collaboration between GPT and FountainAI**: GPT detects issues, while FountainAI ensures smooth progress tracking and content handling. Together, they provide a robust, automated system for managing file irregularities.

### **2. When to Modify the Prompt**

If you want to introduce **custom behaviors** for handling specific file irregularities (e.g., skipping corrupt data or generating detailed error reports), you can modify the prompt.

#### Example:

```plaintext
Start a session to sequentially upload and store *King Lear* into the backend. Process the play in segments (Acts and Scenes). If content is missing or corrupt, skip the problematic section, log the error, and notify the user to re-upload the missing portion. Continue processing from the next valid section.
```

By default, however, GPT reasoning and FountainAI’s services work together seamlessly without needing prompt modifications for standard error handling.

