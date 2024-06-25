# Matrix Bot Merger Tool

## Tagline
Effortlessly iterate through and merge relevant OpenAPI specs for creating a Matrix bot.

## Introduction
The Matrix Bot Merger Tool is a Swift command-line application designed to help developers identify and merge relevant OpenAPI specifications for creating Matrix bots. This tool leverages the OpenAI GPT model to determine the relevance of each spec, prompting the user for confirmation before proceeding with the next spec. It is built using the Vapor framework and follows a test-driven development (TDD) approach.

## Table of Contents
1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Project Setup](#project-setup)
    1. [Initial Setup Script](#initial-setup-script)
    2. [Enhancing TDD](#enhancing-tdd)
4. [Implementation](#implementation)
    1. [Main Application](#main-application)
    2. [Abstraction for User Input](#abstraction-for-user-input)
    3. [Tests](#tests)
5. [Running the Tool](#running-the-tool)
6. [Conclusion](#conclusion)

## Features
- **Automated OpenAPI Spec Analysis**: Utilizes OpenAI GPT to determine the relevance of OpenAPI specs.
- **User Interaction**: Prompts the user for confirmation to proceed with the next spec or specify a file name.
- **Spec Merging**: Merges relevant OpenAPI specs into a single document.
- **Test-Driven Development**: Includes tests to ensure reliability and correctness.

## Prerequisites
- Swift and Vapor installed on your machine.
- OpenAI API key for accessing GPT models.

## Project Setup

### Initial Setup Script

Create a setup script named `setup_project.sh` to initialize the project structure:

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
    touch Sources/${PROJECT_NAME}Lib/lib.swift

    # Modify the executable main.swift to use the library
    cat <<EOL > Sources/${PROJECT_NAME}/main.swift
import Foundation
import ${PROJECT_NAME}Lib

print("Matrix Bot Merger Tool")
EOL

    # Create Tests directory and add test target
    mkdir -p Tests/${PROJECT_NAME}Tests
    touch Tests/${PROJECT_NAME}Tests/${PROJECT_NAME}Tests.swift

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
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/openai/openai-swift", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "$PROJECT_NAME",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "OpenAI", package: "openai-swift")
            ]),
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

To further emphasize TDD, the script includes dummy tests to reinforce the development approach of writing tests first, then implementing code to pass those tests.

## Implementation

### Main Application

Edit `Sources/<ProjectName>/main.swift` to implement the tool's logic:

```swift
import Foundation
import OpenAI

struct OpenAPISpec: Codable {
    var spec: String
}

func askGPT(openAPISpec: String, question: String, apiKey: String) -> Bool {
    let openAI = OpenAI(apiKey: apiKey)
    let prompt = """
    Question: \(question)
    OpenAPI Spec: \(openAPISpec)
    """
    do {
        let response = try openAI.createCompletion(model: "gpt-4", prompt: prompt, maxTokens: 1024).wait()
        return response.choices.first?.text.contains("yes") ?? false
    } catch {
        print("Error querying GPT: \(error)")
        return false
    }
}

func mergeSpecs(specs: [String], question: String, apiKey: String) -> String? {
    let openAI = OpenAI(apiKey: apiKey)
    let prompt = """
    Question: Please merge the following OpenAPI specs if they meet the criteria: \(question)
    OpenAPI Specs: \(specs.joined(separator: "\n\n"))
    """
    do {
        let response = try openAI.createCompletion(model: "gpt-4", prompt: prompt, maxTokens: 2048).wait()
        return response.choices.first?.text
    } catch {
        print("Error merging specs: \(error)")
        return nil
    }
}

func promptUserForNextAction(inputProvider: InputProvider) -> String {
    print("Press 'c' to continue with the next spec, 'f' to specify a file name, or 'q' to quit:")
    if let response = inputProvider.readInput()?.lowercased() {
        return response
    }
    return "q"
}

func promptUserForFileName(inputProvider: InputProvider) -> String? {
    print("Enter the file name of the next spec to process:")
    return inputProvider.readInput()
}

func promptUserForMergeConfirmation(inputProvider: InputProvider) -> Bool {
    print("Do you want to proceed with the merge? (yes/no):")
    if let response = inputProvider.readInput()?.lowercased() {
        return response == "yes"
    }
    return false
}

func promptUserForAdditionalCriteria(inputProvider: InputProvider) -> String? {
    print("Enter any additional criteria to be met before merging (or press Enter to skip):")
    return inputProvider.readInput()
}

func saveMergedSpec(mergedSpec: String, fileName: String) {
    let fileURL = URL(fileURLWithPath: fileName)
    do {
        try mergedSpec.write(to: fileURL, atomically: true, encoding: .utf8)
        print("Merged OpenAPI spec saved to \(fileName)")
    } catch {
        print("Failed to save merged spec: \(error)")
    }
}

func main() {
    let arguments = CommandLine.arguments
    guard arguments.count == 4 else {
        print("Usage: <executable> <directory_path> <question> <api_key>")
        return
    }

    let directoryPath = arguments[1]
    let question = arguments[2]
    let apiKey = arguments[3]
    let inputProvider = ConsoleInputProvider()

    var relevantSpecs = [String]()
    var filesToProcess = [String]()

    do {
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(atPath: directoryPath)
        filesToProcess = files

        while !filesToProcess.isEmpty {
            let file = filesToProcess.removeFirst()
            let filePath = "\(directoryPath)/\(file)"
            if let openAPISpec = try? String(contentsOfFile: filePath, encoding: .utf8) {
                if askGPT(openAPISpec: openAPISpec, question: question

, apiKey: apiKey) {
                    relevantSpecs.append(openAPISpec)
                }
            }

            let action = promptUserForNextAction(inputProvider: inputProvider)
            if action == "q" {
                break
            } else if action == "f" {
                if let fileName = promptUserForFileName(inputProvider: inputProvider) {
                    filesToProcess.insert(fileName, at: 0)
                }
            }
        }

        if !relevantSpecs.isEmpty {
            if let additionalCriteria = promptUserForAdditionalCriteria(inputProvider: inputProvider), !additionalCriteria.isEmpty {
                let combinedQuestion = "\(question). Additional criteria: \(additionalCriteria)"
                if let mergedSpec = mergeSpecs(specs: relevantSpecs, question: combinedQuestion, apiKey: apiKey), promptUserForMergeConfirmation(inputProvider: inputProvider) {
                    saveMergedSpec(mergedSpec: mergedSpec, fileName: "merged_openapi_spec.yaml")
                }
            } else {
                if let mergedSpec = mergeSpecs(specs: relevantSpecs, question: question, apiKey: apiKey), promptUserForMergeConfirmation(inputProvider: inputProvider) {
                    saveMergedSpec(mergedSpec: mergedSpec, fileName: "merged_openapi_spec.yaml")
                }
            }
        }
    } catch {
        print("Error reading directory: \(error)")
    }
}

main()
```

### Abstraction for User Input

Create an abstraction for user input in `Sources/<ProjectName>Lib/Input.swift`:

```swift
import Foundation

public protocol InputProvider {
    func readInput() -> String?
}

public class ConsoleInputProvider: InputProvider {
    public init() {}
    public func readInput() -> String? {
        return readLine()
    }
}
```

### Tests

Implement tests in `Tests/<ProjectName>Tests/<ProjectName>Tests.swift`:

```swift
import XCTest
@testable import <ProjectName>Lib

final class <ProjectName>Tests: XCTestCase {
    func testAskGPT() {
        // Mock data and test the askGPT function
    }

    func testMergeSpecs() {
        let specs = ["spec1", "spec2"]
        let question = "Are these specs relevant for creating a Matrix bot?"
        let mergedSpec = mergeSpecs(specs: specs, question: question, apiKey: "test_api_key")
        XCTAssertNotNil(mergedSpec)
    }

    func testPromptUserForNextAction() {
        let mockInputProvider = MockInputProvider(inputs: ["c"])
        let action = promptUserForNextAction(inputProvider: mockInputProvider)
        XCTAssertEqual(action, "c")
    }

    func testPromptUserForFileName() {
        let mockInputProvider = MockInputProvider(inputs: ["testFile.yaml"])
        let fileName = promptUserForFileName(inputProvider: mockInputProvider)
        XCTAssertEqual(fileName, "testFile.yaml")
    }

    func testPromptUserForMergeConfirmation() {
        let mockInputProvider = MockInputProvider(inputs: ["yes"])
        let confirmation = promptUserForMergeConfirmation(inputProvider: mockInputProvider)
        XCTAssertTrue(confirmation)
    }

    func testPromptUserForAdditionalCriteria() {
        let mockInputProvider = MockInputProvider(inputs: ["criteria"])
        let criteria = promptUserForAdditionalCriteria(inputProvider: mockInputProvider)
        XCTAssertEqual(criteria, "criteria")
    }

    // Additional tests...
}
```

Implement a mock input provider in `Tests/<ProjectName>Tests/MockInputProvider.swift`:

```swift
import Foundation
@testable import <ProjectName>Lib

class MockInputProvider: InputProvider {
    var inputs: [String]
    var index = 0

    init(inputs: [String]) {
        self.inputs = inputs
    }

    func readInput() -> String? {
        guard index < inputs.count else { return nil }
        let input = inputs[index]
        index += 1
        return input
    }
}
```

### Running the Tool

1. **Build and Run**:
   ```sh
   chmod +x setup_project.sh
   ./setup_project.sh
   cd <ProjectName>
   swift build
   swift run <ProjectName> <directory_path> "Is this OpenAPI spec relevant for creating a matrix bot?" <your_openai_api_key>
   ```

Replace `<ProjectName>` with your actual project name, `<directory_path>` with the path to your directory of OpenAPI specs, and `<your_openai_api_key>` with your actual OpenAI API key.

### Commit Message

```plaintext
feat: Create and configure Matrix Bot Merger Tool

- Initialize Swift package with executable and test targets
- Create project directory structure and setup initial files
- Ensure idempotency by cleaning up existing project directory
- Add interactivity by prompting for project name
- Implement OpenAPI spec analysis using OpenAI GPT
- Implement user interaction for proceeding with specs
- Implement merging logic with OpenAI GPT
- Implement user prompts for confirmation and additional criteria
- Add tests for user input and merging logic
- Build project and run tests to verify setup
- Initialize Git repository with .gitignore and make initial commit
```

### Conclusion

This documentation provides a comprehensive guide to setting up, implementing, and testing the Matrix Bot Merger Tool. By following these steps, you can create a robust tool for iterating through and merging relevant OpenAPI specs for creating a Matrix bot, while adhering to the principles of test-driven development. The tool leverages OpenAI's GPT model to assist in determining relevance and merging specs, ensuring a streamlined and efficient process. The implementation also includes user prompts for confirmation and additional criteria before merging, ensuring that the process meets the user's specific requirements.