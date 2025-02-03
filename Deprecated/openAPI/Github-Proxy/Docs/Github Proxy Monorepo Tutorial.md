# Github Proxy Monorepo Tutorial

## Project Name
`GithubProxyMonorepo`

---

## Directory Structure
```plaintext
GithubProxyMonorepo/
├── Package.swift
├── Sources/
│   ├── Actions/
│   │   ├── Server.swift
│   │   ├── Types.swift
│   │   └── README.md
│   ├── Branches/
│   │   ├── Server.swift
│   │   ├── Types.swift
│   │   └── README.md
│   ├── Commits/
│   │   ├── Server.swift
│   │   ├── Types.swift
│   │   └── README.md
│   ├── Issues/
│   │   ├── Server.swift
│   │   ├── Types.swift
│   │   └── README.md
│   ├── Labels/
│   │   ├── Server.swift
│   │   ├── Types.swift
│   │   └── README.md
│   ├── Milestones/
│   │   ├── Server.swift
│   │   ├── Types.swift
│   │   └── README.md
│   └── RepoCM/
│       ├── Server.swift
│       ├── Types.swift
│       └── README.md
├── Tests/
│   ├── ActionsTests/
│   │   ├── ActionsTests.swift
│   │   └── README.md
│   ├── BranchesTests/
│   │   ├── BranchesTests.swift
│   │   └── README.md
│   ├── CommitsTests/
│   │   ├── CommitsTests.swift
│   │   └── README.md
│   ├── IssuesTests/
│   │   ├── IssuesTests.swift
│   │   └── README.md
│   ├── LabelsTests/
│   │   ├── LabelsTests.swift
│   │   └── README.md
│   ├── MilestonesTests/
│   │   ├── MilestonesTests.swift
│   │   └── README.md
│   └── RepoCMTests/
│       ├── RepoCMTests.swift
│       └── README.md
└── README.md
```

---

## Complete `Package.swift` File

```swift
// Package.swift
import PackageDescription

let package = Package(
    name: "GithubProxyMonorepo",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "Actions", targets: ["Actions"]),
        .library(name: "Branches", targets: ["Branches"]),
        .library(name: "Commits", targets: ["Commits"]),
        .library(name: "Issues", targets: ["Issues"]),
        .library(name: "Labels", targets: ["Labels"]),
        .library(name: "Milestones", targets: ["Milestones"]),
        .library(name: "RepoCM", targets: ["RepoCM"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Actions",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ],
            path: "Sources/Actions"
        ),
        .target(
            name: "Branches",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ],
            path: "Sources/Branches"
        ),
        .target(
            name: "Commits",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ],
            path: "Sources/Commits"
        ),
        .target(
            name: "Issues",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ],
            path: "Sources/Issues"
        ),
        .target(
            name: "Labels",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ],
            path: "Sources/Labels"
        ),
        .target(
            name: "Milestones",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ],
            path: "Sources/Milestones"
        ),
        .target(
            name: "RepoCM",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ],
            path: "Sources/RepoCM"
        ),
        .testTarget(
            name: "ActionsTests",
            dependencies: ["Actions"],
            path: "Tests/ActionsTests"
        ),
        .testTarget(
            name: "BranchesTests",
            dependencies: ["Branches"],
            path: "Tests/BranchesTests"
        ),
        .testTarget(
            name: "CommitsTests",
            dependencies: ["Commits"],
            path: "Tests/CommitsTests"
        ),
        .testTarget(
            name: "IssuesTests",
            dependencies: ["Issues"],
            path: "Tests/IssuesTests"
        ),
        .testTarget(
            name: "LabelsTests",
            dependencies: ["Labels"],
            path: "Tests/LabelsTests"
        ),
        .testTarget(
            name: "MilestonesTests",
            dependencies: ["Milestones"],
            path: "Tests/MilestonesTests"
        ),
        .testTarget(
            name: "RepoCMTests",
            dependencies: ["RepoCM"],
            path: "Tests/RepoCMTests"
        )
    ]
)
```

---

## Tutorial: Creating the Monorepo from Scratch

### Step 1: Set Up the Monorepo Structure
Create the directory structure for the monorepo:
```bash
mkdir GithubProxyMonorepo
cd GithubProxyMonorepo
mkdir Sources Tests
```

Create subdirectories for each service under `Sources/`:
```bash
mkdir -p Sources/Actions Sources/Branches Sources/Commits Sources/Issues Sources/Labels Sources/Milestones Sources/RepoCM
```

Create subdirectories for test targets under `Tests/`:
```bash
mkdir -p Tests/ActionsTests Tests/BranchesTests Tests/CommitsTests Tests/IssuesTests Tests/LabelsTests Tests/MilestonesTests Tests/RepoCMTests
```

### Step 2: Add Generated Files
Copy the generated `Server.swift` and `Types.swift` files into the appropriate service directories under `Sources/`.

For example:
- `Server.swift` and `Types.swift` for Actions go into `Sources/Actions/`.
- `Server.swift` and `Types.swift` for Branches go into `Sources/Branches/`.

Repeat this for all services.

### Step 3: Create the `Package.swift` File
Create the `Package.swift` file in the root of the monorepo with the content provided above.

### Step 4: Add Tests
Create a test file for each service in the `Tests/` directory. For example:

**`Tests/ActionsTests/ActionsTests.swift`**:
```swift
import XCTest
@testable import Actions

final class ActionsTests: XCTestCase {
    func testExample() throws {
        XCTAssert(true)
    }
}
```

Repeat for all other services (`BranchesTests`, `CommitsTests`, etc.).

### Step 5: Initialize a Git Repository
Initialize a Git repository and make your initial commit:
```bash
git init
git add .
git commit -m "Initial commit of Github Proxy Monorepo"
```

### Step 6: Push to GitHub
Create a new repository on GitHub (e.g., `GithubProxyMonorepo`) and push your code:
```bash
git branch -M main
git remote add origin https://github.com/your-org/GithubProxyMonorepo.git
git push -u origin main
```

### Step 7: Use the Monorepo in Your Vapor App
Add the monorepo as a dependency in your Vapor app’s `Package.swift` file:
```swift
.package(url: "https://github.com/your-org/GithubProxyMonorepo.git", from: "1.0.0")
```

Import and use specific services as needed:
```swift
import Actions
import Branches
```

Configure the app to use your handlers:
```swift
func configure(_ app: Application) throws {
    let actionsHandler = MyActionsHandler() // Conforms to APIProtocol from Actions
    try app.registerHandlers(handler: actionsHandler)
}
```

