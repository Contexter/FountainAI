#!/bin/bash

# Update GenerateMIDIFileController.swift to use MIDIKit correctly
cat <<EOL > Sources/App/Controllers/GenerateMIDIFileController.swift
import Vapor
import MIDIKit

struct GenerateMIDIFileController {
    func generate(req: Request) throws -> EventLoopFuture<Response> {
        let params = try req.content.decode(GenerateMIDIFileParams.self)
        
        let midi = MIDIFile()
        var track = MIDIFileTrack()
        
        for event in params.events {
            switch event.type {
            case .noteOn:
                let noteOn = MIDIEvent.noteOn(
                    note: MIDINote(event.note!),
                    velocity: .unitInterval(event.velocity! / 127.0),
                    channel: .init(event.channel),
                    group: 0
                )
                track.events.append(.noteOn(noteOn))
            case .noteOff:
                let noteOff = MIDIEvent.noteOff(
                    note: MIDINote(event.note!),
                    velocity: .unitInterval(event.velocity! / 127.0),
                    channel: .init(event.channel),
                    group: 0
                )
                track.events.append(.noteOff(noteOff))
            case .programChange:
                let programChange = MIDIEvent.programChange(
                    program: .init(event.program!),
                    channel: .init(event.channel),
                    group: 0
                )
                track.events.append(.programChange(programChange))
            }
        }
        
        midi.tracks.append(track)
        
        let midiFilePath = "output/\(params.fileName)"
        try midi.write(to: URL(fileURLWithPath: midiFilePath))
        
        return req.eventLoop.future(Response(status: .ok, body: .init(string: "MIDI file generated at \(midiFilePath)")))
    }
}

struct GenerateMIDIFileParams: Content {
    var fileName: String
    var events: [MIDIEventParams]
}

struct MIDIEventParams: Content {
    var type: MIDIEventType
    var channel: Int
    var note: Int?
    var velocity: Int?
    var program: Int?
    var time: Int
}

enum MIDIEventType: String, Content {
    case noteOn, noteOff, programChange
}
EOL

# Fix shell call results in GitUtils.swift
cat <<EOL > Sources/App/Utilities/GitUtils.swift
import Foundation

func shell(_ command: String) throws -> String {
    let process = Process()
    let pipe = Pipe()
    
    process.standardOutput = pipe
    process.standardError = pipe
    process.arguments = ["-c", command]
    process.launchPath = "/bin/zsh"
    process.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    
    if process.terminationStatus != 0 {
        let output = String(data: data, encoding: .utf8) ?? ""
        throw NSError(domain: "", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: output])
    }
    
    return String(data: data, encoding: .utf8) ?? ""
}

func gitAddAndCommit(filePath: String, message: String, repoPath: String) throws {
    _ = try shell("git -C \(repoPath) init")
    _ = try shell("git -C \(repoPath) config user.name \"VaporApp\"")
    _ = try shell("git -C \(repoPath) config user.email \"vapor@app.local\"")
    _ = try shell("git -C \(repoPath) add \(filePath)")
    _ = try shell("git -C \(repoPath) commit -m \"\(message)\"")
}
EOL

# Fix scope errors in controllers
cat <<EOL > Sources/App/Controllers/CommitFileController.swift
import Vapor

struct CommitFileController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let commit = routes.grouped("commit")
        commit.post(use: commitFile)
    }
    
    func commitFile(req: Request) throws -> EventLoopFuture<Response> {
        let params = try req.content.decode(CommitFileParams.self)
        let repoPath = "path/to/repo"
        
        return req.eventLoop.future(try gitAddAndCommit(filePath: "output/\(params.fileName)", message: params.message, repoPath: repoPath))
            .map { _ in Response(status: .ok, body: .init(string: "File committed")) }
    }
}

struct CommitFileParams: Content {
    var fileName: String
    var message: String
}
EOL

cat <<EOL > Sources/App/Controllers/PushToGitHubController.swift
import Vapor

struct PushToGitHubController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let push = routes.grouped("push")
        push.post(use: pushToGitHub)
    }
    
    func pushToGitHub(req: Request) throws -> EventLoopFuture<Response> {
        let params = try req.content.decode(PushToGitHubParams.self)
        let repoPath = "path/to/repo"
        
        return req.eventLoop.future(try shell("git -C \(repoPath) push \(params.remote) \(params.branch)"))
            .map { _ in Response(status: .ok, body: .init(string: "Pushed to GitHub")) }
    }
}

struct PushToGitHubParams: Content {
    var remote: String
    var branch: String
}
EOL
