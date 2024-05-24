import Foundation

/// Runs a shell command with the specified arguments and optional working directory.
///
/// - Parameters:
///   - command: The command to execute.
///   - arguments: The arguments to pass to the command.
///   - workingDirectory: The working directory to execute the command in. Defaults to `nil`.
/// - Throws: A fatal error if the command execution fails.
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
