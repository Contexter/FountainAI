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

### Further Enhancements: Adding GitHub Repository Creation and .gitignore File

To provide a comprehensive solution, we include GitHub repository creation, initializing a `.gitignore` file, and making the initial commit. Additionally, we create three empty shell script files named `dev_patch.sh`, numbered sequentially for patching the project in steps.

**setup_project.sh (Version C)**

```sh
#!/bin/bash

# Function to prompt for project name
prompt_project_name() {
    read -p "Enter the project name: " PROJECT_NAME
}

# Function to create project structure
create_project_structure() {
    echo "Creating project structure for

 $PROJECT_NAME..."

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

    # Create .gitignore file
    cat <<EOL > .gitignore
# SwiftPM
.build/
Package.resolved

# Xcode
*.xccheckout
*.xcscmblueprint

# Swift Package Manager
.build/

# Swift Core Libraries
.swiftpm/xcode/package.xcworkspace/

# User-specific files
*.swp
*.swo
*.tmp
*.log

# Environment variables
.env
EOL

    # Create empty patch scripts
    for i in {1..3}; do
        touch "${PROJECT_NAME}_dev_patch_${i}.sh"
    done

    # Initialize git repository
    git init
    git add .
    git commit -m "initial commit"

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

### Resulting Project Structure

After running the script, the resulting project directory structure will be as follows:

```
TreeCatMD/
├── .git/
│   ├── HEAD
│   ├── config
│   ├── description
│   ├── hooks/
│   ├── info/
│   ├── objects/
│   └── refs/
├── .gitignore
├── Package.swift
├── Sources/
│   ├── TreeCatMD/
│   │   └── main.swift
│   └── TreeCatMDLib/
│       └── lib.swift
├── Tests/
│   └── TreeCatMDTests/
│       └── TreeCatMDTests.swift
├── TreeCatMD_dev_patch_1.sh
├── TreeCatMD_dev_patch_2.sh
├── TreeCatMD_dev_patch_3.sh
```

### Conclusion

This paper presented the FountainAI method for creating a Swift command-line application using the command line, addressing the complexity of Xcode's GUI and emphasizing simplicity, idempotency, and interactivity. The provided script automates the project setup, ensuring a streamlined and efficient development process. By following this approach, developers can focus on writing code and tests, leveraging the power of the Swift Package Manager and command-line tools. Additionally, the script now supports Git repository creation, initializing a `.gitignore` file, and setting up patch scripts for future development steps.

### Commit Message

```plaintext
feat: Create and configure Swift command-line app with TDD and interactivity

- Initialize Swift package with executable and test targets
- Create project directory structure and setup initial files
- Ensure idempotency by cleaning up existing project directory
- Add interactivity by prompting for project name
- Refactor script into functions for readability and reusability
- Build project and run tests to verify setup
- Initialize Git repository with .gitignore and make initial commit
- Create empty patch scripts for future development
```

By following this structured approach, developers can efficiently create Swift command-line applications, maintaining focus on coding and testing while leveraging command-line tools for project management.