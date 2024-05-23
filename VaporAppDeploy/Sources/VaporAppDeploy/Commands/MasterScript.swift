import Foundation
import ArgumentParser

/// Command to run the master script for setting up and deploying the Vapor application.
struct MasterScript: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run the master script to set up and deploy the Vapor application."
    )

    /// Execute the master script, which includes multiple phases.
    func run() {
        print("Starting Phase 1: Vapor App Creation...")
        runScript(CreateDirectories.self)
        runScript(SetupVaporProject.self)
        runScript(BuildVaporApp.self)
        print("Phase 1: Vapor App Creation completed.")

        print("Starting Phase 2: Production Deployment...")
        runScript(CreateDirectories.self)
        runScript(CreateDockerComposeFile.self)
        runScript(CreateNginxConfigFile.self)
        runScript(CreateCertbotScript.self)
        print("Project setup for production deployment...")

        runScript(SetupProject.self)
        print("Phase 2: Production Deployment completed.")

        print("Master script completed successfully. The Vapor app is now set up and running in the production environment.")
    }

    /// Helper method to run another command as part of the master script.
    /// - Parameter command: The command to run.
    private func runScript<T: ParsableCommand>(_ command: T.Type) {
        var command = command.init()
        do {
            try command.run()
        } catch {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
}

