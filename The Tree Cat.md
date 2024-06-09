>By using the presented setup script & following the structured steps suggested in this paper, developers can efficiently create and maintain the TreeCatMD project, ensuring clear development progress and effective use of TDD principles.

# Project Paper: TreeCatMD: Swift Directory Documentation Made Easy   
**Generate and share detailed Markdown documentation for your directory structures with TreeCatMD.**

---

## Introduction

This project aims to create a Swift-based command-line tool that generates a Markdown file containing the directory tree and the contents of files within a specified directory. The generated Markdown file is then copied to the clipboard for easy pasting into a Markdown editor or other interfaces. The tool will be integrated with Automator on macOS to allow users to generate the Markdown file via a quick action accessible from the Finder.

## Use Case and Environment

### Use Case

The primary use case for this tool is to facilitate discussions and interactions with AI systems by referencing entire packages of information stored in directories. Users often need to share or reference complex directory structures and file contents during conversations with AI assistants. This tool simplifies the process by generating a single, well-structured Markdown document that captures the entire directory structure and file contents.

### Environment

The tool is designed to run on macOS with the following environment specifications:
- **Operating System**: macOS
- **Language**: Swift
- **Additional Tools**: Homebrew (for installing dependencies like `tree`), Automator (for creating Quick Actions)

## Phase 1: Using the Template to Set Up the Project

To set up the project, we use an interactive shell script that ensures idempotency and modularity.

### Setup Script: `setup_project.sh`

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

    # Initialize git repository
    git init

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

**Explanation:**

- The script first prompts the user for a project name.
- It creates the project structure, initializes a Swift package, and sets up a basic library and executable target.
- The library contains a simple function, `getGreeting`, which is called from the `main.swift` of the executable target.
- A test target is also created to ensure the library function works as expected.
- The script initializes a git repository .

**Committing the Initial Setup:**

After running the setup script, commit the initial project structure:

```sh
git add .
git commit -m "Initial project setup with Swift package, basic library, executable target, and tests"
```

## Phase 2: Develop in a TDD Fashion

Test-Driven Development (TDD) is a software development process where tests are written before the actual functionality. The process involves writing a failing test, implementing the functionality to pass the test, and then refactoring the code as necessary. Below are the steps to develop this project using TDD.

### Step 1: Shell Command Execution

**Test:**

Create a new file `Tests/TestShellCommand.swift` and add the following code:

```swift
import XCTest
@testable import TreeCatMDLib

final class TestShellCommand: XCTestCase {

    func testShellCommand() {
        let output = shell("echo", "Hello, World!")
        XCTAssertEqual(output?.trimmingCharacters(in: .whitespacesAndNewlines), "Hello, World!")
    }
}
```

**Explanation:**

- This test verifies that the `shell` function can execute a simple shell command and return its output.

**Run the Test and See it Fail:**

```sh
swift test
```

**Committing the Failing Test:**

```sh
git add Tests/TestShellCommand.swift
git commit -m "Add failing test for shell command execution"
```

**Implement the Functionality:**

Create a new file `Sources/TreeCatMDLib/shell.swift` and add the following code:

```swift
import Foundation

// Executes a shell command and returns the output as a String
public func shell(_ args: String...) -> String? {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)
}
```

**Explanation:**

- The `shell` function executes a shell command using the `Process` class and returns the output as a string.

**Run the Test Again and See it Pass:**

```sh
swift test
```

**Committing the Passing Implementation:**

```sh
git add Sources/TreeCatMDLib/shell.swift
git commit -m "Implement shell command execution function"
```

### Step 2: Get Directory Tree

**Test:**

Create a new file `Tests/TestGetDirectoryTree.swift` and add the following code:

```swift
import XCTest
@testable import TreeCatMDLib

final class TestGetDirectoryTree: XCTestCase {

    func testGetDirectoryTree() {
        let output = getDirectoryTree(at: "/tmp")
        XCTAssertNotNil(output)
    }
}
```

**Explanation:**

- This test checks if the `getDirectoryTree` function can retrieve the directory tree structure.

**Run the Test and See it Fail:**

```sh
swift test
```

**Committing the Failing Test:**

```sh
git add Tests/TestGetDirectoryTree.swift
git commit -m "Add failing test for directory tree retrieval"
```

**Implement the Functionality:**

Create a new file `Sources/TreeCatMDLib/getDirectoryTree.swift` and add the following code:

```swift
import Foundation

// Retrieves the directory tree structure using the 'tree' command
public func getDirectoryTree(at path: String) -> String? {
    return shell("tree", path)
}
```

**Explanation:**

- The `getDirectoryTree` function calls the `shell` function to execute the `tree` command and return the directory structure.

**Run the Test Again and See it Pass:**

```sh
swift test
```

**Committing the Passing Implementation:**

```sh
git add Sources/TreeCatMDLib/getDirectoryTree.swift
git commit -m "Implement directory tree retrieval function"
```

### Step 3: Get File Contents

**Test:**

Create a new file `Tests/TestGetFileContents.swift` and add the following code:

```swift
import XCTest
@testable import TreeCatMDLib

final class TestGetFileContents: XCTestCase {

    func testGetFileContents() {
        let filePath = "/tmp/testFile.txt"
        let content = "Hello, World!"
        try? content.write(toFile: filePath, atomically: true, encoding: .utf8)
        let fileContent = getFileContents(at: filePath)
        XCTAssertEqual(fileContent, content)
    }
}
```

**Explanation:**

- This test checks if the `getFileContents` function can read the contents of a file correctly.

**Run the Test and See it Fail:**

```sh
swift test
```

**Committing the Failing Test:**

```sh
git add Tests/TestGetFileContents.swift
git commit -m "Add failing test for file contents retrieval"
```

**Implement the Functionality:**

Create a new file `Sources/TreeCatMDLib/getFileContents.swift` and add the following code:

```swift
import Foundation

// Retrieves the contents of a file as

 a String
public func getFileContents(at path: String) -> String {
    return (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
}
```

**Explanation:**

- The `getFileContents` function reads the contents of a file at the given path and returns it as a string. If the file cannot be read, it returns an empty string.

**Run the Test Again and See it Pass:**

```sh
swift test
```

**Committing the Passing Implementation:**

```sh
git add Sources/TreeCatMDLib/getFileContents.swift
git commit -m "Implement file contents retrieval function"
```

### Step 4: Generate Markdown

**Test:**

Create a new file `Tests/TestGenerateMarkdown.swift` and add the following code:

```swift
import XCTest
@testable import TreeCatMDLib

final class TestGenerateMarkdown: XCTestCase {

    func testGenerateMarkdown() {
        let directory = "/tmp/testDir"
        let fileManager = FileManager.default
        try? fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        let filePath = "\(directory)/testFile.txt"
        let content = "Hello, World!"
        try? content.write(toFile: filePath, atomically: true, encoding: .utf8)

        generateMarkdown(for: directory, outputFileName: "testOutput.md")

        let outputPath = "\(directory)/testOutput.md"
        let outputContent = try? String(contentsOfFile: outputPath)
        XCTAssertNotNil(outputContent)
        XCTAssertTrue(outputContent?.contains("# \(directory)") ?? false)
    }
}
```

**Explanation:**

- This test verifies if the `generateMarkdown` function can generate a Markdown file with the directory tree and file contents.

**Run the Test and See it Fail:**

```sh
swift test
```

**Committing the Failing Test:**

```sh
git add Tests/TestGenerateMarkdown.swift
git commit -m "Add failing test for Markdown generation"
```

**Implement the Functionality:**

Create a new file `Sources/TreeCatMDLib/generateMarkdown.swift` and add the following code:

```swift
import Foundation

// Generates a Markdown file containing the directory tree and file contents
public func generateMarkdown(for directory: String, outputFileName: String) {
    let fileManager = FileManager.default
    var markdown = "# \(directory)\n\n"

    // Get directory tree
    if let tree = getDirectoryTree(at: directory) {
        markdown += "## Directory Tree\n"
        markdown += "```\n"
        markdown += tree
        markdown += "\n```\n\n"
    } else {
        markdown += "'tree' command not found. Please install it using 'brew install tree'.\n\n"
    }

    // Get file contents
    markdown += "## File Contents\n"
    if let enumerator = fileManager.enumerator(atPath: directory) {
        for case let file as String in enumerator {
            let filePath = "\(directory)/\(file)"
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory), !isDirectory.boolValue {
                let fileHeader = "### \(file)\n"
                let fileStart = "```\n"
                let fileEnd = "\n```\n"
                let fileContent = getFileContents(at: filePath)

                markdown += fileHeader + fileStart + fileContent + fileEnd
            }
        }
    }

    // Write to file
    try? markdown.write(toFile: outputFileName, atomically: true, encoding: .utf8)
    print("Markdown file generated: \(outputFileName)")

    // Copy to clipboard
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(markdown, forType: .string)
    print("Contents copied to clipboard")
}
```

**Explanation:**

- The `generateMarkdown` function generates a Markdown file by combining the directory tree and file contents, then writes it to the specified output file. It also copies the contents to the clipboard for easy pasting.

**Run the Test Again and See it Pass:**

```sh
swift test
```

**Committing the Passing Implementation:**

```sh
git add Sources/TreeCatMDLib/generateMarkdown.swift
git commit -m "Implement Markdown generation function"
```

### Step 5: Size Limit Check

**Test:**

Create a new file `Tests/TestSizeCheck.swift` and add the following code:

```swift
import XCTest
@testable import TreeCatMDLib

final class TestSizeCheck: XCTestCase {

    func testSizeCheckWithinLimit() {
        XCTAssertTrue(checkSizeLimit(currentSize: 500_000, additionalSize: 500_000))
    }

    func testSizeCheckExceedingLimit() {
        XCTAssertFalse(checkSizeLimit(currentSize: 900_000, additionalSize: 200_000))
    }
}
```

**Explanation:**

- This test checks if the `checkSizeLimit` function correctly identifies whether the combined size of current and additional content exceeds a given limit.

**Run the Test and See it Fail:**

```sh
swift test
```

**Committing the Failing Test:**

```sh
git add Tests/TestSizeCheck.swift
git commit -m "Add failing test for size limit check"
```

**Implement the Functionality:**

Create a new file `Sources/TreeCatMDLib/size_check.swift` and add the following code:

```swift
import Foundation

// Checks if the total size after adding additional content exceeds the specified limit
public func checkSizeLimit(currentSize: Int, additionalSize: Int, sizeLimit: Int = 1 * 1024 * 1024) -> Bool {
    return (currentSize + additionalSize) <= sizeLimit
}
```

**Explanation:**

- The `checkSizeLimit` function ensures that the total size of the current content plus additional content does not exceed a specified limit (default 1 MB).

**Run the Test Again and See it Pass:**

```sh
swift test
```

**Committing the Passing Implementation:**

```sh
git add Sources/TreeCatMDLib/size_check.swift
git commit -m "Implement size limit check function"
```

### Step 6: Generate Markdown with Size Check

**Test:**

Create a new file `Tests/TestGenerateMarkdownWithSizeCheck.swift` and add the following code:

```swift
import XCTest
@testable import TreeCatMDLib

final class TestGenerateMarkdownWithSizeCheck: XCTestCase {

    func testGenerateMarkdown() {
        let directory = "/tmp/testDir"
        let fileManager = FileManager.default
        try? fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        let filePath = "\(directory)/testFile.txt"
        let content = "Hello, World!"
        try? content.write(toFile: filePath, atomically: true, encoding: .utf8)

        generateMarkdown(for: directory, outputFileName: "testOutput.md")

        let outputPath = "\(directory)/testOutput.md"
        let outputContent = try? String(contentsOfFile: outputPath)
        XCTAssertNotNil(outputContent)
        XCTAssertTrue(outputContent?.contains("# \(directory)") ?? false)
    }

    func testGenerateMarkdownExceedsSize() {
        let directory = "/tmp/testDir"
        let fileManager = FileManager.default
        try? fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        let filePath = "\(directory)/testFile.txt"
        let content = String(repeating: "A", count: 2 * 1024 * 1024) // 2 MB
        try? content.write(toFile: filePath, atomically: true, encoding: .utf8)

        generateMarkdown(for: directory, outputFileName: "testOutput.md")

        let outputPath = "\(directory)/testOutput.md"
        let outputContent = try? String(contentsOfFile: outputPath)
        XCTAssertNil(outputContent)
    }
}
```

**Explanation:**

- This test checks if the `generateMarkdown` function respects the size limit when generating the Markdown file. If the file content exceeds the limit, the Markdown file should not be generated.

**Run the Test and See it Fail:**

```sh
swift test
```

**Committing the Failing Test:**

```sh
git add Tests/TestGenerateMarkdownWithSizeCheck.swift
git commit -m "Add failing test for Markdown generation with size check"
```

**Modify the Functionality:**

Update `Sources/TreeCatMDLib/generateMarkdown.swift` to include the size check:

```swift
import Foundation

public func generateMarkdown(for directory: String, outputFileName: String) {
    let fileManager = FileManager.default
    var markdown = "# \(directory)\n\n"
    var currentSize = 0
    let sizeLimit = 1 * 1024 * 1024 // 1 MB

    // Get directory tree
    if let tree = getDirectoryTree(at: directory) {
        markdown += "## Directory Tree\n"
        markdown += "```\n"
        markdown += tree
        markdown += "\n```\n\n"
        currentSize += tree.count
    } else {
        markdown += "'tree' command not found. Please install it using 'brew install tree'.\n\n"
    }

    // Get file contents
    markdown += "## File Contents\n"
    if let enumerator = fileManager.enumerator(atPath: directory) {
        for case let file as String in enumerator {
           

 let filePath = "\(directory)/\(file)"
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory), !isDirectory.boolValue {
                let fileHeader = "### \(file)\n"
                let fileStart = "```\n"
                let fileEnd = "\n```\n"
                let fileContent = getFileContents(at: filePath)

                let totalContent = fileHeader + fileStart + fileContent + fileEnd
                if !checkSizeLimit(currentSize: currentSize, additionalSize: totalContent.count) {
                    print("The resulting Markdown file exceeds the size limit of \(sizeLimit / 1024) KB. Stopping the process.")
                    return
                }
                currentSize += totalContent.count
                markdown += totalContent
            }
        }
    }

    // Write to file
    try? markdown.write(toFile: outputFileName, atomically: true, encoding: .utf8)
    print("Markdown file generated: \(outputFileName)")

    // Copy to clipboard
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(markdown, forType: .string)
    print("Contents copied to clipboard")
}
```

**Explanation:**

- The `generateMarkdown` function now includes a check to ensure the combined size of the directory tree and file contents does not exceed the specified limit (1 MB).

**Run the Test Again and See it Pass:**

```sh
swift test
```

**Committing the Passing Implementation:**

```sh
git add Sources/TreeCatMDLib/generateMarkdown.swift
git commit -m "Implement Markdown generation function with size check"
```

## Phase 3: Automator Integration

1. **Open Automator**:
   - Go to `Applications` > `Automator`.
   - Select `New Document`.
   - Choose `Quick Action` and click `Choose`.

2. **Configure Workflow**:
   - Set `Workflow receives current` to `folders` in `Finder`.

3. **Add a "Run Shell Script" Action**:
   - In the search bar, type "Run Shell Script" and drag it to the workflow area.
   - Set `Shell` to `/bin/bash` and `Pass input` to `as arguments`.
   - Enter the following script:
     ```sh
     for f in "$@"
     do
       /usr/local/bin/TreeCatMD "$f"
     done
     ```

4. **Save the Quick Action**:
   - Go to `File` > `Save`.
   - Name it something like "Generate Markdown from Folder".

## Resulting Project Structure

After implementing all the steps, the resulting project directory structure will be as follows:

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
│   ├── TreeCatMDLib/
│       ├── lib.swift
│       ├── shell.swift
│       ├── getDirectoryTree.swift
│       ├── getFileContents.swift
│       ├── generateMarkdown.swift
│       └── size_check.swift
├── Tests/
│   ├── TestShellCommand.swift
│   ├── TestGetDirectoryTree.swift
│   ├── TestGetFileContents.swift
│   ├── TestGenerateMarkdown.swift
│   ├── TestSizeCheck.swift
│   └── TestGenerateMarkdownWithSizeCheck.swift
└── testOutput.md
```

## Conclusion

This paper presented the FountainAI method for creating a Swift command-line application using the command line, addressing the complexity of Xcode's GUI and emphasizing simplicity, idempotency, and interactivity. The provided script automates the project setup, ensuring a streamlined and efficient development process. By following this approach, developers can focus on writing code and tests, leveraging the power of the Swift Package Manager and command-line tools. Additionally, the script now supports Git repository creation, initializing a `.gitignore` file, and setting up patch scripts for future development steps.

## Final Commit Message

```plaintext
feat: Implement TreeCatMD with TDD and Automator integration

- Initialize Swift package with executable and test targets
- Create project directory structure and setup initial files
- Ensure idempotency by cleaning up existing project directory
- Add interactivity by prompting for project name
- Implement and test shell command execution function
- Implement and test directory tree retrieval function
- Implement and test file contents retrieval function
- Implement and test Markdown generation function
- Add size limit functionality to Markdown generation and test
- Integrate with Automator for macOS quick actions
- Initialize Git repository with .gitignore and make initial commits for each development step
```



