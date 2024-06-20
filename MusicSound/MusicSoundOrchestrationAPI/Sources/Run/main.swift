import App
import Vapor

var env = try Environment.detect()
let app = Application(env)
try configure(app)
defer { app.shutdown() }
try app.run()
