import Vapor

struct PushToGitHubController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let push = routes.grouped("push")
        push.post(use: pushToGitHub)
    }
    
    func pushToGitHub(req: Request) throws -> EventLoopFuture<Response> {
        let params = try req.content.decode(PushToGitHubParams.self)
        let repoPath = "path/to/repo"
        
        return req.eventLoop.future(try shell("git -C \(repoPath) push \(params.remote) \(params.branch)"))
            .map { _ in Response(status: .ok, body: .init(string: "Pushed to GitHub")) }
    }
}

struct PushToGitHubParams: Content {
    var remote: String
    var branch: String
}
