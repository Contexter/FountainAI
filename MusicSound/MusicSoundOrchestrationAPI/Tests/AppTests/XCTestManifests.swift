import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GenerateCsoundFileTests.allTests),
        testCase(GenerateLilyPondFileTests.allTests),
        testCase(GenerateMIDIFileTests.allTests),
        testCase(CommitFileTests.allTests),
        testCase(PushToGitHubTests.allTests),
        testCase(ListFilesTests.allTests),
        testCase(GetFileContentTests.allTests),
        testCase(GetFileHistoryTests.allTests),
    ]
}
#endif
