#!/bin/bash

# Fix for MIDIKit integration and other issues
# Applying necessary changes to the project files

# Correcting GenerateMIDIFileController.swift
cat <<EOL > Sources/App/Controllers/GenerateMIDIFileController.swift
import Vapor
import MIDIKit

struct GenerateMIDIFileRequest: Content {
    let fileName: String
    let events: [MIDIEvent]
}

func generateMIDIFile(req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.content.decode(GenerateMIDIFileRequest.self)
    var midi = MIDIFile()
    var track = MIDIFileTrack()

    for event in params.events {
        switch event.type {
        case .noteOn:
            let noteOn = MIDIEvent.noteOn(
                event.note,
                velocity: .unitInterval(Double(event.velocity) / 127.0),
                channel: event.channel,
                group: 0
            )
            track.events.append(.noteOn(noteOn))
        case .noteOff:
            let noteOff = MIDIEvent.noteOff(
                event.note,
                velocity: .unitInterval(Double(event.velocity) / 127.0),
                channel: event.channel,
                group: 0
            )
            track.events.append(.noteOff(noteOff))
        case .programChange:
            let programChange = MIDIEvent.programChange(
                event.program,
                channel: event.channel,
                group: 0
            )
            track.events.append(.programChange(programChange))
        default:
            break
        }
    }

    midi.tracks.append(track)
    try midi.write(to: URL(fileURLWithPath: "output/\(params.fileName)"))

    return req.eventLoop.makeSucceededFuture(Response(status: .ok))
}
EOL

# Correcting routes.swift
cat <<EOL > Sources/App/routes.swift
import Vapor

func routes(_ app: Application) throws {
    app.post("generate_midi_file", use: generateMIDIFile)
    app.post("commit_file", use: commitFile)
    app.post("push_to_github", use: pushToGitHub)
}
EOL

# Correcting ListFilesController.swift
cat <<EOL > Sources/App/Controllers/ListFilesController.swift
import Vapor

func listFiles(req: Request) throws -> EventLoopFuture<Response> {
    let files = try FileManager.default.contentsOfDirectory(atPath: "output")
    let jsonData = try JSONEncoder().encode(files)
    let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"
    return req.eventLoop.makeSucceededFuture(Response(status: .ok, body: .init(string: jsonString)))
}
EOL

echo "Patch 4 applied successfully."
