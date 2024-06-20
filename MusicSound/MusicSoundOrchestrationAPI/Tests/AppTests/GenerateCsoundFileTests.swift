import XCTest
import Vapor
@testable import App

final class GenerateCsoundFileTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testGenerateCsoundFile() throws {
        let requestBody = """
        {
            "outputFile": "test_output.csd",
            "instruments": "instr 1\nifreq = p4\niamp = p5\naout oscil iamp, ifreq, 1\nouts aout, aout\nendin",
            "score": "f1 0 16384 10 1\ni1 0 30 55 0.3",
            "options": "-d -O wav -r 44100"
        }
        """
        try app.test(.POST, "/generate_csound_file", beforeRequest: { req in
            req.headers.contentType = .json
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            XCTAssertNotNil(res.body.string)
        })
    }
}
