import Vapor

struct CommitFileController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let commit = routes.grouped("commit")
        commit.post(use: commitFile)
    }
    
    func commitFile(req: Request) throws -> EventLoopFuture<Response> {
        let params = try req.content.decode(CommitFileParams.self)
        let repoPath = "path/to/repo"
        
        return req.eventLoop.future(try gitAddAndCommit(filePath: "output/\(params.fileName)", message: params.message, repoPath: repoPath))
            .map { _ in Response(status: .ok, body: .init(string: "File committed")) }
    }
}

struct CommitFileParams: Content {
    var fileName: String
    var message: String
}
