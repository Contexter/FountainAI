import XCTest
import Vapor
@testable import App

final class CommitFileTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testCommitFile() throws {
        let requestBody = """
        {
            "fileName": "test_output.csd",
            "message": "Initial commit of Csound file"
        }
        """
        try app.test(.POST, "/commit_file", beforeRequest: { req in
            req.headers.contentType = .json
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertNotNil(res.body.string)
        })
    }
}
