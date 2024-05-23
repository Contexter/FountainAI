import Foundation
import ArgumentParser

/// Command to create the Docker Compose file.
struct CreateDockerComposeFile: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Create the Docker Compose file."
    )

    /// Execute the command to create the Docker Compose file.
    func run() {
        let config = readConfig()
        let projectDir = config.projectDirectory
        validateProjectDirectory(projectDir)

        let templatePath = "./config/docker-compose-template.yml"
        let outputPath = "\(projectDir)/docker-compose.yml"

        let templateContent = try! String(contentsOfFile: templatePath)
        let substitutedContent = templateContent
            .replacingOccurrences(of: "$DATABASE_USERNAME", with: config.database.username)
            .replacingOccurrences(of: "$DATABASE_PASSWORD", with: config.database.password)
            .replacingOccurrences(of: "$DATABASE_NAME", with: config.database.name)
            .replacingOccurrences(of: "$REDIS_HOST", with: config.redis.host)
            .replacingOccurrences(of: "$REDIS_PORT", with: String(config.redis.port))

        try! substitutedContent.write(toFile: outputPath, atomically: true, encoding: .utf8)
        print("Docker Compose file created in \(projectDir).")
    }
}

