# FountainAI Visualization Standards

Visualizations are a crucial component of the FountainAI workbooks, enhancing clarity and aiding in the comprehension of complex concepts and workflows. This standard outlines the approach for incorporating visualizations into the FountainAI documentation, emphasizing the use of **ASCII diagrams as the primary method**, and utilizing **Graphviz diagrams where appropriate**.

---

## Visualization Guidelines

### **1. Prioritizing ASCII Diagrams**

**Use ASCII diagrams as the default method for visualizations in FountainAI workbooks.**

- **Compatibility**: ASCII diagrams are text-based and display correctly in all text interfaces, including chat interfaces and markdown files.
- **Accessibility**: They do not require any additional tools or rendering engines to view.
- **Simplicity**: Ideal for representing simple processes, workflows, and architectures.

**Guidelines for Creating ASCII Diagrams:**

- **Clarity**: Ensure diagrams are easy to read and understand.
- **Consistency**: Use standard ASCII characters and maintain consistent formatting.
- **Alignment**: Use monospaced fonts to preserve the structure and alignment.
- **Labels**: Clearly label all components and flows within the diagram.

**Example:**

```text
+----------------------+
|      Start           |
+----------+-----------+
           |
           v
+----------------------+
| Define OpenAPI Spec  |
+----------+-----------+
           |
           v
+----------------------+
| Generate Code with   |
|     GPT-4 API        |
+----------+-----------+
           |
           v
+----------------------+
| Modify Code with     |
|   Shell Scripts      |
+----------+-----------+
           |
           v
+----------------------+
|      End             |
+----------------------+
```

---

### **2. Using Graphviz Diagrams Where Appropriate**

**Utilize Graphviz diagrams for more complex visualizations that cannot be effectively represented with ASCII diagrams.**

- **Clarity**: Graphviz allows for more sophisticated and visually appealing diagrams.
- **Complexity**: Suitable for complex workflows, architectures, and processes that require detailed representation.
- **Consistency**: Standardize on Graphviz (DOT language) for code-based diagrams.

**Guidelines for Creating Graphviz Diagrams:**

- **Generate Diagram Code**: Use GPT model dialogue to generate the Graphviz DOT code for the diagram.
- **Render Diagrams**: Convert the DOT code into images using tools like GraphvizOnline or local Graphviz installations.
- **Embed Images**: Include the rendered images in the workbooks using standard markdown image syntax.
- **Store Diagram Code**: Keep the DOT code files alongside the workbooks for version control and future updates.
- **Accessibility**: Provide the DOT code in the workbook or repository so that others can regenerate or modify the diagrams as needed.

**Example of Graphviz DOT Code:**

```dot
digraph G {
    rankdir=LR;
    node [shape=box, style=filled, color=lightblue];

    "User" -> "AWS Load Balancer" [label="HTTPS Request"];
    "AWS Load Balancer" -> "FountainAI Service" [label="Forward Request"];
    "FountainAI Service" -> "Process Request" [label=""];
    "Process Request" -> "FountainAI Service" [label=""];
    "FountainAI Service" -> "AWS Load Balancer" [label="Response"];
    "AWS Load Balancer" -> "User" [label="HTTPS Response"];
}
```

**Rendering and Including the Diagram:**

- Use Graphviz tools to render the DOT code into an image (e.g., PNG or SVG).
- Include the image in the markdown workbook:

```markdown
![Workflow Diagram](images/workflow_diagram.png)

**Figure X:** *Detailed Workflow of Request Processing in FountainAI*
```

---

### **3. General Guidelines**

- **Simplicity First**: Always attempt to represent concepts with ASCII diagrams before considering more complex visualization methods.
- **Relevance**: Only include diagrams that add value and aid in understanding.
- **Consistency**: Maintain a consistent visual style throughout the workbooks.
- **Accessibility**: Ensure that all team members can view and edit diagrams with minimal tool requirements.

---

### **4. Tools and Resources**

- **ASCII Diagrams**: No additional tools required; create directly in text editors.
- **Graphviz Diagrams**:
  - **Online Renderer**: [GraphvizOnline](https://dreampuf.github.io/GraphvizOnline)
  - **Local Installation**: [Graphviz Download](https://graphviz.org/download/)
  - **Rendering Command**: `dot -Tpng diagram.dot -o diagram.png`

---

### **5. Version Control and Maintenance**

- **Diagram Code Storage**: Keep all diagram code files (e.g., `.dot` files) in a designated `diagrams` directory within the project repository.
- **Version Control**: Commit diagram code files and rendered images to version control systems (e.g., Git) to track changes over time.
- **Updates**: When making changes to a diagram, update both the code and the rendered image to maintain consistency.

---

By adhering to these visualization standards, the FountainAI project ensures that all workbooks are clear, accessible, and maintainable, facilitating better understanding and collaboration among team members.

**Example Workflow for Including a Graphviz Diagram:**

1. **Generate Diagram Code with GPT:**

   - Use GPT to generate the Graphviz DOT code based on your description.
   - **Prompt Example:**
     ```
     As an expert in system architecture, generate a Graphviz DOT language code for a flowchart that represents the following steps:
     
     1. User sends a request via HTTPS.
     2. AWS Load Balancer receives the request.
     3. The request is forwarded to the FountainAI service.
     4. The service processes the request.
     5. The service sends a response back through the Load Balancer.
     6. The user receives the response.

     Include appropriate arrows to indicate the flow and use descriptive labels.
     ```
   - **GPT Response:** Provides the DOT code.

2. **Render the Diagram:**

   - Use [GraphvizOnline](https://dreampuf.github.io/GraphvizOnline) or a local Graphviz installation to render the diagram.

3. **Include the Diagram in the Workbook:**

   - Save the rendered image in the `images` directory.
   - Embed the image in the markdown file using `![Alt Text](images/diagram.png)`.

4. **Store Diagram Code:**

   - Save the DOT code in a `.dot` file within the `diagrams` directory.
   - Commit the code to version control for future reference and updates.

---

**Note:** Always ensure that diagrams are up-to-date and accurately reflect the content of the workbooks. Regularly review visualizations during documentation updates to maintain their relevance and correctness.