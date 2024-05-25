import Vapor

public func routes(_ app: Application) throws {
    let scriptController = ScriptController()
    try app.register(collection: scriptController)
}
