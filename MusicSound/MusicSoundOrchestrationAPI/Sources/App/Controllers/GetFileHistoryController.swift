import Vapor

func getFileHistory(_ req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.query.decode(FileQueryParams.self)
    let command = "git -C output log --oneline -- \(params.fileName)"
    let result = try shell(command)
    return req.eventLoop.makeSucceededFuture(Response(status: .ok, body: .init(string: result)))
}
