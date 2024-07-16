# Road to FountainAI

## Introduction

Welcome to "FountainAI's Vapor," the road story of setting up and deploying FountainAI, an AI-driven model designed to analyze and process theatrical and screenplay scripts. Leveraging the power of Vapor, Docker, and modern CI/CD practices, this guide will take you through every step, from initial setup to deploying a Dockerized Vapor application managed by a CI/CD pipeline.

### Table of Contents

1. [Episode 1: Initial Setup and Manual GitHub Secrets Creation](episodes/episode1.md)
2. [Episode 2: Creating and Managing the CI/CD Pipeline with GitHub Actions](episodes/episode2.md)
3. [Episode 3: Creating and Managing the Vapor App for FountainAI with CI/CD Pipeline](episodes/episode3.md)
4. [Episode 4: Implementing the Script Entity with TDD](episodes/episode4.md)
5. [Episode 5: Placeholder Title](episodes/episode5.md)
6. [Episode 6: Placeholder Title](episodes/episode6.md)
7. [Episode 7: Placeholder Title](episodes/episode7.md)
8. [Episode 8: Placeholder Title](episodes/episode8.md)
9. [Episode 9: Placeholder Title](episodes/episode9.md)
10. [Episode 10: Placeholder Title](episodes/episode10.md)

---

### FountainAI Network Graph

The FountainAI Network Graph provides a visual overview of the conceptual model of FountainAI, highlighting the core components and their interactions. This graph helps visualize the structural and thematic composition of storytelling, providing a foundational understanding of how FountainAI will process and analyze scripts.

![The Fountain Network Graph](https://coach.benedikt-eickhoff.de/koken/storage/cache/images/000/723/Bild-2,xlarge.1713545956.jpeg)

### OpenAPI Specification

The OpenAPI specification serves as the detailed blueprint for FountainAI, transitioning from the high-level conceptual model to a precise API definition. It outlines all the endpoints, request/response formats, and data models, ensuring that developers have a clear and consistent reference for implementing the AI. The OpenAPI specification for this project can be found [here](https://github.com/Contexter/fountainAI/blob/main/openAPI/FountainAI-Admin-openAPI.yaml).

---

By following this guide, you will:

1. **Set up the development environment**: Create a GitHub repository, configure environment variables, generate necessary tokens, and establish secure communication between your local machine and a Virtual Private Server (VPS).
2. **Implement a CI/CD pipeline**: Use GitHub Actions to automate the process of building, testing, and deploying the application, ensuring continuous integration and continuous deployment.
3. **Create and manage the Vapor application**: Develop the Vapor application based on the FountainAI OpenAPI specification, Dockerize the application, and integrate it into the CI/CD pipeline for seamless deployment.

By the end of this guide, you will have a fully functional, automated deployment process for FountainAI, leveraging the power of Docker, Vapor, and GitHub Actions.

---

## Episode Overviews

### [Episode 1: Initial Setup and Manual GitHub Secrets Creation](episodes/episode1.md)

In this episode, we set up the foundational components required for developing and deploying FountainAI. This includes creating a GitHub repository, configuring environment variables, and establishing secure communication with a VPS.

### [Episode 2: Creating and Managing the CI/CD Pipeline with GitHub Actions](episodes/episode2.md)

In this episode, we create and manage a CI/CD pipeline using GitHub Actions. This pipeline automates the process of building, testing, and deploying the FountainAI application, ensuring continuous integration and continuous deployment.

### [Episode 3: Creating and Managing the Vapor App for FountainAI with CI/CD Pipeline](episodes/episode3.md)

In this episode, we create a basic "Hello, World!" Vapor application, Dockerize it, and integrate it into the CI/CD pipeline established in Episode 2. We introduce Docker Compose to manage multiple containers and ensure a smooth deployment process.

### [Episode 4: Implementing the Script Entity with TDD](episodes/episode4.md)

In this episode, we implement the Script entity using Test-Driven Development (TDD). We begin by writing tests based on the OpenAPI specification, run the tests to see them fail, then implement the functionality to make the tests pass. We develop core API endpoints, connect to the PostgreSQL database, and implement basic CRUD operations.
