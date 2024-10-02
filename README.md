# FountainAI

Welcome to **FountainAI**, a comprehensive project dedicated to building a robust and scalable microservices architecture using FastAPI, Docker, and AWS Lightsail. This repository serves as the central hub for all components, documentation, and guides necessary to develop, deploy, and maintain the FountainAI system.

## 📚 Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Guidance: Comprehensive Implementation Guide](#guidance-comprehensive-implementation-guide)
    - [Part A: Introduction and Architecture Overview](#part-a-introduction-and-architecture-overview)
    - [Part B: GPT Code Generation Sessions](#part-b-gpt-code-generation-sessions)
    - [Part C: Deployment, CI/CD Enhancements, and Custom Logging](#part-c-deployment-cicd-enhancements-and-custom-logging)
4. [Use Cases](#use-cases)
5. [OpenAPI Specifications](#openapi-specifications)
6. [Project Reports](#project-reports)
7. [Getting Started](#getting-started)
8. [Contributing](#contributing)
9. [License](#license)
10. [Contact](#contact)

---

## 📖 Project Overview

**FountainAI** is designed to manage various aspects of storytelling, character development, script management, session contexts, and sequence assignments through a suite of interconnected APIs. Leveraging a microservices architecture ensures modularity, scalability, and ease of maintenance. The key components include:

- **Central Sequence Service API**
- **Character Management API**
- **Core Script Management API**
- **Session Context Management API**
- **Story Factory API**

Each API is responsible for specific functionalities, interacting seamlessly through defined interfaces to provide a cohesive and efficient system.

---

## 📂 Repository Structure

The repository is organized to facilitate easy navigation and management of different components, documentation, and scripts. Below is an overview of the repository structure:

- **Guidance/**
  - `Part A_ Introduction and Architecture Overview.md`
  - `Part B_ GPT Code Generation Sessions.md`
  - `Part C_ Deployment, CI_CD Enhancements, and Custom Logging.md`
  
- **Project Report by Date/**
  - `FountainAI Project Report.md`
  
- **Use Cases/**
  - `The Role of Context in FountainAI.md`
  
- **openAPI/**
  - **API-Docs-GPT-4o-Paraphrase/**
    - `API Documentation - Central Sequence Service API Documentation.md`
    - `API Documentation - Character Management API.md`
    - `API Documentation - Core Script Management.md`
    - `API Documentation - Session and Context Management API.md`
    - `API Documentation - Story Factory API.md`
  - `central-sequence-service.yaml`
  - `character-management.yaml`
  - `core-script-management.yaml`
  - `session-and-context.yaml`
  - `story-factory.yaml`
  
- `README.md`

---

## 📚 Guidance: Comprehensive Implementation Guide

The **Guidance** directory is your roadmap to successfully implementing and deploying the FountainAI system. It is divided into three integral parts:

### 📘 Part A: Introduction and Architecture Overview

Provides an in-depth overview of the FountainAI project, detailing the system architecture, project structure, and initial setup requirements.

- **[Read Part A](Guidance/Part%20A_%20Introduction%20and%20Architecture%20Overview.md)**

### 📗 Part B: GPT Code Generation Sessions

Focuses on leveraging GPT for automating the creation of FastAPI applications based on OpenAPI specifications. It covers code generation, repository initialization, and maintaining code quality.

- **[Read Part B](Guidance/Part%20B_%20GPT%20Code%20Generation%20Sessions.md)**

### 📕 Part C: Deployment, CI/CD Enhancements, and Custom Logging

Delves into deploying the microservices to AWS Lightsail, configuring Docker Compose across multiple instances, enhancing CI/CD pipelines with GitHub Actions, and implementing a centralized logging solution using Kong API Gateway.

- **[Read Part C](Guidance/Part%20C_%20Deployment,%20CI_CD%20Enhancements,%20and%20Custom%20Logging.md)**

---

## 🔍 Use Cases

Explore real-world scenarios and applications of FountainAI to understand its impact and functionality.

- **[The Role of Context in FountainAI](Use%20Cases/The%20Role%20of%20Context%20in%20FountainAI.md)**

---

## 📄 OpenAPI Specifications

Detailed OpenAPI specifications for each API component, facilitating standardized and consistent API development.

- **Central Sequence Service API:** [central-sequence-service.yaml](openAPI/central-sequence-service.yaml)
- **Character Management API:** [character-management.yaml](openAPI/character-management.yaml)
- **Core Script Management API:** [core-script-management.yaml](openAPI/core-script-management.yaml)
- **Session and Context Management API:** [session-and-context.yaml](openAPI/session-and-context.yaml)
- **Story Factory API:** [story-factory.yaml](openAPI/story-factory.yaml)

Additionally, comprehensive documentation and guides can be found within the **API-Docs-GPT-4o-Paraphrase** directory.

---

## 📝 Project Reports

Keep track of project progress, milestones, and evaluations through detailed reports.

- **[FountainAI Project Report](Project%20Report%20by%20Date/FountainAI%20Project%20Report.md)**

---

## 🚀 Getting Started

To get started with FountainAI, follow these steps:

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/fountainAI.git
   cd fountainAI
   ```

2. **Navigate to the Guidance Directory:**

   Begin by reading through **Part A** to understand the project overview and architecture.

   ```bash
   cd Guidance
   ```

3. **Follow the Implementation Guide:**

   Progress through Parts A, B, and C sequentially to develop, deploy, and maintain the FountainAI system.

4. **Explore Use Cases and Reports:**

   Gain insights into practical applications and track project progress through the **Use Cases** and **Project Reports** directories.

---

## 🤝 Contributing

Contributions are welcome! To contribute to FountainAI:

1. **Fork the Repository**

2. **Create a New Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Commit Your Changes**

4. **Push to the Branch**

   ```bash
   git push origin feature/your-feature-name
   ```

5. **Open a Pull Request**

Please ensure your code adheres to the project's coding standards and passes all CI checks.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 📞 Contact

For any questions or support, please reach out to [mail@benedikt-eickhoff.de](mailto:mail@benedikt-eickhoff.de).

---

🔗 **Explore More:**

- **[Guidance: Comprehensive FountainAI Implementation Guide](Guidance/Part%20A_%20Introduction%20and%20Architecture%20Overview.md)**
- **[OpenAPI Documentation](openAPI/API-Docs-GPT-4o-Paraphrase/)**

---

*Happy Coding! 🚀*