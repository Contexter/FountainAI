# GitHub REST API Proxy - Alignment Checks

## Overview

This document provides a summary and verification of the OpenAPI specifications created so far to proxy GitHub's REST API. Each section reviews the endpoints implemented, their alignment with GitHub's provided REST API, and references the official GitHub documentation.

---

## 1. Issues Management

**Purpose**: Manage issues, including creation, updates, retrieval, and deletion.

**Implemented Endpoints**:

- `POST /repos/{owner}/{repo}/issues` - Create an issue.
- `GET /repos/{owner}/{repo}/issues` - List issues.
- `GET /repos/{owner}/{repo}/issues/{issue_number}` - Get issue details.
- `PATCH /repos/{owner}/{repo}/issues/{issue_number}` - Update an issue.
- `DELETE /repos/{owner}/{repo}/issues/{issue_number}` - Delete an issue.

**Alignment Check**: Matches GitHub's Issues REST API as documented [here](https://docs.github.com/en/rest/issues/issues).

---

## 2. Labels Management

**Purpose**: Handle repository labels (create, list, and delete labels).

**Implemented Endpoints**:

- `POST /repos/{owner}/{repo}/labels` - Create a label.
- `GET /repos/{owner}/{repo}/labels` - List labels.
- `DELETE /repos/{owner}/{repo}/labels/{name}` - Delete a label.

**Alignment Check**: Matches GitHub's Labels REST API as documented [here](https://docs.github.com/en/rest/issues/labels).

---

## 3. Milestones Management

**Purpose**: Manage repository milestones (create, update, delete, and list milestones).

**Implemented Endpoints**:

- `POST /repos/{owner}/{repo}/milestones` - Create a milestone.
- `GET /repos/{owner}/{repo}/milestones` - List milestones.
- `PATCH /repos/{owner}/{repo}/milestones/{milestone_number}` - Update a milestone.
- `DELETE /repos/{owner}/{repo}/milestones/{milestone_number}` - Delete a milestone.

**Alignment Check**: Matches GitHub's Milestones REST API as documented [here](https://docs.github.com/en/rest/issues/milestones).

---

## 4. Repository Contents

**Purpose**: Manage file contents in a repository (get, create, update, delete files).

**Implemented Endpoints**:

- `GET /repos/{owner}/{repo}/contents/{path}` - Get file or directory content.
- `PUT /repos/{owner}/{repo}/contents/{path}` - Create or update file content.
- `DELETE /repos/{owner}/{repo}/contents/{path}` - Delete a file.

**Alignment Check**: Matches GitHub's Contents REST API as documented [here](https://docs.github.com/en/rest/repos/contents).

---

## 5. Branch Management

**Purpose**: Retrieve details about repository branches.

**Implemented Endpoints**:

- `GET /repos/{owner}/{repo}/branches` - List branches.
- `GET /repos/{owner}/{repo}/branches/{branch}` - Get branch details.

**Alignment Check**: Matches GitHub's Branches REST API as documented [here](https://docs.github.com/en/rest/branches/branches).

---

## 6. Commits Management

**Purpose**: Manage and compare commits in a repository.

**Implemented Endpoints**:

- `GET /repos/{owner}/{repo}/commits` - List commits.
- `GET /repos/{owner}/{repo}/commits/{ref}` - Get commit details.
- `POST /repos/{owner}/{repo}/commits` - Create a commit.
- `GET /repos/{owner}/{repo}/compare/{base}...{head}` - Compare commits.

**Alignment Check**: Matches GitHub's Commits REST API as documented [here](https://docs.github.com/en/rest/commits/commits).

---

## 7. Actions Management

**Purpose**: Manage GitHub Actions workflows, runs, logs, and artifacts.

**Implemented Endpoints**:

- `GET /repos/{owner}/{repo}/actions/workflows` - List workflows.
- `GET /repos/{owner}/{repo}/actions/workflows/{workflow_id}` - Get workflow details.
- `GET /repos/{owner}/{repo}/actions/runs` - List workflow runs.
- `GET /repos/{owner}/{repo}/actions/runs/{run_id}` - Get workflow run details.
- `GET /repos/{owner}/{repo}/actions/runs/{run_id}/logs` - Download logs.

**Alignment Check**: Matches GitHub's Actions REST API as documented [here](https://docs.github.com/en/rest/actions).

---

## General Observations

1. **Authentication**: All endpoints implement **Bearer Token Authorization**, compatible with GitHub's **Personal Access Tokens (PATs)**.
2. **Consistency**: Path formatting (e.g., `/repos/{owner}/{repo}`) aligns with GitHub's conventions.
3. **Documentation Links**: Every entity's specification is linked directly to GitHub's official REST API documentation for verification.
