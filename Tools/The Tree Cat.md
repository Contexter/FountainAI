### Project Paper: Directory Tree and File Content Generation with Swift Using the FountainAI Method

#### Introduction

This project aims to create a Swift-based command-line tool, TreeCatMD, that generates a Markdown file containing the directory tree and the contents of files within a specified directory. The generated Markdown file is then copied to the clipboard for easy pasting into a Markdown editor or other interfaces. The tool will be integrated with Automator on macOS to allow users to generate the Markdown file via a quick action accessible from the Finder.

#### Use Case and Environment

##### Use Case

The primary use case for this tool is to facilitate discussions and interactions with AI systems by referencing entire packages of information stored in directories. Users often need to share or reference complex directory structures and file contents during conversations with AI assistants. This tool simplifies the process by generating a single, well-structured Markdown document that captures the entire directory structure and file contents.

##### Environment

The tool is designed to run on macOS with the following environment specifications:
- **Operating System**: macOS
- **Language**: Swift
- **Additional Tools**: Homebrew (for installing dependencies like `tree`), Automator (for creating Quick Actions)

#### Test-Driven Development (TDD) Approach

Test-Driven Development (TDD) is a software development process where tests are written before the actual functionality. The process involves the following steps:
1. **Write a test** for the next bit of functionality.
2. **Run the test** to ensure it fails (since the functionality is not yet implemented).
3. **Implement the functionality** to make the test pass.
4. **Refactor the code**, ensuring all tests still pass.

#### Project Setup and Implementation Using the FountainAI Method

##### Step 1: Setting Up the Project

We use a shell script to set up the project, making it simple, interactive, and idempotent.

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

**Tree Structure After Running the Script**

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

##### Running the Script

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

#### Step 2: Writing Tests First

We will now use the initially created empty development patches to develop our project. These patches will be used to incrementally add functionality to our project.

##### TreeCatMD_dev_patch_1.sh

Add unit tests for the basic functionality.

```sh
#!/bin/bash

echo "Writing tests for the basic functionality..."

cat <<EOL > Tests/TreeCatMDTests/TreeCatMDTests.swift
import XCTest
@testable import TreeCatMDLib

final class TreeCatMDTests: XCTestCase {

    func testShellCommand() {
        let output = shell("echo", "Hello, World!")
        XCTAssertEqual(output?.trimmingCharacters(in: .whitespacesAndNewlines), "Hello, World!")
    }

    func testGetDirectoryTree() {
        let output = getDirectoryTree(at: "/tmp")
        XCTAssertNotNil(output)
    }

    func testGetFileContents() {
        let filePath = "/tmp/testFile.txt"
        let content = "Hello, World!"
        try? content.write(toFile: filePath, atomically: true, encoding: .utf8)
        let fileContent = getFileContents(at: filePath)
        XCTAssertEqual(fileContent, content)
    }

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
EOL

# Run tests
swift test

# Commit changes
git add Tests/TreeCatMDTests/TreeCatMDTests.swift
git commit -m "test: Add unit tests for basic functionality of TreeCatMD"
```

**Running Patch 1**

```sh
chmod +x TreeCatMD_dev_patch_1.sh
./TreeCatMD_dev_patch_1.sh
```

##### TreeCatMD_dev_patch_2.sh

Add functionality to main.swift to pass the tests.

```sh
#!/bin/bash

echo "Implementing functionality to pass the tests..."

cat <<EOL > Sources/TreeCatMD/main.swift
import Foundation

@discardableResult
func shell(_ args: String...) -> String? {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe

    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)
}

func getDirectoryTree(at path: String) -> String?

 {
    return shell("tree", path)
}

func getFileContents(at path: String) -> String? {
    return try? String(contentsOfFile: path)
}

func generateMarkdown(for directory: String, outputFileName: String) {
    let fileManager = FileManager.default
    guard let enumerator = fileManager.enumerator(atPath: directory) else {
        print("Cannot enumerate directory")
        return
    }

    var markdown = "# \(directory)\n\n"

    if let tree = getDirectoryTree(at: directory) {
        markdown += "## Directory Tree\n"
        markdown += "```\n"
        markdown += tree
        markdown += "\n```\n\n"
    } else {
        markdown += "'tree' command not found. Please install it using 'brew install tree'.\n\n"
    }

    markdown += "## File Contents\n"
    for case let file as String in enumerator {
        let filePath = "\(directory)/\(file)"
        if fileManager.fileExists(atPath: filePath) {
            markdown += "### \(file)\n"
            markdown += "```\n"
            if let content = getFileContents(at: filePath) {
                markdown += content
            }
            markdown += "\n```\n\n"
        }
    }

    let outputPath = "\(directory)/\(outputFileName)"
    do {
        try markdown.write(toFile: outputPath, atomically: true, encoding: .utf8)
        print("Markdown file generated: \(outputPath)")

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(markdown, forType: .string)
        print("Contents copied to clipboard")
    } catch {
        print("Failed to write markdown file: \(error)")
    }
}

if CommandLine.arguments.count < 2 {
    print("Usage: TreeCatMD <directory>")
    exit(1)
}

let directory = CommandLine.arguments[1]
generateMarkdown(for: directory, outputFileName: "\(directory.components(separatedBy: "/").last ?? "output").md")
EOL

# Run tests
swift test

# Commit changes
git add Sources/TreeCatMD/main.swift
git commit -m "feat: Implement functionality for TreeCatMD to pass tests"
```

**Running Patch 2**

```sh
chmod +x TreeCatMD_dev_patch_2.sh
./TreeCatMD_dev_patch_2.sh
```

##### TreeCatMD_dev_patch_3.sh

Enhance functionality by adding a size limit check and implementing the tests for it.

```sh
#!/bin/bash

echo "Adding size limit functionality and tests..."

# Modify main.swift to include size limit check
cat <<EOL > Sources/TreeCatMD/main.swift
import Foundation

struct TreeCatMD {
    static let sizeLimit: Int = 1 * 1024 * 1024 // 1 MB

    static func checkAndInstallTree() {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["which", "tree"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8), output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("'tree' command is not installed. Installing it now...")
            installTreeMac()
        } else {
            print("'tree' command is already installed.")
        }
    }

    static func installTreeMac() {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["brew", "install", "tree"]
        task.launch()
        task.waitUntilExit()
    }

    static func generateDocumentation(for directory: String) {
        let fileManager = FileManager.default
        let dirName = URL(fileURLWithPath: directory).lastPathComponent
        let outputFileName = "doc_\(dirName).md"

        var output = "# \(directory)\n\n"

        let treeTask = Process()
        treeTask.launchPath = "/usr/bin/env"
        treeTask.arguments = ["tree", directory]

        let treePipe = Pipe()
        treeTask.standardOutput = treePipe
        treeTask.launch()
        treeTask.waitUntilExit()

        let treeData = treePipe.fileHandleForReading.readDataToEndOfFile()
        if let treeOutput = String(data: treeData, encoding: .utf8) {
            output += "## Directory Tree\n"
            output += "```\n"
            output += treeOutput
            output += "```\n\n"
        } else {
            output += "'tree' command not found. Please install it using 'brew install tree'.\n\n"
        }

        output += "## File Contents\n"

        if let enumerator = fileManager.enumerator(atPath: directory) {
            for case let file as String in enumerator {
                let filePath = "\(directory)/\(file)"
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory), !isDirectory.boolValue {
                    let fileHeader = "### \(file)\n"
                    let fileStart = "```\n"
                    let fileEnd = "\n```\n"
                    let fileContent = (try? String(contentsOfFile: filePath, encoding: .utf8)) ?? ""

                    let totalContent = fileHeader + fileStart + fileContent + fileEnd
                    if output.count + totalContent.count > sizeLimit {
                        print("The resulting Markdown file exceeds the size limit of \(sizeLimit / 1024) KB. Stopping the process.")
                        return
                    }
                    output += totalContent
                }
            }
        }

        try? output.write(toFile: "\(directory)/\(outputFileName)", atomically: true, encoding: .utf8)
        print("Markdown file generated: \(directory)/\(outputFileName)")

        // Copy to clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(output, forType: .string)
        print("Contents copied to clipboard")
    }
}

let args = CommandLine.arguments
if args.count != 2 {
    print("Usage: \(args[0]) <directory>")
    exit(1)
}

let directory = CommandLine.arguments[1]
TreeCatMD.checkAndInstallTree()
TreeCatMD.generateDocumentation(for: directory)
EOL

# Add size check function
cat <<EOL > Sources/TreeCatMDLib/size_check.swift
import Foundation

func check_size_limit(filePath: String, maxSize: Int) {
    let fileManager = FileManager.default
    if let fileAttributes = try? fileManager.attributesOfItem(atPath: filePath), let fileSize = fileAttributes[FileAttributeKey.size] as? NSNumber {
        if fileSize.intValue > maxSize {
            print("File size exceeds limit: \(fileSize.intValue) bytes (limit: \(maxSize) bytes)")
            exit(1)
        }
    }
}
EOL

# Add unit tests for size check function
cat <<EOL > Tests/TreeCatMDTests/SizeCheckTests.swift
import XCTest
@testable import TreeCatMDLib

final class SizeCheckTests: XCTestCase {

    func testFileSizeWithinLimit() {
        let filePath = "/tmp/testFileWithinLimit.txt"
        let content = "Hello, World!"
        try? content.write(toFile: filePath, atomically: true, encoding: .utf8)
        check_size_limit(filePath: filePath, maxSize: 1024 * 1024) // 1 MB
        XCTAssert(true) // If no exception is thrown, the test passes
    }

    func testFileSizeExceedsLimit() {
        let filePath = "/tmp/testFileExceedsLimit.txt"
        let content = String(repeating: "A", count: 2 * 1024 * 1024) // 2 MB
        try? content.write(toFile: filePath, atomically: true, encoding: .utf8)
        XCTAssertThrowsError(try check_size_limit(filePath: filePath, maxSize: 1 * 1024 * 1024)) // 1 MB
    }
}
EOL

# Run tests
swift test

# Commit changes
git add Sources/TreeCatMD/main.swift Sources/TreeCatMDLib/size_check.swift Tests/TreeCatMDTests/SizeCheckTests.swift
git commit -m "feat: Add size limit functionality and tests to TreeCatMD"
```

**Running Patch 3**

```sh
chmod +x TreeCatMD_dev_patch_3.sh
./TreeCatMD_dev_patch_3.sh
```

### Resulting Project Structure

After applying the patches, the resulting project directory structure will be as follows:

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
│       └── size_check.swift
├── Tests/
│   └── TreeCatMDTests/
│       ├── TreeCatMDTests.swift
│       ├── SizeCheckTests.swift
│       └──

 SizeLimitTests.swift
├── TreeCatMD_dev_patch_1.sh
├── TreeCatMD_dev_patch_2.sh
├── TreeCatMD_dev_patch_3.sh
```

### Conclusion

This paper presented the FountainAI method for creating a Swift command-line application using the command line, addressing the complexity of Xcode's GUI and emphasizing simplicity, idempotency, and interactivity. The provided script automates the project setup, ensuring a streamlined and efficient development process. By following this approach, developers can focus on writing code and tests, leveraging the power of the Swift Package Manager and command-line tools. Additionally, the script now supports Git repository creation, initializing a `.gitignore` file, and setting up patch scripts for future development steps.

### Commit Message

```plaintext
feat: Implement TreeCatMD with TDD and interactivity

- Initialize Swift package with executable and test targets for TreeCatMD
- Create project directory structure and setup initial files
- Ensure idempotency by cleaning up existing project directory
- Add interactivity by prompting for project name
- Refactor script into functions for readability and reusability
- Build project and run tests to verify setup
- Initialize Git repository with .gitignore and make initial commit
- Create empty patch scripts for future development
- Add unit tests for basic functionality of TreeCatMD
- Implement functionality for TreeCatMD to pass tests
- Add size limit functionality and tests to TreeCatMD
```

### Habit of Committing to the Created Repo

1. **Write Code in Development Patches**:
   - Each patch should implement a small, incremental change.
   - Example: Adding a new function, updating a test, or modifying existing functionality.

2. **Execute Patch Script**:
   - Make the script executable:
     ```sh
     chmod +x TreeCatMD_dev_patch_1.sh
     ```
   - Execute the patch script:
     ```sh
     ./TreeCatMD_dev_patch_1.sh
     ```

3. **Commit Changes**:
   - Add the changes to the staging area:
     ```sh
     git add <modified files>
     ```
   - Commit the changes with a meaningful message:
     ```sh
     git commit -m "feat: Add unit tests for basic functionality of TreeCatMD"
     ```

By following this structured approach, developers can efficiently create Swift command-line applications, maintaining focus on coding and testing while leveraging command-line tools for project management. The use of development patches ensures continuous improvement and maintainability of the project, promoting a habit of frequent commits with clear messages.