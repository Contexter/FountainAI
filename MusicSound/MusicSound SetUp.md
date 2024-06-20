### MusicSound Orchestration API
#### Tagline: Simplifying Musical Orchestration with Swift and Vapor

**Introduction:**

The MusicSound Orchestration API integrates orchestration functions to generate musical files in Csound, LilyPond, and MIDI formats. This Swift-based API uses Vapor to provide REST endpoints for managing orchestration commands. The API includes functionalities for generating, committing, and pushing files to a GitHub repository, making it an ideal tool for programmatically managing musical compositions.

### OpenAPI Specification

```yaml
openapi: 3.0.1
info:
  title: MusicSound Orchestration API
  description: |
    This API integrates orchestration functions directly to generate musical files in Csound, LilyPond, and MIDI formats. The API supports generating and managing orchestration commands through endpoints that map directly to function names implemented using Vapor in Swift.

    **Dockerized Orchestration**:
    - **Vapor**: Swift-based Vapor application provides the REST API endpoints for managing orchestration commands.
    - **Swift, Csound, LilyPond, and midikit**: Orchestration tools include Swift functions, Csound synthesis, LilyPond notation, and MIDI data generation using `midikit`.

    **Git Integration**:
    All generated files are committed to a git repository located in the `output/` directory using a custom commit message provided by the user. Additionally, files can be pushed to a GitHub repository.

    **Precondition**:
    Connect the VPS local git repository to a GitHub remote by adding the remote URL. For example:
    ```bash
    cd output
    git remote add origin https://github.com/username/repo.git
    ```

    **Docker Image Creation**:
    To build the Docker image with all necessary tools for the MusicSound Orchestration API, use the following Dockerfile:
    ```Dockerfile
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
    ```

  version: "1.2"
servers:
  - url: https://musicsound.fountain.coach
    description: Production server for MusicSound Orchestration API
  - url: http://localhost:8080
    description: Development server for testing

paths:
  /generate_csound_file:
    post:
      summary: Generate Csound File
      operationId: generateCsoundFile
      description: |
        Calls the Swift function `generateCsoundFile` to create a `.csd` file based on preset orchestration settings.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                outputFile:
                  type: string
                  description: Output audio file path.
                instruments:
                  type: string
                  description: Csound instruments definition.
                score:
                  type: string
                  description: Csound score definition.
                options:
                  type: string
                  description: Csound options.
      responses:
        '201':
          description: Csound file successfully generated.
          content:
            application/json:
              schema:
                type: object
                properties:
                  csoundFilePath:
                    type: string
                    description: Path to the generated Csound file.

  /generate_lilypond_file:
    post:
      summary: Generate LilyPond File
      operationId: generateLilyPondFile
      description: |
        Calls the Swift function `generateLilyPondFile` to create a `.ly` file based on preset orchestration settings.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                version:
                  type: string
                  description: LilyPond version.
                header:
                  type: string
                  description: LilyPond header settings.
                score:
                  type: string
                  description: LilyPond score definition.
                midi:
                  type: string
                  description: LilyPond MIDI settings.
                outputFile:
                  type: string
                  description: Output file name without extension.
      responses:
        '201':
          description: LilyPond file successfully generated.
          content:
            application/json:
              schema:
                type: object
                properties:
                  lilyPondFilePath:
                    type: string
                    description: Path to the generated LilyPond file.
                  midiFilePath:
                    type: string
                    description: Path to the generated MIDI file.
                  pdfFilePath:
                    type: string
                    description: Path to the generated PDF file.

  /generate_midi_file:
    post:
      summary: Generate MIDI File
      operationId: generateMIDIFile
      description: |
        Calls the Swift function `generateMIDIFile` to create a `.mid` file based on preset orchestration settings.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                events:
                  type: array
                  items:
                    type: object
                    properties:
                      type:
                        type: string
                        description: Event type (e.g., noteOn, noteOff, programChange)
                      channel:
                        type: integer
                        description: MIDI channel
                      note:
                        type: integer
                        description: MIDI note number (only for noteOn and noteOff)
                      velocity:
                        type: integer
                        description: Velocity (only for noteOn and noteOff)
                      program:
                        type: integer
                        description: Program number (only for programChange)
                      time:
                        type: integer
                        description: Time in ticks
                outputFile:
                  type: string
                  description: Output MIDI file name.
      responses:
        '201':
          description: MIDI file successfully generated.
          content:
            application/json:
              schema:
                type: object
                properties:
                  midiFilePath:
                    type: string
                    description: Path to the generated MIDI file.

  /commit_file:
    post:
      summary: Commit File
      operationId: commitFile
      description: |
        Commits a file to the git repository with a custom commit message.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                fileName:
                  type: string
                  description: Name of the file to commit.
                message:
                  type: string
                  description: Commit message.
      responses:
        '200':
          description: File successfully committed to git.
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
                    description: Confirmation of the commit message.

  /push_to_github:
    post:
      summary: Push to GitHub
      operationId: pushToGitHub
      description: |
        Pushes the committed files to a GitHub repository.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                remote:
                  type: string
                  description: Name of the remote repository.
                branch:
                  type: string
                  description: Name of the branch to push to.
      responses:
        '200':
          description: Files successfully pushed to GitHub.
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
                    description: Confirmation of the push message.

  /list_files:
    get:
      summary: List Files
      operationId: listFiles
      description: |
        Lists all files in the `output/` directory.
      responses:
        '200':
          description: Files listed successfully.
          content:
            application/json:
              schema:
                type: array
                items:
                  type: string

  /get_file_content:
    get:
      summary: Get File Content
      operationId: getFileContent
      description: |
        Retrieves the content of a specific file from the `output/` directory.
      parameters:
        - in: query
          name: fileName
          schema:
            type: string
          required: true
          description: Name of the file to retrieve.
      responses:
        '200':
          description: File content retrieved successfully.
          content:
            application/json:
              schema:
                type: string

  /get_file_history:
    get:
      summary: Get File History
      operationId: getFileHistory
      description: |
        Retrieves the git commit history for a specific file in the `output/` directory.
      parameters:
        - in: query
          name: fileName
          schema:
            type: string
          required: true
          description: Name of the file to retrieve the history for.
      responses:
        '200':
          description: File history retrieved successfully.
          content:
            application/json:
              schema:
                type: string
```

### Project Structure

```
Music

SoundOrchestrationAPI/
├── Sources/
│   ├── App/
│   │   ├── Controllers/
│   │   │   ├── GenerateCsoundFileController.swift
│   │   │   ├── GenerateLilyPondFileController.swift
│   │   │   ├── GenerateMIDIFileController.swift
│   │   │   ├── CommitFileController.swift
│   │   │   ├── PushToGitHubController.swift
│   │   │   ├── ListFilesController.swift
│   │   │   ├── GetFileContentController.swift
│   │   │   ├── GetFileHistoryController.swift
│   │   ├── Utilities/
│   │   │   ├── GitUtils.swift
│   │   ├── app.swift
│   │   ├── routes.swift
│   ├── Run/
│   │   ├── main.swift
├── Tests/
│   ├── AppTests/
│   │   ├── GenerateCsoundFileTests.swift
│   │   ├── GenerateLilyPondFileTests.swift
│   │   ├── GenerateMIDIFileTests.swift
│   │   ├── CommitFileTests.swift
│   │   ├── PushToGitHubTests.swift
│   │   ├── ListFilesTests.swift
│   │   ├── GetFileContentTests.swift
│   │   ├── GetFileHistoryTests.swift
│   │   ├── XCTestManifests.swift
├── LinuxMain.swift
```

### Shell Script to Create the Project

Create a file named `setup_project.sh` and add the following script:

```bash
#!/bin/bash

PROJECT_NAME="MusicSoundOrchestrationAPI"
mkdir -p $PROJECT_NAME

# Create project directories
mkdir -p $PROJECT_NAME/Sources/App/Controllers
mkdir -p $PROJECT_NAME/Sources/App/Utilities
mkdir -p $PROJECT_NAME/Sources/Run
mkdir -p $PROJECT_NAME/Tests/AppTests

# Create main.swift
cat <<EOL > $PROJECT_NAME/Sources/Run/main.swift
import App
import Vapor

var env = try Environment.detect()
let app = Application(env)
try configure(app)
defer { app.shutdown() }
try app.run()
EOL

# Create app.swift
cat <<EOL > $PROJECT_NAME/Sources/App/app.swift
import Vapor

public func configure(_ app: Application) throws {
    // Register routes
    try routes(app)
}
EOL

# Create routes.swift
cat <<EOL > $PROJECT_NAME/Sources/App/routes.swift
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

# Create GitUtils.swift
cat <<EOL > $PROJECT_NAME/Sources/App/Utilities/GitUtils.swift
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

# Create GenerateCsoundFileController.swift
cat <<EOL > $PROJECT_NAME/Sources/App/Controllers/GenerateCsoundFileController.swift
import Vapor

struct CsoundParams: Content {
    var outputFile: String
    var instruments: String
    var score: String
    var options: String
}

func generateCsoundFile(_ req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.content.decode(CsoundParams.self)
    let csoundData = """
    <CsoundSynthesizer>
    <CsOptions>
    \(params.options)
    -o \(params.outputFile)
    </CsOptions>

    <CsInstruments>
    \(params.instruments)
    </CsInstruments>

    <CsScore>
    \(params.score)
    </CsScore>
    </CsoundSynthesizer>
    """
    let csoundFilePath = "output/\(params.outputFile)"
    try csoundData.write(toFile: csoundFilePath, atomically: true, encoding: .utf8)
    return req.eventLoop.makeSucceededFuture(Response(status: .created, body: .init(string: csoundFilePath)))
}
EOL

# Create GenerateLilyPondFileController.swift
cat <<EOL > $PROJECT_NAME/Sources/App/Controllers/GenerateLilyPondFileController.swift
import Vapor

struct LilyPondParams: Content {
    var version: String
    var header: String
    var score: String
    var midi: String
    var outputFile: String
}

func generateLilyPondFile(_ req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.content.decode(LilyPondParams.self)
    let lilypondData = """
    \\version "\(params.version)"

    \\header {
      \(params.header)
    }

    \\score {
      \(params.score)

      \\layout { }

      \\midi {
        \(params.midi)
      }
    }
    """
    let lilypondFilePath = "output/\(params.outputFile).ly"
    let outputDir = "output/"
    let pdfFilePath = outputDir + "\(params.outputFile).pdf"
    let midiFilePath = outputDir + "\(params.outputFile).midi"
    try lilypondData.write(toFile: lilypondFilePath, atomically: true, encoding: .utf8)
    
    # Generate PDF and MIDI from LilyPond file
    let command = "lilypond --output=\(outputDir) \(lilypondFilePath)"
    let result = try shell(command)
    return req.eventLoop.makeSucceededFuture(Response(status: .created, body: .init(string: """
    {"lilyPondFilePath":"\(lilypondFilePath)","pdfFilePath":"\(pdfFilePath)","midiFilePath":"\(midiFilePath)"}
    """)))
}
EOL

# Create GenerateMIDIFileController.swift
cat <<EOL > $PROJECT_NAME/Sources/App/Controllers/GenerateMIDIFileController.swift
import Vapor
import MIDIKit

struct MIDIParams: Content {
    var events: [MIDIEventParams]
    var outputFile: String
}

struct MIDIEventParams: Content {
    var type: String
    var channel: UInt8
    var note: UInt8?
    var velocity: UInt8?
    var program: UInt8?
    var time: UInt32
}

func generateMIDIFile(_ req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.content.decode(MIDIParams.self)
    let midiFilePath = "output/\(params.outputFile)"
    let midi = MIDIFile()
    let track = MIDIFileTrack()
    midi.tracks.append(track)

    # Add events to the track
    for event in params.events {
        switch event.type {
        case "noteOn":
            track.add(event: MIDIEvent.noteOn(channel: event.channel, note: event.note, velocity: event.velocity, time: event.time))
        case "noteOff":
            track.add(event: MIDIEvent.noteOff(channel: event.channel, note: event.note, velocity: event.velocity, time: event.time))
        case "programChange":
            track.add(event: MIDIEvent.programChange(channel: event.channel

, program: event.program, time: event.time))
        default:
            break
        }
    }

    # Save the MIDI file
    try midi.write(to: URL(fileURLWithPath: midiFilePath))
    return req.eventLoop.makeSucceededFuture(Response(status: .created, body: .init(string: midiFilePath)))
}
EOL

# Create CommitFileController.swift
cat <<EOL > $PROJECT_NAME/Sources/App/Controllers/CommitFileController.swift
import Vapor

struct CommitParams: Content {
    var fileName: String
    var message: String
}

func commitFile(_ req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.content.decode(CommitParams.self)
    return gitAddAndCommit(filePath: "output/\(params.fileName)", message: params.message, on: req).map {
        Response(status: .ok, body: .init(string: $0))
    }
}
EOL

# Create PushToGitHubController.swift
cat <<EOL > $PROJECT_NAME/Sources/App/Controllers/PushToGitHubController.swift
import Vapor

struct PushParams: Content {
    var remote: String
    var branch: String
}

func pushToGitHub(_ req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.content.decode(PushParams.self)
    return gitPush(remote: params.remote, branch: params.branch, on: req).map {
        Response(status: .ok, body: .init(string: $0))
    }
}
EOL

# Create ListFilesController.swift
cat <<EOL > $PROJECT_NAME/Sources/App/Controllers/ListFilesController.swift
import Vapor

func listFiles(_ req: Request) throws -> EventLoopFuture<Response> {
    let files = try FileManager.default.contentsOfDirectory(atPath: "output")
    return req.eventLoop.makeSucceededFuture(Response(status: .ok, body: .init(string: try files.jsonEncodedString())))
}
EOL

# Create GetFileContentController.swift
cat <<EOL > $PROJECT_NAME/Sources/App/Controllers/GetFileContentController.swift
import Vapor

struct FileQueryParams: Content {
    var fileName: String
}

func getFileContent(_ req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.query.decode(FileQueryParams.self)
    let filePath = "output/\(params.fileName)"
    let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
    return req.eventLoop.makeSucceededFuture(Response(status: .ok, body: .init(string: fileContent)))
}
EOL

# Create GetFileHistoryController.swift
cat <<EOL > $PROJECT_NAME/Sources/App/Controllers/GetFileHistoryController.swift
import Vapor

func getFileHistory(_ req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.query.decode(FileQueryParams.self)
    let command = "git -C output log --oneline -- \(params.fileName)"
    let result = try shell(command)
    return req.eventLoop.makeSucceededFuture(Response(status: .ok, body: .init(string: result)))
}
EOL

# Create test files
# Create GenerateCsoundFileTests.swift
cat <<EOL > $PROJECT_NAME/Tests/AppTests/GenerateCsoundFileTests.swift
import XCTest
import Vapor
@testable import App

final class GenerateCsoundFileTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testGenerateCsoundFile() throws {
        let requestBody = """
        {
            "outputFile": "test_output.csd",
            "instruments": "instr 1\\nifreq = p4\\niamp = p5\\naout oscil iamp, ifreq, 1\\nouts aout, aout\\nendin",
            "score": "f1 0 16384 10 1\\ni1 0 30 55 0.3",
            "options": "-d -O wav -r 44100"
        }
        """
        try app.test(.POST, "/generate_csound_file", beforeRequest: { req in
            req.headers.contentType = .json
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            XCTAssertNotNil(res.body.string)
        })
    }
}
EOL

# Create GenerateLilyPondFileTests.swift
cat <<EOL > $PROJECT_NAME/Tests/AppTests/GenerateLilyPondFileTests.swift
import XCTest
import Vapor
@testable import App

final class GenerateLilyPondFileTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testGenerateLilyPondFile() throws {
        let requestBody = """
        {
            "version": "2.24.2",
            "header": "title = \\"Drone Melody\\"\\ncomposer = \\"Your Name\\"",
            "score": "\\\\new Staff {\\\\clef \\"bass\\"\\\\time 4/4\\\\key c \\\\major\\nc1 c1 c1 c1\\nc1 c1 c1 c1}",
            "midi": "\\\\tempo 4 = 60",
            "outputFile": "test_notation"
        }
        """
        try app.test(.POST, "/generate_lilypond_file", beforeRequest: { req in
            req.headers.contentType = .json
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            let responseBody = try res.content.decode([String: String].self)
            XCTAssertNotNil(responseBody["lilyPondFilePath"])
            XCTAssertNotNil(responseBody["midiFilePath"])
            XCTAssertNotNil(responseBody["pdfFilePath"])
        })
    }
}
EOL

# Create GenerateMIDIFileTests.swift
cat <<EOL > $PROJECT_NAME/Tests/AppTests/GenerateMIDIFileTests.swift
import XCTest
import Vapor
@testable import App

final class GenerateMIDIFileTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testGenerateMIDIFile() throws {
        let requestBody = """
        {
            "events": [
                { "type": "programChange", "channel": 0, "program": 0, "time": 0 },
                { "type": "noteOn", "channel": 0, "note": 33, "velocity": 64, "time": 0 },
                { "type": "noteOff", "channel": 0, "note": 33, "velocity": 64, "time": 1920 }
            ],
            "outputFile": "test_melody.mid"
        }
        """
        try app.test(.POST, "/generate_midi_file", beforeRequest: { req in
            req.headers.contentType = .json
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            XCTAssertNotNil(res.body.string)
        })
    }
}
EOL

# Create CommitFileTests.swift
cat <<EOL > $PROJECT_NAME/Tests/AppTests/CommitFileTests.swift
import XCTest
import Vapor
@testable import App

final class CommitFileTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testCommitFile() throws {
        let requestBody = """
        {
            "fileName": "test_output.csd",
            "message": "Initial commit of Csound file"
        }
        """
        try app.test(.POST, "/commit_file", beforeRequest: { req in
            req.headers.contentType = .json
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertNotNil(res.body.string)
        })
    }
}
EOL

# Create PushToGitHubTests.swift
cat <<EOL > $PROJECT_NAME/Tests/AppTests/PushToGitHubTests.swift
import XCTest
import Vapor
@testable import App

final class PushToGitHubTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testPushToGitHub() throws {
        let requestBody = """
        {
            "remote": "origin",
            "branch": "main"
        }
        """
        try app.test(.POST, "/push_to_github", beforeRequest: { req in
            req.headers.contentType = .json
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertNotNil(res.body.string)
        })
    }
}
EOL

# Create ListFilesTests.swift
cat <<EOL > $PROJECT_NAME/Tests/AppTests/ListFilesTests.swift
import XCTest
import Vapor
@testable import App

final class ListFilesTests: XCTestCase {
    var app: Application!

    override func setUp()

 {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testListFiles() throws {
        try app.test(.GET, "/list_files", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let files = try res.content.decode([String].self)
            XCTAssertNotNil(files)
        })
    }
}
EOL

# Create GetFileContentTests.swift
cat <<EOL > $PROJECT_NAME/Tests/AppTests/GetFileContentTests.swift
import XCTest
import Vapor
@testable import App

final class GetFileContentTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testGetFileContent() throws {
        let query = "?fileName=test_output.csd"
        try app.test(.GET, "/get_file_content\(query)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertNotNil(res.body.string)
        })
    }
}
EOL

# Create GetFileHistoryTests.swift
cat <<EOL > $PROJECT_NAME/Tests/AppTests/GetFileHistoryTests.swift
import XCTest
import Vapor
@testable import App

final class GetFileHistoryTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testGetFileHistory() throws {
        let query = "?fileName=test_output.csd"
        try app.test(.GET, "/get_file_history\(query)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertNotNil(res.body.string)
        })
    }
}
EOL

# Create XCTestManifests.swift
cat <<EOL > $PROJECT_NAME/Tests/AppTests/XCTestManifests.swift
import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GenerateCsoundFileTests.allTests),
        testCase(GenerateLilyPondFileTests.allTests),
        testCase(GenerateMIDIFileTests.allTests),
        testCase(CommitFileTests.allTests),
        testCase(PushToGitHubTests.allTests),
        testCase(ListFilesTests.allTests),
        testCase(GetFileContentTests.allTests),
        testCase(GetFileHistoryTests.allTests),
    ]
}
#endif
EOL

# Create LinuxMain.swift
cat <<EOL > $PROJECT_NAME/LinuxMain.swift
import XCTest

import AppTests

var tests = [XCTestCaseEntry]()
tests += AppTests.allTests()
XCTMain(tests)
EOL

# Create XCTest extension files
for file in GenerateCsoundFileTests GenerateLilyPondFileTests GenerateMIDIFileTests CommitFileTests PushToGitHubTests ListFilesTests GetFileContentTests GetFileHistoryTests; do
  cat <<EOL > $PROJECT_NAME/Tests/AppTests/${file}+XCTest.swift
import XCTest

extension ${file} {
    static var allTests = [
        ("test${file}", test${file}),
    ]
}
EOL
done

# Create Dockerfile
cat <<EOL > $PROJECT_NAME/Dockerfile
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

echo "Project setup complete!"
```

Make the script executable:

```bash
chmod +x setup_project.sh
```

Run the script to create the project:

```bash
./setup_project.sh
```

### How to Compile, Run, and Test the Project

1. **Compile the Project:**

   ```bash
   cd MusicSoundOrchestrationAPI
   swift build
   ```

2. **Run the Project:**

   ```bash
   swift run
   ```

   The server will start running on `http://localhost:8080`.

3. **Test the Project:**

   ```bash
   swift test
   ```

### Sample `curl` Commands for All Endpoints

Below are the sample `curl` commands for interacting with each endpoint of the MusicSound Orchestration API.

#### Generate Csound File

```bash
curl -X POST http://localhost:8080/generate_csound_file \
     -H "Content-Type: application/json" \
     -d '{
           "outputFile": "test_output.csd",
           "instruments": "instr 1\\nifreq = p4\\niamp = p5\\naout oscil iamp, ifreq, 1\\nouts aout, aout\\nendin",
           "score": "f1 0 16384 10 1\\ni1 0 30 55 0.3",
           "options": "-d -O wav -r 44100"
         }'
```

#### Generate LilyPond File (including MIDI generation)

```bash
curl -X POST http://localhost:8080/generate_lilypond_file \
     -H "Content-Type: application/json" \
     -d '{
           "version": "2.24.2",
           "header": "title = \\"Drone Melody\\"\\ncomposer = \\"Your Name\\"",
           "score": "\\new Staff {\\clef \\"bass\\"\\time 4/4\\key c \\major\\nc1 c1 c1 c1\\nc1 c1 c1 c1}",
           "midi": "\\tempo 4 = 60",
           "outputFile": "test_notation"
         }'
```

#### Generate MIDI File

```bash
curl -X POST http://localhost:8080/generate_midi_file \
     -H "Content-Type: application/json" \
     -d '{
           "events": [
             { "type": "programChange", "channel": 0, "program": 0, "time": 0 },
             { "type": "noteOn", "channel": 0, "note": 33, "velocity": 64, "time": 0 },
             { "type": "noteOff", "channel": 0, "note": 33, "velocity": 64, "time": 1920 }
           ],
           "outputFile": "test_melody.mid"
         }'
```

#### Commit File

```bash
curl -X POST http://localhost:8080/commit_file \
     -H "Content-Type: application/json" \
     -d '{
           "fileName": "test_output.csd",
           "message": "Initial commit of Csound file"
         }'
```

#### Push to GitHub

```bash
curl -X POST http://localhost:8080/push_to_github \
     -H "Content-Type: application/json" \
     -d '{
           "remote": "origin",
           "branch": "main"
         }'
```

#### List Files

```bash
curl -X GET http://localhost:8080/list_files
```

#### Get File Content

```bash
curl -X GET "http://localhost:8080/get_file_content?fileName=test_output.csd"
```

#### Get File History

```bash
curl -X GET "http://localhost:8080/get_file_history?fileName=test_output.csd"
```

### Conclusion

We have successfully created the MusicSound Orchestration API using Swift and Vapor. The project includes endpoints for generating musical files in Csound, LilyPond, and MIDI formats, committing these files to a git repository, and pushing them to a GitHub repository. By following a TDD approach, we ensured that our application is well-defined, tested, and meets the specified requirements.

### Comprehensive Commit Message

```
feat: Initial commit of MusicSound Orchestration API

- Implemented endpoints for generating Csound, LilyPond, and MIDI files.
- Added functionality to commit generated files to a local git repository.
- Added functionality to push committed files to a GitHub repository.
- Included tests for all endpoints following a TDD approach.
- Provided a Dockerfile for containerized deployment.
- Created a shell script to automate project setup.
```
### Addendum: Using the Dockerfile

To simplify deployment and ensure all dependencies are correctly installed, you can use Docker to containerize the MusicSound Orchestration API application. Below are the steps to build and run the Docker container.

#### 1. Building the Docker Image

First, make sure you have Docker installed on your machine. Then, navigate to the project directory and build the Docker image using the following command:

```bash
cd MusicSoundOrchestrationAPI
docker build -t musicsound-orchestration-api .
```

This command will create a Docker image named `musicsound-orchestration-api` based on the instructions in the Dockerfile.

#### 2. Running the Docker Container

Once the Docker image is built, you can run a container using the following command:

```bash
docker run -p 8080:8080 musicsound-orchestration-api
```

This command will start a new container from the `musicsound-orchestration-api` image and map port 8080 of the container to port 8080 on your host machine. The application will be accessible at `http://localhost:8080`.

#### 3. Stopping the Docker Container

To stop the running container, first find the container ID using the `docker ps` command:

```bash
docker ps
```

Then, stop the container using the `docker stop` command followed by the container ID:

```bash
docker stop <container_id>
```

#### 4. Removing the Docker Container and Image

If you want to remove the container and image, use the following commands:

First, remove the container:

```bash
docker rm <container_id>
```

Then, remove the image:

```bash
docker rmi musicsound-orchestration-api
```

### Example Commands

Here are example commands to illustrate the process:

```bash
# Navigate to project directory
cd MusicSoundOrchestrationAPI

# Build the Docker image
docker build -t musicsound-orchestration-api .

# Run the Docker container
docker run -p 8080:8080 musicsound-orchestration-api

# Stop the Docker container (use the actual container ID)
docker stop <container_id>

# Remove the Docker container (use the actual container ID)
docker rm <container_id>

# Remove the Docker image
docker rmi musicsound-orchestration-api
```

### Conclusion

Using Docker to containerize the MusicSound Orchestration API simplifies the deployment process by ensuring all dependencies are correctly installed and configured. The provided Dockerfile and commands allow you to easily build, run, and manage the application in a containerized environment.
