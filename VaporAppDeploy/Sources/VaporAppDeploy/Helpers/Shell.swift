import Foundation

func runShellCommand(_ command: String, arguments: [String], workingDirectory: String? = nil) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = arguments
    if let workingDirectory = workingDirectory {
        process.currentDirectoryURL = URL(fileURLWithPath: workingDirectory)
    }

    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        fatalError("Error: \(error.localizedDescription)")
    }
}
