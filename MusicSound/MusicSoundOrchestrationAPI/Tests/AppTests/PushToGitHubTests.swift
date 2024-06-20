import XCTest
import Vapor
@testable import App

final class PushToGitHubTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testPushToGitHub() throws {
        let requestBody = """
        {
            "remote": "origin",
            "branch": "main"
        }
        """
        try app.test(.POST, "/push_to_github", beforeRequest: { req in
            req.headers.contentType = .json
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertNotNil(res.body.string)
        })
    }
}
