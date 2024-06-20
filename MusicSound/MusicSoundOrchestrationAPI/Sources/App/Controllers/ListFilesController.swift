import Vapor

func listFiles(_ req: Request) throws -> EventLoopFuture<Response> {
    let files = try FileManager.default.contentsOfDirectory(atPath: "output")
    return req.eventLoop.makeSucceededFuture(Response(status: .ok, body: .init(string: try files.jsonEncodedString())))
}
