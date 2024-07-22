# The Ultimate Guide to GitHub Custom Actions and Branches

### Table of Contents
1. **Introduction to GitHub Actions**
2. **Creating Custom GitHub Actions**
    - Overview
    - Types of GitHub Actions
    - Creating a Docker Container Action
    - Creating a JavaScript Action
3. **Using GitHub Actions**
    - Writing Workflows
    - Using Actions in Workflows
4. **GitHub Branches and Triggers**
    - Overview of Branches
    - Branch Naming Conventions
    - Branch Protection Rules
    - Triggers for GitHub Actions
5. **Integrating GitHub Actions with Branches**
    - Workflow Triggering on Specific Branches
    - Examples of Branch-Based Workflow Triggers
6. **Best Practices for GitHub Actions and Branches**

### 1. Introduction to GitHub Actions

> For detailed information, visit the [official GitHub documentation on creating actions](https://docs.github.com/en/actions/creating-actions).

GitHub Actions is a powerful automation tool that allows developers to automate, customize, and execute software development workflows directly in their GitHub repositories. These workflows are defined using YAML syntax and can be triggered by events like code pushes, pull requests, or on a schedule.

### 2. Creating Custom GitHub Actions

#### Overview

Custom GitHub Actions enable you to create reusable components that perform specific tasks in your workflows. There are two primary types of custom actions:

- **Docker Container Actions**: Run in a Docker container.
- **JavaScript Actions**: Run directly in the GitHub Actions runtime.

#### Types of GitHub Actions

1. **Docker Container Actions**
2. **JavaScript Actions**

#### Creating a Docker Container Action

1. **Set Up Your Repository**:
    - Create a new directory for your action.
    - Create a `Dockerfile` in this directory.
    - Create an `action.yml` file to define your action.

2. **Write the Dockerfile**:
    ```dockerfile
    FROM alpine:3.11
    COPY entrypoint.sh /entrypoint.sh
    RUN chmod +x /entrypoint.sh
    ENTRYPOINT ["/entrypoint.sh"]
    ```

3. **Write the Entrypoint Script**:
    ```sh
    #!/bin/sh
    echo "Hello, world! My input was $1"
    ```

4. **Define the Action Metadata (action.yml)**:
    ```yaml
    name: "Hello World Docker Action"
    description: "A simple Docker action example"
    inputs:
      myInput:
        description: "Input to the action"
        required: true
    runs:
      using: "docker"
      image: "Dockerfile"
      args:
        - ${{ inputs.myInput }}
    ```

#### Creating a JavaScript Action

1. **Set Up Your Repository**:
    - Create a new directory for your action.
    - Create an `index.js` file in this directory.
    - Create an `action.yml` file to define your action.

2. **Write the Action Code (index.js)**:
    ```javascript
    const core = require('@actions/core');

    async function run() {
      try {
        const myInput = core.getInput('myInput');
        console.log(`Hello, world! My input was ${myInput}`);
      } catch (error) {
        core.setFailed(error.message);
      }
    }

    run();
    ```

3. **Define the Action Metadata (action.yml)**:
    ```yaml
    name: "Hello World JavaScript Action"
    description: "A simple JavaScript action example"
    inputs:
      myInput:
        description: "Input to the action"
        required: true
    runs:
      using: "node12"
      main: "index.js"
    ```

#### Example Trees for Custom GitHub Actions

**Before Creating Custom Actions:**

Here's an example directory structure of a typical GitHub repository before adding any custom GitHub Actions:

```
my-repo/
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── src/
│   ├── main.py
│   └── utils.py
│
├── README.md
└── requirements.txt
```

**After Creating Custom Actions:**

Once you create custom GitHub Actions, the directory structure will look something like this:

```
my-repo/
│
├── .github/
│   ├── workflows/
│   │   └── ci.yml
│   └── actions/
│       └── hello-world-docker-action/
│           ├── Dockerfile
│           ├── entrypoint.sh
│           └── action.yml
│       └── hello-world-js-action/
│           ├── index.js
│           └── action.yml
│
├── src/
│   ├── main.py
│   └── utils.py
│
├── README.md
└── requirements.txt
```

### 3. Using GitHub Actions

#### Writing Workflows

Workflows are defined in YAML files stored in the `.github/workflows` directory of your repository.

```yaml
name: CI

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
      - name: Run a one-line script
        run: echo Hello, world!
      - name: Use a custom action
        uses: ./hello-world-docker-action
        with:
          myInput: 'Some input'
```

#### Using Actions in Workflows

You can use actions from the GitHub Marketplace or your custom actions in your workflows.

### 4. GitHub Branches and Triggers

#### Overview of Branches

Branches in GitHub allow you to work on different versions of a repository simultaneously. The `main` branch is often the primary branch.

#### Branch Naming Conventions

Common conventions include:
- `feature/branch-name`
- `bugfix/branch-name`
- `hotfix/branch-name`

#### Branch Protection Rules

Branch protection rules help ensure the integrity of your code by enforcing conditions like requiring pull request reviews or status checks before merging.

#### Triggers for GitHub Actions

Workflows can be triggered by various events:
- `push`
- `pull_request`
- `schedule`
- `workflow_dispatch`

### 5. Integrating GitHub Actions with Branches

#### Workflow Triggering on Specific Branches

You can configure workflows to run only on specific branches or tags.

```yaml
on:
  push:
    branches:
      - main
      - 'release/*'
  pull_request:
    branches:
      - develop
```

#### Examples of Branch-Based Workflow Triggers

1. **Trigger on Push to Main**:
    ```yaml
    on:
      push:
        branches:
          - main
    ```

2. **Trigger on Pull Request to Develop**:
    ```yaml
    on:
      pull_request:
        branches:
          - develop
    ```

3. **Trigger on Any Branch Matching a Pattern**:
    ```yaml
    on:
      push:
        branches:
          - 'feature/*'
    ```

### Relevant Git Commands in the Branching Sections

#### Creating and Switching Branches

1. **Create a new branch**:
    ```sh
    git checkout -b feature/new-feature
    ```

2. **Switch to an existing branch**:
    ```sh
    git checkout develop
    ```

3. **List all branches**:
    ```sh
    git branch
    ```

4. **Delete a branch**:
    ```sh
    git branch -d feature/old-feature
    ```

#### Pushing Branches to Remote

1. **Push a new branch to the remote repository**:
    ```sh
    git push origin feature/new-feature
    ```

2. **Push changes to an existing branch**:
    ```sh
    git push origin develop
    ```

#### Merging Branches

1. **Merge a branch into the current branch**:
    ```sh
    git merge feature/new-feature
    ```

2. **Resolve merge conflicts**:
    - Open the conflicted files and resolve the conflicts.
    - Stage the resolved files:
      ```sh
      git add <resolved-file>
      ```
    - Commit the merge:
      ```sh
      git commit
      ```

### 6. Best Practices for GitHub Actions and Branches

- **Modular Actions**: Create modular and reusable actions.
- **Versioning**: Version your actions to maintain backward compatibility.
- **Secrets Management**: Use GitHub Secrets for sensitive data.
- **Branch Naming**: Use consistent and descriptive branch naming conventions.
- **Branch Protection**: Implement branch protection rules for critical branches.
- **Workflow Optimization**: Optimize workflows for performance and cost.

### Conclusion

By leveraging GitHub Actions and managing branches effectively, you can automate and streamline your development workflow, ensuring higher productivity and code quality. This guide provides a comprehensive overview to get you started with creating custom actions and using them efficiently with GitHub branches.