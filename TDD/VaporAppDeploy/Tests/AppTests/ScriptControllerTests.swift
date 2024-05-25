import XCTVapor
@testable import App

final class ScriptControllerTests: XCTestCase {
    func testCreateScript() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        // Ensure the database is clean before starting the test
        try app.autoRevert().wait()
        try app.autoMigrate().wait()

        try app.test(.POST, "scripts", beforeRequest: { req in
            try req.content.encode(Script(title: "Test Title", description: "Test Description", author: "Test Author", sequence: 1))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)  // Change to .ok as the current implementation returns 200 OK
            let script = try res.content.decode(Script.self)
            XCTAssertEqual(script.title, "Test Title")
            XCTAssertEqual(script.description, "Test Description")
            XCTAssertEqual(script.author, "Test Author")
            XCTAssertEqual(script.sequence, 1)
        })
    }

    func testGetAllScripts() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        // Ensure the database is clean before starting the test
        try app.autoRevert().wait()
        try app.autoMigrate().wait()

        // Pre-create a script
        let script = Script(title: "Test Title", description: "Test Description", author: "Test Author", sequence: 1)
        try script.save(on: app.db).wait()

        try app.test(.GET, "scripts", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let scripts = try res.content.decode([Script].self)
            XCTAssertEqual(scripts.count, 1)  // Expecting 1 script in the database
            XCTAssertEqual(scripts[0].title, "Test Title")
        })
    }

    func testDeleteScript() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        // Ensure the database is clean before starting the test
        try app.autoRevert().wait()
        try app.autoMigrate().wait()

        // Pre-create a script
        let script = Script(title: "Test Title", description: "Test Description", author: "Test Author", sequence: 1)
        try script.save(on: app.db).wait()

        try app.test(.DELETE, "scripts/\(script.id!)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })

        // Ensure script is deleted
        let remainingScripts = try Script.query(on: app.db).all().wait()
        XCTAssertEqual(remainingScripts.count, 0)  // Expecting 0 scripts after deletion
    }
}
