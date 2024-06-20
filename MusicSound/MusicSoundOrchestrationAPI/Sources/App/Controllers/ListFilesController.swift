import Vapor

func listFiles(req: Request) throws -> EventLoopFuture<Response> {
    let files = try FileManager.default.contentsOfDirectory(atPath: "output")
    let jsonData = try JSONEncoder().encode(files)
    let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"
    return req.eventLoop.makeSucceededFuture(Response(status: .ok, body: .init(string: jsonString)))
}
