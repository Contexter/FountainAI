import Vapor
import Fluent

struct ScriptController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let scripts = routes.grouped("scripts")
        scripts.get(use: index)
        scripts.post(use: create)
        scripts.group(":scriptID") { script in
            script.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Script]> {
        return Script.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Script> {
        let script = try req.content.decode(Script.self)
        return script.save(on: req.db).map { script }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .flatMap { script in
                script?.delete(on: req.db).transform(to: .ok) ?? req.eventLoop.future(.notFound)
            }
    }
}
