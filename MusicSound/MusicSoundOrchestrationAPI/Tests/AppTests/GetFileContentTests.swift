import XCTest
import Vapor
@testable import App

final class GetFileContentTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testGetFileContent() throws {
        let query = "?fileName=test_output.csd"
        try app.test(.GET, "/get_file_content\(query)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertNotNil(res.body.string)
        })
    }
}
