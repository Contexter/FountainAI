import XCTest
import Vapor
@testable import App

final class ListFilesTests: XCTestCase {
    var app: Application!

    override func setUp()

 {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testListFiles() throws {
        try app.test(.GET, "/list_files", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let files = try res.content.decode([String].self)
            XCTAssertNotNil(files)
        })
    }
}
