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

   func getDirectoryTree(at path: String) -> String? {
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
           markdown += tree
           markdown += "\n\n"
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
   let outputFileName = "\(directory.components(separatedBy: "/").last ?? "output").md"
   generateMarkdown(for: directory, outputFileName: outputFileName)
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
   - Go to `File` > `Save`.
   - Name it something like "Generate Markdown from Folder".

### Step 7: Demonstration

1. **Right-Click on a Folder**:
   - In Finder, right-click on the folder you want to process.
   - Select `Quick Actions` > `Generate Markdown from Folder`.

2. **Paste the Markdown**:
   - The script will run, generate the Markdown file, and copy its contents to the clipboard.
   - Open your Markdown editor or chat interface and paste the content.

This setup provides a comprehensive, TDD-based approach to creating a Swift command-line tool that generates a Markdown document with directory tree and file contents, integrated with Automator for easy use.