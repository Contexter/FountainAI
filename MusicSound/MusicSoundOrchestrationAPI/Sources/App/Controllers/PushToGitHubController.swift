import Vapor

struct PushParams: Content {
    var remote: String
    var branch: String
}

func pushToGitHub(_ req: Request) throws -> EventLoopFuture<Response> {
    let params = try req.content.decode(PushParams.self)
    return gitPush(remote: params.remote, branch: params.branch, on: req).map {
        Response(status: .ok, body: .init(string: ./setup_project.sh))
    }
}
