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
