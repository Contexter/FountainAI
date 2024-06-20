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
