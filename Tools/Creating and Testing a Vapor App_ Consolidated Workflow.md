>This guide helps developers quickly set up a Vapor app, run effective tests, and use shell scripts for automating patches.
# Creating and Testing a Vapor App: Consolidated Workflow

This guide will walk you through creating a Vapor app, ensuring the provided tests run correctly, and creating a shell script for patching files in the project. It also includes the final project structure to ensure everything is in place.

### Step-by-Step Guide

#### 1. Set Up the Environment

Ensure you have the necessary tools installed:
- **Swift**: Verify by running `swift --version`.
- **Vapor Toolbox**: Install using Homebrew:
  ```sh
  brew install vapor/tap/vapor
  ```

#### 2. Create a New Vapor Project

1. **Create the Project:**
   - Open a terminal and navigate to the desired directory.
   - Run the following command:
     ```sh
     vapor new MyVaporApp
     ```
   - Follow the prompts:
     ```
     name: MyVaporApp
     Would you like to use Fluent (ORM)? y
     Would you like to use Leaf (templating)? y
     ```
   - Navigate to the project directory:
     ```sh
     cd MyVaporApp
     ```

2. **Build and Run the Project:**
   - Open the project in Xcode:
     ```sh
     open Package.swift
     ```
   - Build and run the project:
     ```sh
     vapor run
     ```
   - Verify by navigating to `http://localhost:8080` in a browser.

#### 3. Ensure Provided Tests Run Correctly

1. **Locate the Existing Test Case:**
   - In Xcode, navigate to `Tests > AppTests > AppTests.swift`.
   - The content should already be populated with the following:

     ```swift
     @testable import App
     import XCTVapor
     import Fluent

     final class AppTests: XCTestCase {
         var app: Application!
         
         override func setUp() async throws {
             self.app = try await Application.make(.testing)
             try await configure(app)
             try await app.autoMigrate()
         }
         
         override func tearDown() async throws { 
             try await app.autoRevert()
             try await self.app.asyncShutdown()
             self.app = nil
         }
         
         func testHelloWorld() async throws {
             try await self.app.test(.GET, "hello", afterResponse: { res async in
                 XCTAssertEqual(res.status, .ok)
                 XCTAssertEqual(res.body.string, "Hello, world!")
             })
         }
         
         func testTodoIndex() async throws {
             let sampleTodos = [Todo(title: "sample1"), Todo(title: "sample2")]
             try await sampleTodos.create(on: self.app.db)
             
             try await self.app.test(.GET, "todos", afterResponse: { res async throws in
                 XCTAssertEqual(res.status, .ok)
                 XCTAssertEqual(
                     try res.content.decode([TodoDTO].self).sorted(by: { $0.title ?? "" < $1.title ?? "" }),
                     sampleTodos.map { $0.toDTO() }.sorted(by: { $0.title ?? "" < $1.title ?? "" })
                 )
             })
         }
         
         func testTodoCreate() async throws {
             let newDTO = TodoDTO(id: nil, title: "test")
             
             try await self.app.test(.POST, "todos", beforeRequest: { req in
                 try req.content.encode(newDTO)
             }, afterResponse: { res async throws in
                 XCTAssertEqual(res.status, .ok)
                 let models = try await Todo.query(on: self.app.db).all()
                 XCTAssertEqual(models.map { $0.toDTO().title }, [newDTO.title])
             })
         }
         
         func testTodoDelete() async throws {
             let testTodos = [Todo(title: "test1"), Todo(title: "test2")]
             try await testTodos.create(on: app.db)
             
             try await self.app.test(.DELETE, "todos/\(testTodos[0].requireID())", afterResponse: { res async throws in
                 XCTAssertEqual(res.status, .noContent)
                 let model = try await Todo.find(testTodos[0].id, on: self.app.db)
                 XCTAssertNil(model)
             })
         }
     }

     extension TodoDTO: Equatable {
         public static func == (lhs: Self, rhs: Self) -> Bool {
             lhs.id == rhs.id && lhs.title == rhs.title
         }
     }
     ```

2. **Configure the Scheme for Testing:**
   - Click on the scheme selector at the top center of Xcode.
   - Select `Manage Schemes...`.
   - In the list of schemes, select your scheme and click `Edit...`.
   - Go to the `Test` tab.
   - Ensure `AppTests` is included. If not, click the `+` button, add `AppTests`, and click `Add`.
   - Close the scheme editor.

3. **Run the Tests:**
   - Ensure the correct scheme is selected.
   - Press `Command-U` or go to `Product > Test`.

#### 4. Create and Execute a Shell Script for Patching

1. **Navigate to the Project Directory:**
   - Ensure you are in the root directory of your project:
     ```sh
     cd /path/to/your/MyVaporApp
     ```

2. **Create the Shell Script:**
   - Create a new shell script file:
     ```sh
     touch patch_script.sh
     ```

3. **Edit the Shell Script:**
   - Open the shell script in `nano`:
     ```sh
     nano patch_script.sh
     ```

4. **Add the Following Content to `patch_script.sh`:**

     ```sh
     #!/bin/bash

     # Define paths to configure.swift and test case file
     CONFIGURE_SWIFT_PATH="Sources/App/configure.swift"
     TEST_CASE_PATH="Tests/AppTests/AppTests.swift"

     # Navigate to the project directory (assuming this script is in the root of the project)
     cd "$(dirname "$0")" || exit

     # Function to add a comment to a file
     add_comment_to_file() {
       local file_path=$1
       local comment=$2

       if [ -f "$file_path" ]; then
         echo "// $comment" | cat - "$file_path" > temp && mv temp "$file_path"
         echo "Patched $file_path"
       else
         echo "File $file_path does not exist"
       fi
     }

     # Add comments to configure.swift and test case file
     add_comment_to_file "$CONFIGURE_SWIFT_PATH" "this is a first patch by shell script!"
     add_comment_to_file "$TEST_CASE_PATH" "this is a first patch by shell script!"

     echo "Patching completed."
     ```

5. **Save and Close the Editor:**
   - Save the changes and close the editor (for `nano`, press `Ctrl + X`, then `Y`, then `Enter`).

6. **Make the Script Executable:**
   - Make the script executable:
     ```sh
     chmod +x patch_script.sh
     ```

7. **Run the Script:**
   - Execute the script:
     ```sh
     ./patch_script.sh
     ```

### Project Structure

Your final project directory should look like this:

```
.
├── Dockerfile
├── Package.resolved
├── Package.swift
├── Public
├── Resources
│   └── Views
│       └── index.leaf
├── Sources
│   └── App
│       ├── Controllers
│       │   └── TodoController.swift
│       ├── DTOs
│       │   └── TodoDTO.swift
│       ├── Migrations
│       │   └── CreateTodo.swift
│       ├── Models
│       │   └── Todo.swift
│       ├── configure.swift
│       ├── entrypoint.swift
│       └── routes.swift
├── Tests
│   └── AppTests
│       └── AppTests.swift
├── docker-compose.yml
└── patch_script.sh

12 directories, 14 files
```

### Conclusion

By following these steps, you will have a comprehensive workflow for setting up and managing your Vapor app development environment effectively. This ensures that you can create, test, and maintain your Vapor applications with consistent practices.

### Commit Message for the Tutorial

```
Add tutorial for creating and testing a Vapor app with a patching shell script

This commit includes a detailed step-by-step guide on how to:
- Set up the environment and create a new Vapor project using Fluent and Leaf.
- Configure and run the provided tests for the Vapor application.
- Create a shell script to patch the configure.swift and AppTests.swift files.
- Ensure consistent development practices with clear instructions.
```
