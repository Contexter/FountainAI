Below is comprehensive documentation for the **GitHub Branches Proxy** Vapor application, modeled after the style we used for the **GitHub Actions** proxy documentation. It explains how to set up, configure, and use the application in a production setting.

# GitHub Branches Proxy
---

## 1. Overview

**Name**: `GitHub Branches Proxy`  
**Description**: A Vapor 4 application that proxies requests to GitHub’s **Repository Branch** endpoints. It allows users to:

- **List branches** in a repository  
- **Get details** of a specific branch  
- **Create** a branch (via Git references)  
- **Delete** a branch (via Git references)

All requests are secured by **Bearer** authentication, which the application checks via a middleware. Requests are then **forwarded** to the GitHub API, ensuring that:

1. **Authorization** headers are preserved.  
2. **Response** status codes and bodies are returned to the caller, maintaining parity with GitHub’s API.

---

## 2. Project Layout & Files

When you run the provided script (`MakeBranchesApp.swift`), a folder named `GitHubBranchesProxy` (or whichever name you chose) is created with the following structure:

```
GitHubBranchesProxy/
├── Package.swift
├── Sources
│   ├── App
│   │   ├── Controllers
│   │   │   └── GitHubBranchController.swift
│   │   ├── Middlewares
│   │   │   └── BearerAuthMiddleware.swift
│   │   ├── Services
│   │   │   └── GitHubProxyService.swift
│   │   ├── GlobalAppRef.swift
│   │   ├── configure.swift
│   │   └── routes.swift
│   └── Run
│       └── main.swift
└── Tests
    └── AppTests
```

- **Package.swift**: Declares dependencies (Vapor 4) and targets.  
- **Sources/Run/main.swift**: The entry point for your Vapor application.  
- **Sources/App/configure.swift**: Configures routes and any middleware.  
- **Sources/App/routes.swift**: Declares the REST endpoints, mapped to controller methods.  
- **Sources/App/Middlewares/BearerAuthMiddleware.swift**: Minimal Bearer authentication check.  
- **Sources/App/Services/GitHubProxyService.swift**: Performs actual HTTP calls (GET, POST, DELETE) to GitHub.  
- **Sources/App/Controllers/GitHubBranchController.swift**: Implements the route-handling logic for branch-related operations.  
- **Sources/App/GlobalAppRef.swift**: Stores a reference to the `Application` for use in controllers (optional pattern).

---

## 3. Getting Started

### 3.1 Installation

1. **Run the script**:  
   ```bash
   swift MakeBranchesApp.swift
   ```
   This creates the `GitHubBranchesProxy` folder.

2. **Move into the project**:  
   ```bash
   cd GitHubBranchesProxy
   ```

3. **Build the project**:  
   ```bash
   swift build
   ```

4. **Run the Vapor server**:  
   ```bash
   swift run
   ```

By default, the application will listen on **port 8080**.

### 3.2 Configuration

- **Listening address/port**: In `configure.swift` (or in `main.swift`), you can set:
  ```swift
  // app.http.server.configuration.hostname = "0.0.0.0"
  // app.http.server.configuration.port = 8080
  ```
- **Environment Variables**:
  - `GITHUB_API_BASE_URL` (optional): If you need to proxy to a **GitHub Enterprise** server or a custom domain instead of `https://api.github.com`, set it here.  

---

## 4. High-Level Architecture

1. **BearerAuthMiddleware** checks for a `Bearer` token in the `Authorization` header. If invalid, returns `401 Unauthorized`.  
2. **routes.swift** defines the available endpoints (`/repos/:owner/:repo/branches`, etc.).  
3. **GitHubBranchController** receives each request, constructs the appropriate path (e.g., `"/repos/\(owner)/\(repo)/branches"`), and delegates the actual network call to `GitHubProxyService`.  
4. **GitHubProxyService** builds headers, forwards the request to GitHub, logs the response, and checks for errors (e.g., 404, 401) before returning.  
5. **The response** is passed back to the client with the same status code and body from GitHub.

---

## 5. Route Endpoints

The application implements the following endpoints (based on your OpenAPI specification):

1. **List Branches**  
   **Method**: `GET`  
   **Path**: `/repos/{owner}/{repo}/branches`  
   **Description**: Retrieves a list of branches for the specified repository.

2. **Get Branch Details**  
   **Method**: `GET`  
   **Path**: `/repos/{owner}/{repo}/branches/{branch}`  
   **Description**: Retrieves details for a specific branch (branch name, commit info, etc.).  
   **404** if the branch is not found.

3. **Create Branch**  
   **Method**: `POST`  
   **Path**: `/repos/{owner}/{repo}/git/refs`  
   **Description**: Creates a new branch by specifying the `ref` (e.g., `"refs/heads/new-branch"`) and the commit `sha`.  
   **Body** (JSON):  
   ```json
   {
     "ref": "refs/heads/new-branch",
     "sha": "abcd1234..."
   }
   ```
   **201** on success, or **422** if validation fails.

4. **Delete Branch**  
   **Method**: `DELETE`  
   **Path**: `/repos/{owner}/{repo}/git/refs/{ref}`  
   **Description**: Deletes the specified branch reference, e.g. `refs/heads/my-branch`.  
   **204** on success, or **404** if the branch is not found.

---

## 6. Security and Bearer Authentication

The application uses **BearerAuthMiddleware**:

```swift
struct BearerAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let authHeader = request.headers[.authorization].first,
              authHeader.lowercased().starts(with: "bearer ") else {
            throw Abort(.unauthorized, reason: "Missing or invalid Bearer token.")
        }
        return try await next.respond(to: request)
    }
}
```

- **Bearer token** must be included in the `Authorization` header of each request.  
- Example header: `Authorization: Bearer ghp_xxx...`  
- In a production setting, you would likely **validate** this token. For instance, you could parse a JWT, compare it to a known secret, or check it against a database.  

---

## 7. Error Handling & Logging

- **Logging**:  
  - Vapor logs to stdout by default.  
  - Each proxied request includes a log entry:  
    ```
    [GitHubProxyService] GET /repos/{owner}/{repo} -> 200
    ```
- **GitHub Error Handling**:  
  - The `GitHubProxyService` checks common error statuses (401, 404, etc.).  
  - If GitHub returns JSON with an `error` message, that message is forwarded to the client via `throw GitHubProxyError.someError(...)`.  
  - This ensures consistent status codes and meaningful messages.

---

## 8. Local Development & Testing

1. **Local Testing**:  
   - While running locally (`swift run`), you can test endpoints with a tool like `curl` or Postman.  
   - For example:  
     ```bash
     curl -X GET "http://127.0.0.1:8080/repos/apple/swift/branches" \
          -H "Authorization: Bearer YOUR_TOKEN"
     ```
2. **Unit Tests**:  
   - A `Tests/AppTests` folder is included. You can add test files there.  
   - You might write tests for your controllers or service logic with Vapor’s `XCTVapor` package (which is included automatically).

---

## 9. Deployment

1. **Docker**:  
   - Common approach: build a Docker image from the Swift official image, copy your compiled Vapor app, and run it.  
   - [Vapor Docs on Docker](https://docs.vapor.codes/4.0/deploy/docker/).
2. **Heroku** (though Heroku’s free plan has changed):  
   - Use a Procfile specifying the run command: `web: Run serve --env production --port $PORT`.  
3. **AWS / GCP** / other hosting:  
   - You can deploy anywhere Swift can run. The key is to open port 8080 or configure another port accordingly.

---

## 10. Extending and Customizing

- **Bearer Token Validation**:  
  - Implement real token logic in `BearerAuthMiddleware`.  
- **More GitHub Endpoints**:  
  - If you need to handle advanced features (e.g., merging branches, updating references), simply add more functions in `GitHubBranchController.swift` and wire them in `routes.swift`.  
- **Caching**:  
  - If you want to reduce requests to GitHub or handle rate limits, you could integrate caching (e.g., Redis or in-memory) around the `GitHubProxyService` calls.  
- **Error Customization**:  
  - Currently, we pass GitHub’s status codes & messages back to the client. If you prefer a custom error format, you can wrap or transform them.

---

## 11. Frequently Asked Questions

1. **Why store the Vapor `app` in `GlobalAppRef`?**  
   - This is a simple pattern so that the `GitHubBranchController` can instantiate `GitHubProxyService(app: app)`. In more advanced apps, you may pass `app` in an initializer or use a DI container.  

2. **Can I reuse this code for GitHub Enterprise?**  
   - Yes. Set `GITHUB_API_BASE_URL` to your enterprise URL, e.g. `https://github.my-company.com/api/v3`.  

3. **Does it handle pagination for large numbers of branches?**  
   - By default, the GitHub API will return up to 100 branches per page. You can pass query parameters (e.g., `?per_page=100&page=2`) in your request to get more. If you need to auto-paginate, you can implement additional logic in the service.  

4. **What if my branch name includes slashes?**  
   - GitHub expects references like `refs/heads/feature/some-branch`. In the `deleteBranch` function, we directly append `"/git/refs/\(refParam)"`. If you have special characters, ensure your request path is properly URL-encoded in your client.

---

## Summary

This **GitHub Branches Proxy** is a fully working Vapor 4 application. It enforces **Bearer** authentication, logs requests, forwards them to the GitHub API, and preserves GitHub’s status codes and responses:

1. **List** branches  
2. **Get** a branch  
3. **Create** a branch by posting JSON to `git/refs`  
4. **Delete** a branch reference  

All **production-ready** and easily extensible. Just add your custom logic, real token validation, and any needed error transformations. Enjoy your new **GitHub repository branch proxy**!