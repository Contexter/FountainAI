# Creating and Testing a Command Line Tool in Xcode

This tutorial will guide you through the steps to create a Command Line Tool in Xcode and set up a unit test for it.

## Prerequisites

- Xcode installed on your Mac.
- Basic knowledge of Swift programming.

## Step-by-Step Guide

### 1. Create the Command Line Tool Project

1. Open Xcode.
2. Select `File > New > Project`.
3. Choose the `Command Line Tool` template under the `macOS` tab and click `Next`.
4. Enter the project name (e.g., `DocTool`), choose `Swift` as the language, and click `Next`.
5. Choose a location to save the project and click `Create`.

### 2. Create a Unit Test Target

1. In Xcode, go to the `File` menu and select `New > Target`.
2. Choose `macOS > Unit Testing Bundle` and click `Next`.
3. Name the test target (e.g., `DocToolTests`).
4. Leave the "Target to be Tested" as "None" if it doesn't allow you to select your main target and click `Finish`.

### 3. Configure the Test Target to Access the Main Target

1. In the Project Navigator, select the project file (e.g., `DocTool.xcodeproj`).
2. Select the `DocToolTests` target from the `TARGETS` list.
3. Go to the `Build Phases` tab.
4. Add the main target (`DocTool`) to the `Target Dependencies` by clicking the `+` button under `Target Dependencies`.

### 4. Modify the Test Case File

1. In the Project Navigator, find the `DocToolTests` folder.
2. Open the `DocToolTests.swift` file.
3. Modify it to include a basic test case:

```swift
import XCTest
@testable import DocTool

final class DocToolTests: XCTestCase {
    func testExample() {
        // Example test case
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
}
```

### 5. Ensure the Main Code is Accessible

In your `main.swift` (or other Swift files in the main target), make sure the code you want to test is in a module that can be accessed by the test target.

### Example `main.swift`

Here's a simple example of `main.swift` for a Command Line Tool:

```swift
import Foundation

func greet() -> String {
    return "Hello, World!"
}

print(greet())
```

### Update the Test Case to Test This Function

Modify `DocToolTests.swift` to test the `greet` function:

```swift
import XCTest
@testable import DocTool

final class DocToolTests: XCTestCase {
    func testGreet() {
        // Test the greet function
        XCTAssertEqual(greet(), "Hello, World!")
    }
}
```

### Running the Tests

1. **Select the Test Scheme:**
   - Select the test scheme (`DocToolTests`) from the scheme selector at the top of Xcode.

2. **Run the Tests:**
   - Click `Product > Test` (or press `Command-U`) to run the tests.

## Conclusion

By following these steps, you should be able to successfully add and run tests for your Command Line Tool in Xcode. This tutorial covered the creation of a Command Line Tool project, setting up a unit test target, and writing a basic test case. You can now extend this setup to include more complex functionality and corresponding tests as needed.