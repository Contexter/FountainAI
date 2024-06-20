import XCTest
import Vapor
@testable import App

final class GenerateMIDIFileTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testGenerateMIDIFile() throws {
        let requestBody = """
        {
            "events": [
                { "type": "programChange", "channel": 0, "program": 0, "time": 0 },
                { "type": "noteOn", "channel": 0, "note": 33, "velocity": 64, "time": 0 },
                { "type": "noteOff", "channel": 0, "note": 33, "velocity": 64, "time": 1920 }
            ],
            "outputFile": "test_melody.mid"
        }
        """
        try app.test(.POST, "/generate_midi_file", beforeRequest: { req in
            req.headers.contentType = .json
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            XCTAssertNotNil(res.body.string)
        })
    }
}
