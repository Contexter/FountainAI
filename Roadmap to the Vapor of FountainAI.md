# Roadmap to the Vapor of FountainAI

## Introduction

Welcome to "FountainAI's Vapor," the story guide of setting up and deploying FountainAI, an AI-driven model designed to analyze and process theatrical and screenplay scripts. Leveraging the power of Vapor, Docker, and modern CI/CD practices, this guide will take you through every step, from initial setup to deploying a Dockerized Vapor application managed by a CI/CD pipeline.

### FountainAI Network Graph

The FountainAI Network Graph provides a visual overview of the conceptual model of FountainAI, highlighting the core components and their interactions. This graph helps visualize the structural and thematic composition of storytelling, providing a foundational understanding of how FountainAI will process and analyze scripts.

---

![The Fountain Network Graph](https://coach.benedikt-eickhoff.de/koken/storage/cache/images/000/723/Bild-2,xlarge.1713545956.jpeg)

---

### OpenAPI Specification

The OpenAPI specification serves as the detailed blueprint for FountainAI, transitioning from the high-level conceptual model to a precise API definition. It outlines all the endpoints, request/response formats, and data models, ensuring that developers have a clear and consistent reference for implementing the AI. The OpenAPI specification for this project can be found [here](https://github.com/Contexter/fountainAI/blob/main/openAPI/FountainAI-Admin-openAPI.yaml).

---

By following this guide, you will:

1. **Set up the development environment**: Create a GitHub repository, configure environment variables, generate necessary tokens, and establish secure communication between your local machine and a Virtual Private Server (VPS).
2. **Implement a CI/CD pipeline**: Use GitHub Actions to automate the process of building, testing, and deploying the application, ensuring continuous integration and continuous deployment.
3. **Create and manage the Vapor application**: Develop the Vapor application based on the FountainAI OpenAPI specification, Dockerize the application, and integrate it into the CI/CD pipeline for seamless deployment.

By the end of this guide, you will have a fully functional, automated deployment process for FountainAI, leveraging the power of Docker, Vapor, and GitHub Actions.

---

## Table of Contents
1. [Episode 1: Initial Setup and Manual GitHub Secrets Creation](#episode-1-initial-setup-and-manual-github-secrets-creation)
2. [Episode 2: Creating and Managing the CI/CD Pipeline with GitHub Actions](#episode-2-creating-and-managing-the-cicd-pipeline-with-github-actions)
3. [Episode 3: Creating and Managing the Vapor App for FountainAI with CI/CD Pipeline](#episode-3-creating-and-managing-the-vapor-app-for-fountainai-with-cicd-pipeline)

---

## Episode 1: Initial Setup and Manual GitHub Secrets Creation

### Table of Contents
1. [Introduction](#introduction-1)
2. [Prerequisites](#prerequisites)
3. [Step-by-Step Setup Guide](#step-by-step-setup-guide)
    1. [Create GitHub Repository and Configuration File](#create-github-repository-and-configuration-file)
    2. [Generate a GitHub Personal Access Token](#generate-a-github-personal-access-token)
    3. [Create SSH Keys for VPS Access](#create-ssh-keys-for-vps-access)
    4. [Add SSH Keys to Your VPS and GitHub](#add-ssh-keys-to-your-vps-and-github)
    5. [Generate a Runner Registration Token](#generate-a-runner-registration-token)
    6. [Manually Add Secrets to GitHub](#manually-add-secrets-to-github)
4. [Conclusion](#conclusion)

### Introduction

In this episode, we will set up the foundational components required for developing and deploying FountainAI. This includes creating a GitHub repository, configuring environment variables, and establishing secure communication with a VPS.

### Prerequisites

Ensure you have:
- A GitHub Account
- VPS (Virtual Private Server)
- Docker installed locally

### Step-by-Step Setup Guide

#### Create GitHub Repository and Configuration File
- Detailed instructions on creating a GitHub repository and setting up `config.env`.

#### Generate a GitHub Personal Access Token
- Step-by-step guide to generate a personal access token on GitHub.

#### Create SSH Keys for VPS Access
- Instructions on generating SSH keys for secure VPS access.

#### Add SSH Keys to Your VPS and GitHub
- How to add public keys to VPS and private keys to GitHub secrets.

#### Generate a Runner Registration Token
- Steps to generate a runner token and setting up a self-hosted runner on GitHub Actions.

#### Manually Add Secrets to GitHub
- How to securely add configuration variables as GitHub secrets.

### Conclusion

Summarize the steps covered and provide a brief outlook on the next episode.

---

## Episode 2: Creating and Managing the CI/CD Pipeline with GitHub Actions

### Table of Contents
1. [Introduction](#introduction-2)
2. [Project Structure Setup](#project-structure-setup)
3. [Creating Custom Actions](#creating-custom-actions)
    1. [Manage Secrets Action](#manage-secrets-action)
    2. [Setup Environment Action](#setup-environment-action)
    3. [Build Project Action](#build-project-action)
    4. [Test Project Action](#test-project-action)
    5. [Deploy Project Action](#deploy-project-action)
4. [Defining Workflows](#defining-workflows)
    1. [Development Workflow](#development-workflow)
    2. [Testing Workflow](#testing-workflow)
    3. [Staging Workflow](#staging-workflow)
    4. [Production Workflow](#production-workflow)
5. [Conclusion](#conclusion-1)

### Introduction

In this episode, we will create and manage a CI/CD pipeline using GitHub Actions. This pipeline will automate the process of building, testing, and deploying the FountainAI application, ensuring continuous integration and continuous deployment.

### Project Structure Setup

**Setting Up the Environment**
- Provide the shell script to set up the project structure.

### Creating Custom Actions

#### Manage Secrets Action
- Instructions to create the `Manage Secrets` action with `action.yml` and `index.js`.

#### Setup Environment Action
- Guide to create the `Setup Environment` action.

#### Build Project Action
- Steps to create the `Build Project` action.

#### Test Project Action
- Instructions to create the `Test Project` action.

#### Deploy Project Action
- Guide to create the `Deploy Project` action.

### Defining Workflows

#### Development Workflow
- Steps to define the development workflow.

#### Testing Workflow
- Instructions for the testing workflow.

#### Staging Workflow
- Steps to create the staging workflow.

#### Production Workflow
- Instructions to define the production workflow.

### Conclusion

Summarize the steps covered and the benefits of the CI/CD pipeline setup.

---

## Episode 3: Creating and Managing the Vapor App for FountainAI with CI/CD Pipeline

### Table of Contents
1. [Introduction](#introduction-3)
2. [FountainAI Project Overview](#fountainai-project-overview)
    1. [FountainAI Network Graph](#fountainai-network-graph)
    2. [OpenAPI Specification](#openapi-specification)
3. [Setting Up the Vapor Application](#setting-up-the-vapor-application)
    1. [Create Vapor Application Script](#create-vapor-application-script)
    2. [Dockerizing the Vapor Application](#dockerizing-the-vapor-application)
4. [Integrating with CI/CD Pipeline](#integrating-with-cicd-pipeline)
    1. [Building and Pushing Docker Image](#building-and-pushing-docker-image)
    2. [Deployment and Monitoring](#deployment-and-monitoring)
    3. [Updating CI/CD Workflows](#updating-cicd-workflows)
5. [Conclusion](#conclusion-2)

### Introduction

In this episode, we will focus on creating the Vapor application for FountainAI, Dockerizing it, and integrating it into the CI/CD pipeline established in Episode 2.

### FountainAI Project Overview

#### FountainAI Network Graph
- Explain the conceptual model of FountainAI, detailing the various components and their interactions.

#### OpenAPI Specification
- Provide an overview of the OpenAPI specification, which serves as the blueprint for the Vapor application. Include a link to the OpenAPI spec file and describe its key components.

### Setting Up the Vapor Application

#### Create Vapor Application Script
- Discuss creating a script to initialize the Vapor application using the Vapor toolbox.

#### Dockerizing the Vapor Application
- Overview of creating a Dockerfile for the Vapor application.

### Integrating with CI/CD Pipeline

#### Building and Pushing Docker Image
- Outline the steps to build and push the Docker image to the GitHub Container Registry using CI/CD workflows.

#### Deployment and Monitoring
- Overview of how to deploy the Dockerized Vapor application using GitHub Actions and monitor the deployment process.

#### Updating CI/CD Workflows
- Mention updating the workflows to include building, testing, and deploying the Dockerized Vapor application.

### Conclusion

Summarize the steps covered in creating and managing a Dockerized Vapor application through a CI/CD pipeline. Emphasize the benefits of having an automated and structured deployment process.

