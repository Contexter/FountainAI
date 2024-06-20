#!/bin/bash

PROJECT_NAME="MusicSoundOrchestrationAPI"
SCRIPT_DIR="$PROJECT_NAME/scripts"

# Create project and script directories
mkdir -p $SCRIPT_DIR/controllers
mkdir -p $SCRIPT_DIR/tests

# Create the main shell script to generate, make executable, and run the individual scripts
cat <<'EOL' > $SCRIPT_DIR/run_all.sh
#!/bin/bash

# Run all setup scripts
for script in $(find $(dirname $0) -name '*.sh' ! -name 'run_all.sh'); do
    chmod +x $script
    $script
done
EOL

chmod +x $SCRIPT_DIR/run_all.sh

# Create individual setup scripts

# Package.swift creation script
cat <<'EOL' > $SCRIPT_DIR/create_package.sh
#!/bin/bash

PROJECT_NAME="MusicSoundOrchestrationAPI"
FILE="$PROJECT_NAME/Package.swift"

if [ ! -f "$FILE" ]; then
    # Create Package.swift
    cat <<EOL > $FILE
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MusicSoundOrchestrationAPI",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "MusicSoundOrchestrationAPI", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/orchetect/MIDIKit.git", from: "0.9.6"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "MIDIKit", package: "MIDIKit"),
            ],
            path: "Sources/App"
        ),
        .target(
            name: "Run",
            dependencies: [.target(name: "App")],
            path: "Sources/Run"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/AppTests"
        ),
    ]
)
EOL
    echo "Created $FILE"
else
    echo "$FILE already exists. Skipping creation."
fi
EOL

# main.swift creation script
cat <<'EOL' > $SCRIPT_DIR/create_main.sh
#!/bin/bash

PROJECT_NAME="MusicSoundOrchestrationAPI"
FILE="$PROJECT_NAME/Sources/Run/main.swift"

if [ ! -f "$FILE" ]; then
    # Create main.swift
    mkdir -p $(dirname $FILE)
    cat <<EOL > $FILE
import App
import Vapor

var env = try Environment.detect()
let app = Application(env)
try configure(app)
defer { app.shutdown() }
try app.run()
EOL
    echo "Created $FILE"
else
    echo "$FILE already exists. Skipping creation."
fi
EOL

# app.swift and routes.swift creation script
cat <<'EOL' > $SCRIPT_DIR/create_app.sh
#!/bin/bash

PROJECT_NAME="MusicSoundOrchestrationAPI"
FILE_APP="$PROJECT_NAME/Sources/App/app.swift"
FILE_ROUTES="$PROJECT_NAME/Sources/App/routes.swift"

if [ ! -f "$FILE_APP" ]; then
    # Create app.swift
    mkdir -p $(dirname $FILE_APP)
    cat <<EOL > $FILE_APP
import Vapor

public func configure(_ app: Application) throws {
    // Register routes
    try routes(app)
}
EOL
    echo "Created $FILE_APP"
else
    echo "$FILE_APP already exists. Skipping creation."
fi

if [ ! -f "$FILE_ROUTES" ]; then
    # Create routes.swift
    cat <<EOL > $FILE_ROUTES
import Vapor

public func routes(_ app: Application) throws {
    app.post("generate_csound_file", use: generateCsoundFile)
    app.post("generate_lilypond_file", use: generateLilyPondFile)
    app.post("generate_midi_file", use: generateMIDIFile)
    app.post("commit_file", use: commitFile)
    app.post("push_to_github", use: pushToGitHub)
    app.get("list_files", use: listFiles)
    app.get("get_file_content", use: getFileContent)
    app.get("get_file_history", use: getFileHistory)
}
EOL
    echo "Created $FILE_ROUTES"
else
    echo "$FILE_ROUTES already exists. Skipping creation."
fi
EOL

# GitUtils.swift creation script
cat <<'EOL' > $SCRIPT_DIR/create_git_utils.sh
#!/bin/bash

PROJECT_NAME="MusicSoundOrchestrationAPI"
FILE="$PROJECT_NAME/Sources/App/Utilities/GitUtils.swift"

if [ ! -f "$FILE" ]; then
    # Create GitUtils.swift
    mkdir -p $(dirname $FILE)
    cat <<EOL > $FILE
import Vapor

func shell(_ command: String) throws -> String {
    let process = Process()
    let pipe = Pipe()

    process.standardOutput = pipe
    process.standardError = pipe
    process.arguments = ["-c", command]
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    try process.run()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
}

func gitAddAndCommit(filePath: String, message: String, on req: Request) -> EventLoopFuture<String> {
    return req.eventLoop.future().flatMapThrowing {
        let repoPath = "output"
        if !FileManager.default.fileExists(atPath: "\(repoPath)/.git") {
            try shell("git -C \(repoPath) init")
            try shell("git -C \(repoPath) config user.name \"VaporApp\"")
            try shell("git -C \(repoPath) config user.email \"vapor@app.local\"")
        }
        try shell("git -C \(repoPath) add \(filePath)")
        try shell("git -C \(repoPath) commit -m \"\(message)\"")
        return "Committed \(filePath) with message: \(message)"
    }
}

func gitPush(remote: String, branch: String, on req: Request) -> EventLoopFuture<String> {
    return req.eventLoop.future().flatMapThrowing {
        let repoPath = "output"
        let result = try shell("git -C \(repoPath) push \(remote) \(branch)")
        return "Pushed to \(remote) \(branch): \(result)"
    }
}

extension Array where Element == String {
    func jsonEncodedString() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return String(data: data, encoding: .utf8) ?? "[]"
    }
}
EOL
    echo "Created $FILE"
else
    echo "$FILE already exists. Skipping creation."
fi
EOL

# Controller scripts
CONTROLLERS=(
    "generate_csound_file"
    "generate_lilypond_file"
    "generate_midi_file"
    "commit_file"
    "push_to_github"
    "list_files"
    "get_file_content"
    "get_file_history"
)

for controller in "${CONTROLLERS[@]}"; do
cat <<EOL > $SCRIPT_DIR/controllers/create_${controller}_controller.sh
#!/bin/bash

PROJECT_NAME="MusicSoundOrchestrationAPI"
FILE="\$PROJECT_NAME/Sources/App/Controllers/${controller^}Controller.swift"

if [ ! -f "\$FILE" ]; then
    # Create ${controller^}Controller.swift
    mkdir -p \$(dirname \$FILE)
    cat <<EOL > \$FILE
import Vapor

struct ${controller^}Params: Content {
    var param1: String
    var param2: String
}

func ${controller}(_ req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.content.decode(${controller^}Params.self)
    // Implement the functionality for ${controller}
    return req.eventLoop.makeSucceededFuture(Response(status: .ok))
}
EOL
    echo "Created \$FILE"
else
    echo "\$FILE already exists. Skipping creation."
fi
EOL
done

# Test scripts
TESTS=(
    "generate_csound_file"
    "generate_lilypond_file"
    "generate_midi_file"
    "commit_file"
    "push_to_github"
    "list_files"
    "get_file_content"
    "get_file_history"
)

for test in "${TESTS[@]}"; do
cat <<EOL > $SCRIPT_DIR/tests/create_${test}_tests.sh
#!/bin/bash

PROJECT_NAME="MusicSoundOrchestrationAPI"
FILE="\$PROJECT_NAME/Tests/AppTests/${test^}Tests.swift"

if [ ! -f "\$FILE" ]; then
    # Create ${test^}Tests.swift
    mkdir -p \$(dirname \$FILE)
    cat <<EOL > \$FILE
import XCTest
import Vapor
@testable import App

final class ${test^}Tests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func test${test^}() throws {
        // Implement the test for ${test}
    }
}
EOL
    echo "Created \$FILE"
else
    echo "\$FILE already exists. Skipping creation."
fi
EOL
done

# Dockerfile creation script
cat <<'EOL' > $SCRIPT_DIR/create_dockerfile.sh
#!/bin/bash

PROJECT_NAME="MusicSoundOrchestrationAPI"
FILE="$PROJECT_NAME/Dockerfile"

if [ ! -f "$FILE" ]; then
    # Create Dockerfile
    cat <<EOL > $FILE
# Use official Swift image
FROM swift:5.3.3

# Install Csound
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    nano \
    csound \
    git

# Install LilyPond
RUN wget http://lilypond.org/download/binaries/linux/lilypond-2.24.2-1.linux-64.sh \
    && chmod +x lilypond-2.24.2-1.linux-64.sh \
    && ./lilypond-2.24.2-1.linux-64.sh --batch --prefix=/usr/local

# Install Vapor and orchestration tools
RUN apt-get install -y libssl-dev libsqlite3-dev
RUN swift build && swift package resolve

# Set working directory and copy API files
WORKDIR /workspace
COPY . /workspace

# Start the Vapor server
CMD ["swift", "run"]
EOL
    echo "Created $FILE"
else
    echo "$FILE already exists. Skipping creation."
fi
EOL

# Run all setup scripts
$SCRIPT_DIR/run_all.sh
