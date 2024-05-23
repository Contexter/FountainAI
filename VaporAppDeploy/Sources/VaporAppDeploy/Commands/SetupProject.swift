import Foundation
import ArgumentParser

/// Command to set up the entire project.
struct SetupProject: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Set up the entire project."
    )

    /// Execute the command to set up the entire project.
    func run() {
        let config = readConfig()
        let projectDir = config.projectDirectory
        let domain = config.domain
        validateProjectDirectory(projectDir)
        validateDomainName(domain)

        runScript(CreateDirectories.self)
        runScript(CreateDockerComposeFile.self)
        runScript(CreateNginxConfigFile.self)
        runScript(CreateCertbotScript.self)

        print("Project setup complete in \(projectDir).")

        runShellCommand("/usr/bin/env", arguments: ["docker-compose", "up", "-d"], workingDirectory: projectDir)
        runShellCommand("/bin/bash", arguments: ["./certbot/init-letsencrypt.sh"], workingDirectory: projectDir)

        print("Production server setup complete and running in \(projectDir).")
    }

    /// Helper method to run another command as part of the setup process.
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

