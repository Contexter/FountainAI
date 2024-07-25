# Road to FountainAI

## Introduction

Welcome to "FountainAI's Vapor," the story of setting up and deploying FountainAI, an AI-driven model designed to analyze and process theatrical and screenplay scripts. Leveraging the power of Vapor, Docker, and modern CI/CD practices, this guide will take you through every step, from initial setup to deploying a Dockerized Vapor application managed by a CI/CD pipeline.

### FountainAI Network Graph

The FountainAI Network Graph provides a visual overview of the conceptual model of FountainAI, highlighting the core components and their interactions. This graph helps visualize the structural and thematic composition of storytelling, providing a foundational understanding of how FountainAI will process and analyze scripts.

![The Fountain Network Graph](https://coach.benedikt-eickhoff.de/koken/storage/cache/images/000/723/Bild-2,xlarge.1713545956.jpeg)

### OpenAPI Specification

The OpenAPI specification serves as the detailed blueprint for FountainAI, transitioning from the high-level conceptual model to a precise API definition. It outlines all the endpoints, request/response formats, and data models, ensuring that developers have a clear and consistent reference for implementing the AI. The OpenAPI specification for this project can be found [here](https://github.com/Contexter/fountainAI/blob/main/openAPI/FountainAI-Admin-openAPI.yaml).

---

## Episode Overviews

### [Episode 1: Initial Setup and Manual GitHub Secrets Creation](episodes/Episode1/episode1.md)

In this episode, we set up the foundational components required for developing and deploying your application. This includes creating a GitHub repository, configuring environment variables, generating necessary tokens, and establishing secure communication with a VPS. Key steps involve generating a GitHub personal access token, creating SSH keys, and manually adding secrets to GitHub.

### [Episode 2: Creating an OpenAPI-based Vapor Wrapper App around "gh"](episodes/Episode2/episode2.md)

In this episode, we create a Vapor app that acts as a wrapper around the GitHub CLI (`gh`). This app provides a web interface for interacting with GitHub repositories, including listing contents, fetching file contents, and managing GitHub secrets. We start by defining our API using the OpenAPI specification, implementing the Vapor app, dockerizing the app, and securing it using JWT-based bearer authentication. The episode also covers writing tests, setting up routes and controllers, handling GitHub CLI commands, and deploying the app with Docker and GitHub Actions.

This wrapper utility is crucial for implementing the FountainAI OpenAPI when being recomposed into smaller, modular APIs, allowing for more scalable and maintainable architecture.

### [Episode 3: Enhancing Security for Your OpenAPI-based Vapor Wrapper App around "gh"](episodes/Episode3/episode3.md)

In this episode, we enhance the security of our Vapor app by implementing best practices for managing sensitive information, robust authentication and authorization, error handling, and logging. Key topics include securing JWT secret management, protecting routes with JWT middleware, implementing static code analysis, setting up GitHub monitoring and alerts, and patching the project to meet security requirements. We also cover Docker and network security, as well as comprehensive error handling.

### [Episode 4: Placeholder Title](episodes/Episode4/episode4.md)

Content to be added.

### [Episode 5: Placeholder Title](episodes/Episode5/episode5.md)

Content to be added.

### [Episode 6: Placeholder Title](episodes/Episode6/episode6.md)

Content to be added.

### [Episode 7: Placeholder Title](episodes/Episode7/episode7.md)

Content to be added.

### [Episode 8: Placeholder Title](episodes/Episode8/episode8.md)

Content to be added.

### [Episode 9: Placeholder Title](episodes/Episode9/episode9.md)

Content to be added.

### [Episode 10: Placeholder Title](episodes/Episode10/episode10.md)

Content to be added.

---

Feel free to provide more episodes or additional details to be included in the README.