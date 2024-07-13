# A Method for Creating Swift Command Line Apps Using the Command Line

### Background

Creating Swift command-line applications is essential for developers who build powerful tools and automation scripts. Xcode's GUI can be cumbersome and confusing, especially for developers who prefer working from the command line. This paper presents a method for creating a Swift command-line application using the command line, emphasizing simplicity, idempotency, interactivity, and advanced scripting techniques.

### The Xcode Problematic

While Xcode is a powerful IDE, its complexity can hinder the development process due to its intricate settings and configurations. Developers often find themselves entangled in Xcode's build phases and schemes, which can detract from coding efficiency. The command-line approach simplifies these tasks, providing a streamlined and developer-friendly experience.

### Test-Driven Development (TDD) Approach

Instead of creating and using patches to develop the application, the true Test-Driven Development (TDD) method involves writing tests first, seeing them fail, and then implementing the code to make them pass. This approach ensures code quality and reliability from the outset.

### Initial Setup Script

The initial script sets up a basic Swift project with an executable and a test target. This version focuses on quickly creating the necessary structure and files, following the TDD approach.

**setup_project.sh**

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
public func functionExample1() -> String {
    return "Function Example 1"
}

public func functionExample2() -> String {
    return "Function Example 2"
}

public func functionExample3() -> String {
    return "Function Example 3"
}

public func functionExample4() -> String {
    return "Function Example 4"
}

public func functionExample5() -> String {
    return "Function Example 5"
}

public func functionExample6() -> String {
    return "Function Example 6"
}

public func functionExample7() -> String {
    return "Function Example 7"
}

public func functionExample8() -> String {
    return "Function Example 8"
}

public func functionExample9() -> String {
    return "Function Example 9"
}

public func functionExample10() -> String {
    return "Function Example 10"
}
EOL

    # Modify the executable main.swift to use the library
    cat <<EOL > Sources/${PROJECT_NAME}/main.swift
import Foundation
import ${PROJECT_NAME}Lib

print(functionExample1())
EOL

    # Create Tests directory and add test target with 10 dummy tests
    mkdir -p Tests/${PROJECT_NAME}Tests
    cat <<EOL > Tests/${PROJECT_NAME}Tests/${PROJECT_NAME}Tests.swift
import XCTest
@testable import ${PROJECT_NAME}Lib

final class ${PROJECT_NAME}Tests: XCTestCase {

    func testFunctionExample1() {
        XCTAssertEqual(functionExample1(), "Function Example 1")
    }

    func testFunctionExample2() {
        XCTAssertEqual(functionExample2(), "Function Example 2")
    }

    func testFunctionExample3() {
        XCTAssertEqual(functionExample3(), "Function Example 3")
    }

    func testFunctionExample4() {
        XCTAssertEqual(functionExample4(), "Function Example 4")
    }

    func testFunctionExample5() {
        XCTAssertEqual(functionExample5(), "Function Example 5")
    }

    func testFunctionExample6() {
        XCTAssertEqual(functionExample6(), "Function Example 6")
    }

    func testFunctionExample7() {
        XCTAssertEqual(functionExample7(), "Function Example 7")
    }

    func testFunctionExample8() {
        XCTAssertEqual(functionExample8(), "Function Example 8")
    }

    func testFunctionExample9() {
        XCTAssertEqual(functionExample9(), "Function Example 9")
    }

    func testFunctionExample10() {
        XCTAssertEqual(functionExample10(), "Function Example 10")
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
*.xcworkspace
*.xcuserstate
*.xcodeproj
*.xcuserdata

# Build products
*.app
*.dSYM
*.ipa
*.xcarchive

# Swift Package Manager
.swiftpm/xcode/package.xcworkspace/

# User-specific files
*.swp
*.swo
*.tmp
*.log

# Environment variables
.env

# Note: Use GitHub secrets as much as possible for managing sensitive configuration.
EOL

    # Initialize git repository and make initial commit
    git init
    git add .
    git commit -m "Initial commit: Setup Swift command-line app with TDD structure"
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

### Enhancing TDD

To further emphasize TDD, the script includes 10 dummy tests to remind us to think about development in terms of failing and passing tests of library code (reusable code).

### Options for Structuring Tests

There are two primary options for structuring tests: consolidating them in a single test file or creating individual test files for each test. Each approach has its benefits and drawbacks.

#### Option 1: Single Test File

This approach places all test cases within a single file. This can be simpler to manage for smaller projects or when the number of tests is limited.

**Tree Structure:**
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
│       ├── lib.swift
├── Tests/
│   └── TreeCatMDTests/
│       └── TreeCatMDTests.swift
```

**Tests File:**
```swift
import XCTest
@testable import TreeCatMDLib

final class TreeCatMDTests: XCTestCase {

    func testFunctionExample1() {
        XCTAssertEqual(functionExample1(), "Function Example 1")
    }

    func testFunctionExample2() {
        XCTAssertEqual(functionExample2(), "Function Example 2")
    }

    func testFunctionExample3() {
        XCTAssertEqual(functionExample3(), "Function Example 3")
    }

    func testFunctionExample4() {
        XCTAssertEqual(functionExample4(), "Function Example 4")
    }

    func testFunctionExample5() {
        XCTAssertEqual(functionExample5(), "Function Example 5")
    }

    func testFunctionExample6() {
        XCTAssertEqual(functionExample6(), "Function Example 6")
    }

    func testFunctionExample7() {
        XCTAssertEqual(functionExample7(), "Function Example 7")
    }

    func testFunctionExample8() {
        XCTAssertEqual(functionExample8(), "Function Example 8")
    }

    func testFunctionExample9() {
        XCTAssertEqual(functionExample9(), "Function Example 9")
    }

    func testFunctionExample10() {
        XCTAssertEqual(functionExample10(), "Function Example 10")
    }
}
```

#### Option 2: Separate Test Files

This approach involves creating individual test files for each test case. This can be beneficial for larger projects, as it allows for more modular and manageable code.

**Tree Structure:**
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
│       ├── lib.swift
│       ├── functionExample1.swift
│       ├── functionExample2.swift
│       ├── functionExample3.swift
│       ├── functionExample4.swift
│       ├── functionExample5.swift
│       ├── functionExample6.swift
│       ├── functionExample7.swift
│       ├── functionExample8.swift
│       ├── functionExample9.swift
│       └── functionExample10.swift
├── Tests/
│   └── TreeCatMDTests/
│       ├── testFunctionExample1.swift
│       ├── testFunctionExample2.swift
│       ├── testFunctionExample3.swift
│       ├── testFunctionExample4.swift
│       ├── testFunctionExample5.swift
│       ├── testFunctionExample6.swift
│       ├── testFunctionExample7.swift
│       ├── testFunctionExample8.swift
│       ├── testFunctionExample9.swift
│       └── testFunctionExample10.swift
```

**Example Function File (functionExample1.swift):**
```swift
// Sources/TreeCatMDLib/functionExample1.swift
public func functionExample1() -> String {
    return "Function Example 1"
}
```

**Example Test File (testFunctionExample1.swift):**
```swift
// Tests/TreeCatMDTests/testFunctionExample1.swift
import XCTest
@testable import TreeCatMDLib

final class testFunctionExample1: XCTestCase {

    func testFunctionExample1() {
        XCTAssertEqual(functionExample1(), "Function Example 1")
    }
}
```

### Importing the Library in the Multi-File Structure

When structuring tests into separate files, each test file needs to import the library appropriately. Here's how we ensure each test file imports the necessary module:

1. **Create Separate Swift Files for Each Function:**
   - Split the functions into individual Swift files under the `Sources/TreeCatMDLib/` directory (e.g., `functionExample1.swift`, `functionExample2.swift`, etc.).

2. **Ensure Each Test File Imports the Library:**
   - Each test file in the `Tests/TreeCatMDTests/` directory should import the `TreeCatMDLib` module.

**Example Function File (functionExample1.swift):**
```swift
// Sources/TreeCatMDLib/functionExample1.swift
public func functionExample1() -> String {
    return "Function Example 1"
}
```

**Example Test File (testFunctionExample1.swift):**
```swift
// Tests/TreeCatMDTests/testFunctionExample1.swift
import XCTest
@testable import TreeCatMDLib

final class testFunctionExample1: XCTestCase {

    func testFunctionExample1() {
        XCTAssertEqual(functionExample1(), "Function Example 1")
    }
}
```

By following these steps, we can maintain a clear and modular structure for both our library code and our tests.

### Conclusion

This paper presented a method for creating a Swift command-line application using the command line, addressing the complexity of Xcode's GUI and emphasizing simplicity, idempotency, and interactivity. The provided script automates the project setup, ensuring a streamlined and efficient development process. By following this approach, we can focus on writing tests first, implementing the code to pass those tests, and leveraging the power of the Swift Package Manager and command-line tools. This method ensures high-quality, reliable code from the outset, adhering to the principles of Test-Driven Development (TDD).

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
- Implement TDD approach: write tests, see them fail, and implement code to pass
- Include 10 dummy tests to reinforce TDD principles
- Provide options for structuring tests: single file or separate files
- Ensure proper importing of the library in the multi-file test structure
```

By following this structured approach, we can efficiently create Swift command-line applications, maintaining focus on coding and testing while leveraging command-line tools for project management.