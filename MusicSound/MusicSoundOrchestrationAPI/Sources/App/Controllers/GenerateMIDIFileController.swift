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
