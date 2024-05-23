import Foundation
import ArgumentParser

/// Command to create necessary directories for the project.
struct CreateDirectories: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Create necessary directories for the project."
    )

    /// Execute the command to create the required directories.
    func run() {
        let config = readConfig()
        let projectDir = config.projectDirectory
        validateProjectDirectory(projectDir)

        let fileManager = FileManager.default
        let directories = [
            "\(projectDir)/Sources/App/Controllers",
            "\(projectDir)/Sources/App/Models",
            "\(projectDir)/Sources/App/Migrations"
        ]

        for dir in directories {
            if !fileManager.fileExists(atPath: dir) {
                try! fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                print("Directory created at \(dir)")
            } else {
                print("Directory already exists at \(dir)")
            }
        }
    }
}

