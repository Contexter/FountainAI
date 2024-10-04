

# FountainAI
> Managing Story

## Overview

**FountainAI** is a platform designed to manage and orchestrate storytelling components such as sequences, characters, actions, dialogues, and contexts. Built upon a robust and scalable **OpenAPI** framework, FountainAI supports the development and management of narrative elements across five core services.

---

## Prompt-First Development Approach

The **Prompt-First Development Approach** is used to break down the complexities of API creation into specific tasks, leveraging **ChatGPT-4 Canvas** for continuous, iterative refinement. This approach ensures that each development phase is structured and consistent with the overall narrative framework.

**Key Benefits**:
- **Granular Control**: Focused phases on API components.
- **OpenAPI-Driven**: Ensures strict adherence to OpenAPI standards.
- **Iterative Refinement**: Continuous improvements throughout development.

For more details, see the [Prompt-First Development Documentation](Workbooks/Documentation_%20Intent%20First%20-%20Productive%20Approach%20to%20Application%20Development%20in%20ChatGPT-4%20with%20Canvas.md).

---

## Comprehensive OpenAPI Service Group

FountainAI is built on five core services, each playing a crucial role in managing different aspects of storytelling:

1. **Central Sequence Service**:
   - [OpenAPI Critique Documentation](openAPI/v2/Documentation_%20Critique%20of%20v1%20-%20Central%20Sequence%20Service%20API%20OpenAPI%20Specification.md)
   
2. **Character Management Service**:
   - [OpenAPI Critique Documentation](openAPI/v2/Documentation_%20Critique%20of%20v1%20-%20Character%20Management%20API%20OpenAPI%20Specification.md)
   
3. **Core Script Management Service**:
   - [OpenAPI Critique Documentation](openAPI/v2/Documentation_%20Critique%20of%20v1%20-%20Core%20Script%20Management%20API%20OpenAPI%20Specification.md)
   
4. **Session and Context Management Service**:
   - [OpenAPI Critique Documentation](openAPI/v2/Documentation_%20Critique%20of%20v1%20-%20Session%20and%20Context%20Management%20API%20OpenAPI%20Specification.md)
   
5. **Story Factory Service**:
   - [OpenAPI Critique Documentation](openAPI/v2/Documentation_%20Critique%20of%20v1%20-%20Story%20Factory%20API%20OpenAPI%20Specification.md)

These services work together to manage sequences, characters, scripts, and other elements that form the building blocks of dynamic stories. Each service is aligned with OpenAPI standards to ensure consistency and ease of integration.

---

## Project Tree

Below is the current structure of the repository, reflecting the updated state of the project, including deprecation marks for older guidance and documentation that has been superseded.

```
.
├── Guidance
│   ├── Part A_ Introduction and Architecture Overview.md             # Deprecated
│   ├── Part B_ GPT Code Generation Sessions.md                       # Deprecated
│   └── Part C_ Deployment, CI_CD Enhancements, and Custom Logging.md # Deprecated
├── Project Report by Date
│   └── FountainAI Project Report.md                                  # Current project reports
├── README.md                                                         # This file
├── Use Cases
│   └── The Role of Context in FountainAI.md                          # Deprecated
├── Workbooks
│   ├── Documentation_ Intent First - Productive Approach to Application Development in ChatGPT-4 with Canvas.md # Active
│   ├── FountainAI Code Generation Workbook.md                        # Active
│   ├── FountainAI Visualization Standards.md                         # Active
│   └── README.md                                                     # Active
├── create_new_main_branch.sh                                         # Active: Shell script to manage branches
└── openAPI
    ├── v1
    │   ├── API-Docs-GPT-4o-Paraphrase
    │   │   ├── API Documentation - Central Sequence Service API Documentation.md # Deprecated (Paraphrased)
    │   │   ├── API Documentation - Character Management API.md                  # Deprecated (Paraphrased)
    │   │   ├── API Documentation - Core Script Management.md                    # Deprecated (Paraphrased)
    │   │   ├── API Documentation - Session and Context Management API.md        # Deprecated (Paraphrased)
    │   │   └── API Documentation - Story Factory API.md                         # Deprecated (Paraphrased)
    │   ├── central-sequence-service.yaml                                        # Active
    │   ├── character-management.yaml                                            # Active
    │   ├── core-script-management.yaml                                          # Active
    │   ├── o1-preview-FountainAI-system-description
    │   │   ├── Appendix
    │   │   │   └── Appendix_ FountainAI Implementation Path Documentation.md    # Active
    │   │   ├── Comprehensive FountainAI Implementation Guide (Extended).md      # Deprecated
    │   │   ├── Comprehensive FountainAI Implementation Guide.md                 # Deprecated
    │   │   ├── Requirements Engineering
    │   │   │   ├── Deprecated - FountainAI System Description.md                # Deprecated
    │   │   │   ├── FastAPI Implementation Path for the Official FountainAI System.md # Deprecated
    │   │   │   ├── Official FountainAI Implementation Requirements_ Ensuring Compliance with OpenAPI Specifications.md # Deprecated
    │   │   │   └── Official FountainAI System Description and Implementation Plan.md # Deprecated
    │   │   ├── Step-1-Implementation of the Central Sequence Service API
    │   │   │   ├── Continuing the Implementation of the Central Sequence Service API.md # Active
    │   │   │   └── Official FountainAI System Implementation_ Central Sequence Service API.md # Active
    │   │   ├── Step-2-Character Management API
    │   │   │   └── Official FountainAI Implementation Path_ Character Management API.md # Active
    │   │   ├── Step-3-Core Script Management API
    │   │   │   └── Official FountainAI Implementation Path_ Core Script Management API.md # Active
    │   │   ├── Step-4-Session and Context Management API
    │   │   │   └── Official FountainAI Implementation Path_ Session and Context Management API.md # Active
    │   │   └── Step-5-Story Factory API
    │   │       ├── Appendix_ From Mock to Real Implementation of the FountainAI Story Factory Service.md # Active
    │   │       └── Official FountainAI Implementation Path_ Story Factory API.md # Active
    │   ├── session-and-context.yaml                                            # Active
    │   └── story-factory.yaml                                                  # Active
    └── v2
        ├── Documentation_ Critique of v1 - Central Sequence Service API OpenAPI Specification.md
        ├── Documentation_ Critique of v1 - Character Management API OpenAPI Specification.md
        ├── Documentation_ Critique of v1 - Core Script Management API OpenAPI Specification.md
        ├── Documentation_ Critique of v1 - Session and Context Management API OpenAPI Specification.md
        └── Documentation_ Critique of v1 - Story Factory API OpenAPI Specification.md
```

---

## Deprecation Notices

- The **Guidance** documents (`Part A`, `Part B`, and `Part C`) are marked as **deprecated** in favor of the more structured workbook-driven approach. These files remain available for historical context but should not be referenced for current development.
- **Use Cases** have transitioned from standalone discussions (previously covered in "The Role of Context in FountainAI.md") to examples embedded within each service's workbook.

---

## Getting Started

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Contexter/FountainAI.git
   ```

2. **Review the Workbooks**: Start with the `FountainAI Code Generation Workbook` in the `Workbooks` directory.

3. **Set Up Development Environment**: Install required tools and dependencies as outlined in the workbooks.

4. **Generate Code**: Use the workbooks to interact with GPT-4 for generating service code based on the OpenAPI specs.

5. **Deploy Services**: Follow the deployment guidelines for containerizing and deploying services to AWS.

---

## Contributing

1. **Submit Issues**: Use GitHub to report issues or make feature requests.
2. **Pull Requests**: Ensure your pull requests are aligned with the project's goals and adhere to OpenAPI specifications.

