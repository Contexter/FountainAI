> This document contains hardcoded file paths to my particual machine - which are quite easy to make out. Please change accordingly - and : Happy Chatting with the future **FounainAI**
# GenerateDoc Tool

## Overview

`GenerateDoc` is a command-line tool written in Swift that generates a markdown documentation file for a specified directory. The documentation includes a directory tree and the contents of all files within the directory, which is useful for situations like Chatting with a chat optimized GPT model or the like - :)

## Features

- **Directory Tree:** Generates a visual tree of the directory structure.
- **File Contents:** Includes the contents of each file in the directory in the generated documentation.

## Usage

```sh
GenerateDoc <directory>
```

- `<directory>`: The path to the directory you want to document.

## Requirements

- Swift installed on your Mac.
- `tree` command installed (the script will check for it and install if necessary).

## Script

Below is the script used to create and compile the `GenerateDoc` tool:

### `create_GenerateDoc_swift_cmd_tool.sh`

```sh
#!/bin/bash

set -e

PROJECT_NAME="GenerateDoc"

# Function to create a new Swift package
create_swift_package() {
    if [ ! -d "$PROJECT_NAME" ]; then
        echo "Creating Swift package..."
        mkdir -p "$PROJECT_NAME/Sources/${PROJECT_NAME}"
        mkdir -p "$PROJECT_NAME/Tests/${PROJECT_NAME}Tests"
        cd "$PROJECT_NAME"
        swift package init --type executable
        cd ..
        echo "Created Swift package structure."
    else
        echo "Swift package already exists."
    fi
}

# Function to create main.swift
create_main_swift() {
    echo "Creating main.swift..."
    cat <<'EOL' > ${PROJECT_NAME}/Sources/${PROJECT_NAME}/main.swift
import Foundation

struct GenerateDoc {
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
            if ProcessInfo.processInfo.environment["OSTYPE"] == "darwin" {
                installTreeMac()
            } else {
                installTreeLinux()
            }
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
    
    static func installTreeLinux() {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["sudo", "apt-get", "install", "-y", "tree"]
        task.launch()
        task.waitUntilExit()
    }
    
    static func generateDocumentation(for directory: String) {
        let fileManager = FileManager.default
        let dirName = URL(fileURLWithPath: directory).lastPathComponent
        let outputFileName = "doc_\(dirName).md"
        
        var output = "# Directory Tree\n"
        output += "```\n"
        
        let treeTask = Process()
        treeTask.launchPath = "/usr/bin/env"
        treeTask.arguments = ["tree", directory]
        
        let treePipe = Pipe()
        treeTask.standardOutput = treePipe
        treeTask.launch()
        treeTask.waitUntilExit()
        
        let treeData = treePipe.fileHandleForReading.readDataToEndOfFile()
        if let treeOutput = String(data: treeData, encoding: .utf8) {
            output += treeOutput
        }
        
        output += "```\n\n# File Contents\n"
        
        if let enumerator = fileManager.enumerator(atPath: directory) {
            for case let file as String in enumerator {
                let filePath = "\(directory)/\(file)"
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory), !isDirectory.boolValue {
                    output += "## \(file)\n"
                    output += "```\n"
                    if let fileContent = try? String(contentsOfFile: filePath, encoding: .utf8) {
                        output += fileContent
                    }
                    output += "\n```\n"
                }
            }
        }
        
        try? output.write(toFile: "\(directory)/\(outputFileName)", atomically: true, encoding: .utf8)
    }
}

let args = CommandLine.arguments
if args.count != 2 {
    print("Usage: \(args[0]) <directory>")
    exit(1)
}

let directory = args[1]
GenerateDoc.checkAndInstallTree()
GenerateDoc.generateDocumentation(for: directory)
EOL
}

# Function to create Package.swift
create_package_swift() {
    echo "Creating Package.swift..."
    cat <<EOL > ${PROJECT_NAME}/Package.swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "$PROJECT_NAME",
    products: [
        .executable(name: "$PROJECT_NAME", targets: ["$PROJECT_NAME"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "$PROJECT_NAME",
            dependencies: []
        ),
        .testTarget(
            name: "${PROJECT_NAME}Tests",
            dependencies: ["$PROJECT_NAME"]),
    ]
)
EOL
}

# Function to create test directory
create_test_directory() {
    echo "Creating test directory structure..."
    mkdir -p test_directory/Tests/AppTests
    mkdir -p test_directory/Sources/App/Models
    mkdir -p test_directory/Sources/App/Controllers
    mkdir -p test_directory/Sources/Run

    echo "print(\"Hello, Tests!\")" > test_directory/Tests/AppTests/AppTests.swift
    echo "print(\"Hello, Models!\")" > test_directory/Sources/App/Models/Model.swift
    echo "print(\"Hello, Controllers!\")" > test_directory/Sources/App/Controllers/Controller.swift
    echo "print(\"Hello, Run!\")" > test_directory/Sources/Run/main.swift
}

# Function to run the test
run_test() {
    echo "Running test..."
    cd $PROJECT_NAME
    swift run $PROJECT_NAME ../test_directory
    cd ..
    diff -q test_directory/doc_test_directory.md test_directory/doc_test_directory.md > /dev/null
    if [ $? -eq 0 ]; then
        echo "Test passed: Generated documentation matches the reference."
    else
        echo "Test failed: Generated documentation does not match the reference."
    fi
}

# Main script execution
create_swift_package
create_main_swift
create_package_swift

# Build the project
cd $PROJECT_NAME
swift build
cd ..

create_test_directory
run_test
```

### Usage

1. **Run the Script:**

   ```sh
   ./create_GenerateDoc_swift_cmd_tool.sh
   ```

   This script will:
   - Create a Swift package.
   - Populate the package with the main Swift file (`main.swift`).
   - Generate the necessary `Package.swift`.
   - Build the project.
   - Create a test directory structure and run a test to ensure the tool works as expected.

2. **Install the Tool:**

   After running the script, manually copy the built executable to a location in your `PATH`.

   ```sh
   sudo cp /path/to/GenerateDoc/.build/release/GenerateDoc /usr/local/bin/
   sudo chmod +x /usr/local/bin/GenerateDoc
   ```

3. **Verify Installation:**

   ```sh
   GenerateDoc --help
   ```

   This should show the usage instructions if the tool is installed correctly.

## Manual Installation Tutorial

To manually install the `GenerateDoc` tool:

1. **Locate the Executable:**
   Navigate to `/Users/benedikteickhoff/playground/ToolCreation/GenerateDoc/.build/arm64-apple-macosx/release/` in Finder and verify that the `GenerateDoc` executable is present.

2. **Open a Terminal window:**
   Open the Terminal application on your Mac.

3. **Copy the Executable to `/usr/local/bin`:**

   ```sh
   sudo cp /Users/benedikteickhoff/playground/ToolCreation/GenerateDoc/.build/arm64-apple-macosx/release/GenerateDoc /usr/local/bin/
   ```

4. **Set the Appropriate Permissions:**

   ```sh
   sudo chmod +x /usr/local/bin/GenerateDoc
   ```

5. **Verify the Installation:**

   ```sh
   GenerateDoc --help
   ```

   If the tool is installed correctly, this command should show the usage instructions.

## Commit Message

```
feat: Add GenerateDoc Swift command-line tool with installation script

- Created Swift package for GenerateDoc tool.
- Added functionality to generate directory tree and file contents documentation.
- Included installation script for manual installation on Mac.
- Verified and tested tool with a sample directory structure.

This tool allows users to generate markdown documentation for any specified directory, enhancing project documentation efforts.
```