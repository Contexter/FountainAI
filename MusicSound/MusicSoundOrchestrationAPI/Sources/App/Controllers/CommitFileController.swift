import Vapor

struct CommitParams: Content {
    var fileName: String
    var message: String
}

func commitFile(_ req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.content.decode(CommitParams.self)
    return gitAddAndCommit(filePath: "output/\(params.fileName)", message: params.message, on: req).map {
        Response(status: .ok, body: .init(string: ./setup_project.sh))
    }
}
