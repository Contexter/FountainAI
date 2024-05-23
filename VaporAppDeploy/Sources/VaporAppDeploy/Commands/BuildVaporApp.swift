import Foundation
import ArgumentParser

/// Command to build the Vapor application.
struct BuildVaporApp: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Build the Vapor application."
    )

    /// Execute the command to build the Vapor application in release mode.
    func run() {
        let config = readConfig()
        let projectDir = config.projectDirectory
        validateProjectDirectory(projectDir)

        runShellCommand("/usr/bin/env", arguments: ["swift", "build", "-c", "release"], workingDirectory: projectDir)
        print("Vapor app built in release mode.")
    }
}

