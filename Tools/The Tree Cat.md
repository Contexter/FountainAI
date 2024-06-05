# Project Paper: Directory Tree and File Content Generation with Swift

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

## Test-Driven Development (TDD) Approach

Test-Driven Development (TDD) is a software development process where tests are written before the actual functionality. The process involves the following steps:
1. **Write a test** for the next bit of functionality.
2. **Run the test** to ensure it fails (since the functionality is not yet implemented).
3. **Implement the functionality** to make the test pass.
4. **Refactor the code**, ensuring all tests still pass.

## Project Setup and Implementation

### Step 1: Setting Up the Project

1. **Open Xcode** and create a new project:
   - Select `File` > `New` > `Project`.
   - Choose `macOS` > `Command Line Tool`.
   - Name the project `TreeCatMD`.

2. **Install `tree` Command**:
   - Ensure the `tree` command is installed using Homebrew:
     ```sh
     brew install tree
     ```

### Step 2: Writing Tests First

1. **Create a Test Target**:
   - In Xcode, add a new target by selecting `File` > `New` > `Target`.
   - Choose `macOS` > `Unit Testing Bundle`.
   - Name the test target `TreeCatMDTests`.

2. **Write Tests**:
   In the `TreeCatMDTests` folder, create tests for the functionality:

   ```swift
   import XCTest
   @testable import TreeCatMD

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
   ```

### Step 3: Implementing Functionality

Implement the functions in `main.swift` to make the tests pass:

1. **main.swift**:

   ```swift
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

   let directory = args[1]
   TreeCatMD.checkAndInstallTree()
   TreeCatMD.generateDocumentation(for: directory)
   ```

### Step 4: Running Tests

1. **Run the Tests**:
   - In Xcode, select `Product` > `Test` or press `Cmd + U`.
   - Ensure all tests pass before proceeding.

### Step 5: Building and Deploying the Command-Line Tool

1. **Build the Project**:
   - Select `Product` > `Build`.

2. **Copy the Executable**:
   - Navigate to the Products directory in Xcode, right-click on `TreeCatMD`, and select `Show in Finder`.
   - Copy the `TreeCatMD` executable to `/usr/local/bin`:
     ```sh
     cp /path/to/TreeCatMD /usr/local/bin
     ```

### Step 6: Integrating with Automator

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
   - Go to `File` > `Save

`.
   - Name it something like "Generate Markdown from Folder".

### Step 7: Demonstration

1. **Right-Click on a Folder**:
   - In Finder, right-click on the folder you want to process.
   - Select `Quick Actions` > `Generate Markdown from Folder`.

2. **Paste the Markdown**:
   - The script will run, generate the Markdown file, and copy its contents to the clipboard.
   - Open your Markdown editor or chat interface and paste the content.

This setup provides a comprehensive, TDD-based approach to creating a Swift command-line tool that generates a Markdown document with directory tree and file contents, integrated with Automator for easy use. Additionally, it incorporates a size limit check to ensure the generated Markdown file remains within manageable limits, providing user feedback if the limit is exceeded.

### Commit Message

```
feat: Add project paper for Swift-based directory tree and file content generation tool

- Introduce project goals and implementation path
- Describe use case and environment for the tool
- Emphasize Test-Driven Development (TDD) approach
- Provide a detailed, tutorialized project setup
- Implement tests first, followed by functionality
- Include a Swift script for generating a Markdown file from directory contents
- Explain integration with Automator Quick Actions on macOS
- Demonstrate proper functioning of the tool with usage examples
- Add size limit feature to ensure Markdown files remain manageable

This commit adds comprehensive documentation to guide the development and integration of a Swift command-line tool for generating Markdown files from directory contents, enhancing user interactions with AI systems.
```