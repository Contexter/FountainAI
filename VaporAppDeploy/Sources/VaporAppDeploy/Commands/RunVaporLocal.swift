import Foundation
import ArgumentParser

/// Command to run the Vapor application locally.
struct RunVaporLocal: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run the Vapor application locally."
    )

    /// Execute the command to run the Vapor application in development mode.
    func run() {
        let config = readConfig()
        let projectDir = config.projectDirectory
        validateProjectDirectory(projectDir)

        runShellCommand("\(projectDir)/.build/release/App", arguments: ["--env", "development"], workingDirectory: projectDir)
    }
}

