import XCTest
import Vapor
@testable import App

final class GetFileHistoryTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testGetFileHistory() throws {
        let query = "?fileName=test_output.csd"
        try app.test(.GET, "/get_file_history\(query)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertNotNil(res.body.string)
        })
    }
}
