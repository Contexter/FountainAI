#!/bin/bash

# Update Package.swift to include MIDIKit
cat <<EOL > Package.swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MusicSoundOrchestrationAPI",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/orchetect/MIDIKit.git", from: "0.9.6")
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Leaf", package: "leaf"),
            .product(name: "MIDIKit", package: "MIDIKit")
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
EOL

# Update GenerateMIDIFileController.swift to use MIDIKit correctly
cat <<EOL > Sources/App/Controllers/GenerateMIDIFileController.swift
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

    // Add events to the track
    for event in params.events {
        switch event.type {
        case "noteOn":
            track.add(event: MIDIEvent.noteOn(channel: event.channel, note: event.note!, velocity: event.velocity!, time: .ticks(event.time)))
        case "noteOff":
            track.add(event: MIDIEvent.noteOff(channel: event.channel, note: event.note!, velocity: event.velocity!, time: .ticks(event.time)))
        case "programChange":
            track.add(event: MIDIEvent.programChange(channel: event.channel, program: event.program!, time: .ticks(event.time)))
        default:
            break
        }
    }

    // Save the MIDI file
    try midi.write(to: URL(fileURLWithPath: midiFilePath))
    return req.eventLoop.makeSucceededFuture(Response(status: .created, body: .init(string: midiFilePath)))
}
EOL

echo "Patches applied successfully!"
