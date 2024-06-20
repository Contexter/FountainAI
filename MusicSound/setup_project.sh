#!/bin/bash

PROJECT_NAME="MusicSoundOrchestrationAPI"
mkdir -p $PROJECT_NAME

# Create project directories
mkdir -p $PROJECT_NAME/Sources/App/Controllers
mkdir -p $PROJECT_NAME/Sources/App/Utilities
mkdir -p $PROJECT_NAME/Sources/Run
mkdir -p $PROJECT_NAME/Tests/AppTests

# Create Package.swift
cat <<EOL > $PROJECT_NAME/Package.swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MusicSoundOrchestrationAPI",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/matrix-org/MatrixSDK.git", from: "0.17.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "MatrixSDK", package: "MatrixSDK")
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
            dependencies: [.target(name: "App")],
            path: "Tests/AppTests"
        )
    ]
)
EOL

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
    {"lilyPondFilePath":"\(l

ilypondFilePath)","pdfFilePath":"\(pdfFilePath)","midiFilePath":"\(midiFilePath)"}
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
            "score": "\\new Staff {\\clef \\"bass\\"\\time 4/4\\key c \\major\\nc1 c1 c1 c1\\nc1 c1 c1 c1}",
            "midi": "\\tempo 4 = 60",
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
        try app.test(.POST, "/

commit_file", beforeRequest: { req in
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
