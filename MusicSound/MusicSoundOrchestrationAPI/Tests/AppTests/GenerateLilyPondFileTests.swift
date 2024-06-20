import XCTest
import Vapor
@testable import App

final class GenerateLilyPondFileTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testGenerateLilyPondFile() throws {
        let requestBody = """
        {
            "version": "2.24.2",
            "header": "title = \"Drone Melody\"\ncomposer = \"Your Name\"",
            "score": "\new Staff {\clef \"bass\"\time 4/4\key c \major\nc1 c1 c1 c1\nc1 c1 c1 c1}",
            "midi": "\tempo 4 = 60",
            "outputFile": "test_notation"
        }
        """
        try app.test(.POST, "/generate_lilypond_file", beforeRequest: { req in
            req.headers.contentType = .json
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            let responseBody = try res.content.decode([String: String].self)
            XCTAssertNotNil(responseBody["lilyPondFilePath"])
            XCTAssertNotNil(responseBody["midiFilePath"])
            XCTAssertNotNil(responseBody["pdfFilePath"])
        })
    }
}
