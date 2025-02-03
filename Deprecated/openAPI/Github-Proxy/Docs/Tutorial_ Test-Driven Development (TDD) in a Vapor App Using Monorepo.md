# Tutorial: Test-Driven Development (TDD) in a Vapor App Using Monorepo

This tutorial demonstrates how to implement a Vapor app using **Test-Driven Development (TDD)**. TDD helps ensure that your code is reliable, maintainable, and adheres to the specified requirements by focusing on writing tests before implementing functionality. We will leverage the `APIProtocol` provided by the [GithubProxyMonorepo](https://github.com/Contexter/GithubProxyMonorepo). Additionally, we integrate Vapor’s testing library, **XCTVapor**, while adhering to its directory structure and conventions.

---

## Prerequisites

1. **Monorepo Setup**:

   - Ensure the monorepo ([GithubProxyMonorepo](https://github.com/Contexter/GithubProxyMonorepo)) is set up with all `Server.swift` and `Types.swift` files for the APIs (e.g., `Actions`, `Branches`, etc.).
   - The monorepo should be added as a dependency in your Vapor app.

2. **Vapor App Setup**:

   - Create a new Vapor app if you don’t already have one:
     ```bash
     vapor new MyVaporApp -T default
     cd MyVaporApp
     ```

3. **Familiarity with TDD**:

   - Understand the basic process of writing tests before implementing functionality. TDD aligns well with Vapor’s modular design principles by encouraging incremental development. Writing tests first allows you to define the expected behavior of your app upfront, ensuring that new features integrate seamlessly with existing components. This approach reduces the risk of introducing bugs and makes your codebase more maintainable and predictable.

---

## Step 1: Add the Monorepo as a Dependency

Update your Vapor app's `Package.swift` to include the monorepo. This is essential to seamlessly integrate the prebuilt APIs (like `Actions` and `Branches`) into your app, enabling you to focus on implementing specific business logic while leveraging the existing functionality provided by the monorepo.

**File**: `Package.swift`

```swift
.package(url: "https://github.com/Contexter/GithubProxyMonorepo.git", from: "1.0.0")
```

Add the specific services to your target's dependencies:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Vapor", package: "vapor"),
        "Actions", // Example service from the monorepo
        "Branches"
    ]
)
```

Run:

```bash
swift package update
```

---

## Step 2: Define the API Handler

Create a handler that conforms to the `APIProtocol` defined in the monorepo. This is where you will implement the business logic for your API endpoints.

**File**: `Sources/App/Controllers/MyAPIHandler.swift`

```swift
import Vapor
import Actions

struct MyAPIHandler: APIProtocol {
    func listWorkflows(_ input: Operations.listWorkflows.Input) async throws -> Operations.listWorkflows.Output {
        if input.path.repo == "testrepo" {
            let workflows = [
                Workflow(id: 1, name: "CI", path: ".github/workflows/ci.yml", state: "active")
            ]
            return .ok(workflows)
        }
        return .notFound
    }

    // Implement other API methods as needed...
}
```

---

## Step 3: Integrate the Handler with Vapor

Update your `routes.swift` file to register the handler with Vapor’s routing system.

**File**: `Sources/App/routes.swift`

```swift
import Vapor
import Actions

func routes(_ app: Application) throws {
    let handler = MyAPIHandler()
    try app.registerHandlers(handler: handler)
}
```

---

## Step 4: Write Tests Using TDD

### 4.1 **Set Up the Test File**

By convention, Vapor places tests in the `Tests/AppTests/` directory. Create a new test file for the endpoint you are implementing.

**File**: `Tests/AppTests/ListWorkflowsTests.swift`

```swift
import XCTest
import XCTVapor
@testable import App

final class ListWorkflowsTests: XCTestCase {
    func testListWorkflowsSuccess() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try configure(app)

        try app.test(.GET, "/repos/testowner/testrepo/actions/workflows") { res in
            XCTAssertEqual(res.status, .ok)
            let workflows = try res.content.decode([Workflow].self)
            XCTAssertEqual(workflows.count, 1)
            XCTAssertEqual(workflows[0].name, "CI")
        }
    }

    func testListWorkflowsNotFound() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try configure(app)

        try app.test(.GET, "/repos/testowner/unknownrepo/actions/workflows") { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
}
```

### Explanation of the Test

1. **Setup**:

   - Create an `Application` instance in `.testing` mode.
   - Call the `configure` function to set up the app, ensuring all routes and handlers are registered.

2. **Test a Successful Response**:

   - Use `app.test(.GET, ...)` to simulate an HTTP request.
   - Check that the response status is `.ok` (200).
   - Decode the response body and verify its content.

3. **Test an Error Response**:

   - Simulate a request for a non-existent repository.
   - Assert that the response status is `.notFound` (404).

### 4.2 **Run the Test**

Run the test suite to confirm that the test fails because the functionality hasn’t been implemented yet. This failure is a crucial part of the TDD process as it ensures that the test is valid and the feature has not been prematurely implemented. By starting with a failing test, you can confirm that subsequent changes directly address the intended functionality.

```bash
swift test
```

---

## Step 5: Implement Minimal Functionality

Write just enough code to make the test pass. In this case, implement the `listWorkflows` method in your handler.

**File**: `Sources/App/Controllers/MyAPIHandler.swift`

```swift
struct MyAPIHandler: APIProtocol {
    func listWorkflows(_ input: Operations.listWorkflows.Input) async throws -> Operations.listWorkflows.Output {
        if input.path.repo == "testrepo" {
            let workflows = [
                Workflow(id: 1, name: "CI", path: ".github/workflows/ci.yml", state: "active")
            ]
            return .ok(workflows)
        }
        return .notFound
    }
}
```

Run the test again:

```bash
swift test
```

**Expected Result**: The test passes.

---

## Step 6: Refactor

Refactor the implementation to improve readability, modularity, or efficiency. For instance, consider extracting commonly used logic into helper methods or employing dependency injection for services like database access. Or, for example, you could replace direct inline logic with a `WorkflowService` class that manages workflows, which can then be injected into the handler. This approach simplifies testing and promotes better code reuse.

```swift
struct MyAPIHandler: APIProtocol {
    private let workflowsDatabase: [String: [Workflow]] = [
        "testrepo": [
            Workflow(id: 1, name: "CI", path: ".github/workflows/ci.yml", state: "active")
        ]
    ]

    func listWorkflows(_ input: Operations.listWorkflows.Input) async throws -> Operations.listWorkflows.Output {
        guard let workflows = workflowsDatabase[input.path.repo] else {
            return .notFound
        }
        return .ok(workflows)
    }
}
```

Run the test again to ensure it still passes.

---

## Step 7: Repeat for All Endpoints

Repeat the TDD cycle for all methods in `APIProtocol`. Prioritizing endpoints based on their complexity and usage frequency can make the development process more efficient. For example, start with endpoints that are foundational to the API's functionality, such as those related to retrieving data, and progress to more complex operations like creating or updating data. This ensures a logical flow and helps identify potential issues earlier in the development process.

1. Write tests for the endpoint.
2. Run the tests to confirm failure.
3. Implement minimal functionality to pass the tests.
4. Refactor and improve the implementation.
5. Add tests for edge cases.

**Example Progress Table**:

| Endpoint        | Test Written | Implementation Done | Refactored | Notes                   |
| --------------- | ------------ | ------------------- | ---------- | ----------------------- |
| `listWorkflows` | ✅            | ✅                   | ✅          | Basic workflows example |
| `getWorkflow`   | ✅            | ✅                   | ❌          | Needs refactoring       |
| `createIssue`   | ❌            | ❌                   | ❌          | Pending implementation  |

---

## Final Notes

1. **Run All Tests**:

   - Ensure all tests pass successfully.

   ```bash
   swift test
   ```

2. **Validate OpenAPI Compliance**:

   - Use tools like Postman or Swagger UI to verify the app against the OpenAPI spec.

3. **Deploy the App**:

   - Deploy your Vapor app to your preferred environment.

4. **Monitor and Maintain**:

   - Update tests and implementation as the OpenAPI spec evolves.

---

This tutorial provides a systematic, TDD-driven approach to implementing a Vapor app while adhering to the API contract defined in the [GithubProxyMonorepo](https://github.com/Contexter/GithubProxyMonorepo).

