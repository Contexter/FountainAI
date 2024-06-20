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
    \version "\(params.version)"

    \header {
      \(params.header)
    }

    \score {
      \(params.score)

      \layout { }

      \midi {
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
