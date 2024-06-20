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
