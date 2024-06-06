
## The (FountainAI) Method for Creating a Swift Command Line App Using the Command Line

### Background

Creating Swift command-line applications is essential for developers who build powerful tools and automation scripts. Xcode's GUI can be cumbersome and confusing, especially for developers who prefer working from the command line. This paper presents the FountainAI method for creating a Swift command-line application using the command line, emphasizing simplicity, idempotency, interactivity, and advanced scripting techniques.

### The Xcode Problematic

While Xcode is a powerful IDE, its complexity can hinder the development process due to its intricate settings and configurations. Developers often find themselves entangled in Xcode's build phases and schemes, which can detract from coding efficiency. The command-line approach simplifies these tasks, providing a streamlined and developer-friendly experience.

### Initial Setup Script (Version A)

The initial script sets up a basic Swift project with an executable and a test target. This version focuses on quickly creating the necessary structure and files.

**setup_project.sh (Version A)**

```sh
#!/bin/bash

# Project name
PROJECT_NAME="TreeCatMD"

# Create project directory
mkdir $PROJECT_NAME
cd $PROJECT_NAME

# Initialize Swift package
swift package init --type executable

# Move main.swift to the correct directory
mkdir -p Sources/${PROJECT_NAME}
mv Sources/main.swift Sources/${PROJECT_NAME}/

# Create a library target for shared code
mkdir -p Sources/${PROJECT_NAME}Lib
cat <<EOL > Sources/${PROJECT_NAME}Lib/lib.swift
public func getGreeting() -> String {
    return "Hello, TreeCatMD"
}
EOL

# Modify the executable main.swift to use the library
cat <<EOL > Sources/${PROJECT_NAME}/main.swift
import Foundation
import ${PROJECT_NAME}Lib

print(getGreeting())
EOL

# Create Tests directory and add test target
mkdir -p Tests/${PROJECT_NAME}Tests
cat <<EOL > Tests/${PROJECT_NAME}Tests/${PROJECT_NAME}Tests.swift
import XCTest
@testable import ${PROJECT_NAME}Lib

final class ${PROJECT_NAME}Tests: XCTestCase {

    func testExample() {
        XCTAssertEqual(getGreeting(), "Hello, TreeCatMD")
    }
}
EOL

# Create Package.swift
cat <<EOL > Package.swift
// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "$PROJECT_NAME",
    products: [
        .executable(name: "$PROJECT_NAME", targets: ["$PROJECT_NAME"]),
        .library(name: "${PROJECT_NAME}Lib", targets: ["${PROJECT_NAME}Lib"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "$PROJECT_NAME",
            dependencies: ["${PROJECT_NAME}Lib"]),
        .target(
            name: "${PROJECT_NAME}Lib",
            dependencies: []),
        .testTarget(
            name: "${PROJECT_NAME}Tests",
            dependencies: ["${PROJECT_NAME}Lib"]),
    ]
)
EOL

# Build the project
swift build

# Run tests
swift test
```

### Issues with Version A

1. **Lack of Idempotency**: Running the script multiple times can cause errors because it doesn't check if the project directory already exists.
2. **Lack of Function Modularity**: The script performs all tasks in a linear fashion without modular functions, making it less readable and harder to maintain.
3. **No Cleanup Mechanism**: The script doesn't clean up any existing project structure, which can lead to conflicts.

### Refactored Script (Version B)

The refactored script addresses these issues by adding idempotency, breaking tasks into modular functions, and including a cleanup mechanism.

**setup_project.sh (Version B)**

```sh
#!/bin/bash

# Function declarations for clarity and reusability
create_project_structure() {
    echo "Creating project structure for $PROJECT_NAME..."

    # Create project directory
    mkdir -p $PROJECT_NAME
    cd $PROJECT_NAME

    # Initialize Swift package
    swift package init --type executable

    # Move main.swift to the correct directory
    mkdir -p Sources/${PROJECT_NAME}
    mv Sources/main.swift Sources/${PROJECT_NAME}/

    # Create a library target for shared code
    mkdir -p Sources/${PROJECT_NAME}Lib
    cat <<EOL > Sources/${PROJECT_NAME}Lib/lib.swift
public func getGreeting() -> String {
    return "Hello, $PROJECT_NAME"
}
EOL

    # Modify the executable main.swift to use the library
    cat <<EOL > Sources/${PROJECT_NAME}/main.swift
import Foundation
import ${PROJECT_NAME}Lib

print(getGreeting())
EOL

    # Create Tests directory and add test target
    mkdir -p Tests/${PROJECT_NAME}Tests
    cat <<EOL > Tests/${PROJECT_NAME}Tests/${PROJECT_NAME}Tests.swift
import XCTest
@testable import ${PROJECT_NAME}Lib

final class ${PROJECT_NAME}Tests: XCTestCase {

    func testExample() {
        XCTAssertEqual(getGreeting(), "Hello, $PROJECT_NAME")
    }
}
EOL

    # Create Package.swift
    cat <<EOL > Package.swift
// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "$PROJECT_NAME",
    products: [
        .executable(name: "$PROJECT_NAME", targets: ["$PROJECT_NAME"]),
        .library(name: "${PROJECT_NAME}Lib", targets: ["${PROJECT_NAME}Lib"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "$PROJECT_NAME",
            dependencies: ["${PROJECT_NAME}Lib"]),
        .target(
            name: "${PROJECT_NAME}Lib",
            dependencies: []),
        .testTarget(
            name: "${PROJECT_NAME}Tests",
            dependencies: ["${PROJECT_NAME}Lib"]),
    ]
)
EOL

    # Build the project
    swift build

    # Run tests
    swift test
}

# Ensure the script is idempotent by removing the directory if it exists
cleanup() {
    if [ -d "$PROJECT_NAME" ]; then
        echo "Removing existing project directory..."
        rm -rf "$PROJECT_NAME"
    fi
}

# Main script execution
cleanup
create_project_structure

echo "Project $PROJECT_NAME setup completed successfully."
```

### Adding Interactivity

To enhance user experience, we add interactivity by prompting the user for the project name.

**setup_project.sh with Interactivity**

```sh
#!/bin/bash

# Function to prompt for project name
prompt_project_name() {
    read -p "Enter the project name: " PROJECT_NAME
}

# Function to create project structure
create_project_structure() {
    echo "Creating project structure for $PROJECT_NAME..."

    # Create project directory
    mkdir -p $PROJECT_NAME
    cd $PROJECT_NAME

    # Initialize Swift package
    swift package init --type executable

    # Move main.swift to the correct directory
    mkdir -p Sources/${PROJECT_NAME}
    mv Sources/main.swift Sources/${PROJECT_NAME}/

    # Create a library target for shared code
    mkdir -p Sources/${PROJECT_NAME}Lib
    cat <<EOL > Sources/${PROJECT_NAME}Lib/lib.swift
public func getGreeting() -> String {
    return "Hello, $PROJECT_NAME"
}
EOL

    # Modify the executable main.swift to use the library
    cat <<EOL > Sources/${PROJECT_NAME}/main.swift
import Foundation
import ${PROJECT_NAME}Lib

print(getGreeting())
EOL

    # Create Tests directory and add test target
    mkdir -p Tests/${PROJECT_NAME}Tests
    cat <<EOL > Tests/${PROJECT_NAME}Tests/${PROJECT_NAME}Tests.swift
import XCTest
@testable import ${PROJECT_NAME}Lib

final class ${PROJECT_NAME}Tests: XCTestCase {

    func testExample() {
        XCTAssertEqual(getGreeting(), "Hello, $PROJECT_NAME")
    }
}
EOL

    # Create Package.swift
    cat <<EOL > Package.swift
// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "$PROJECT_NAME",
    products: [
        .executable(name: "$PROJECT_NAME", targets: ["$PROJECT_NAME"]),
        .library(name: "${PROJECT_NAME}Lib", targets: ["${PROJECT_NAME}Lib"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "$PROJECT_NAME",
            dependencies: ["${PROJECT_NAME}Lib"]),
        .target(
            name: "${PROJECT_NAME}Lib",
            dependencies: []),
        .testTarget(
            name: "${PROJECT_NAME}Tests",
            dependencies: ["${PROJECT_NAME}Lib"]),
    ]
)
EOL

    # Build the project
    swift build

    # Run tests
    swift test
}

# Ensure the script is idempotent by removing the directory if it exists
cleanup() {
    if [ -d "$PROJECT_NAME" ]; then
        echo "Removing existing project directory..."
        rm -rf "$PROJECT_NAME"
    fi
}

# Main script execution
prompt_project_name
cleanup
create_project_structure

echo "Project $PROJECT_NAME setup completed successfully."
```

### Explanation of the Refactoring

1. **Interactivity**:
   - The script prompts the user for the project name, ensuring a customized project setup.

2. **Function Declarations**:
   - The script now has clear function declarations for creating the project structure (`create_project_structure`) and cleaning up existing directories (`cleanup`).

3. **Idempotency**:
   - The `cleanup` function ensures that any existing project directory is removed before creating a new one

, making the script idempotent.

4. **Modularity**:
   - Tasks are broken into modular functions, improving readability, maintainability, and reusability.

### Running the Script

1. **Save the Script**:
   - Save the script to a file, e.g., `setup_project.sh`.

2. **Make the Script Executable**:
   - Run the following command to make the script executable:
     ```sh
     chmod +x setup_project.sh
     ```

3. **Run the Script**:
   - Execute the script by running:
     ```sh
     ./setup_project.sh
     ```

### Conclusion

This paper presented the FountainAI method for creating a Swift command-line application using the command line, addressing the complexity of Xcode's GUI and emphasizing simplicity, idempotency, and interactivity. The provided script automates the project setup, ensuring a streamlined and efficient development process. By following this approach, developers can focus on writing code and tests, leveraging the power of the Swift Package Manager and command-line tools.

### Commit Message

```plaintext
feat: Create and configure Swift command-line app with TDD and interactivity

- Initialize Swift package with executable and test targets
- Create project directory structure and setup initial files
- Ensure idempotency by cleaning up existing project directory
- Add interactivity by prompting for project name
- Refactor script into functions for readability and reusability
- Build project and run tests to verify setup
```

By following this structured approach, developers can efficiently create Swift command-line applications, maintaining focus on coding and testing while leveraging command-line tools for project management.