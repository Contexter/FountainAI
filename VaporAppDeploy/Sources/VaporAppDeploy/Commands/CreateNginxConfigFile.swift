import Foundation
import ArgumentParser

/// Command to create the Nginx configuration file.
struct CreateNginxConfigFile: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Create the Nginx configuration file."
    )

    /// Execute the command to create the Nginx configuration file.
    func run() {
        let config = readConfig()
        let projectDir = config.projectDirectory
        let domain = config.domain
        validateProjectDirectory(projectDir)
        validateDomainName(domain)

        let templatePath = "./config/nginx-template.conf"
        let outputPath = "\(projectDir)/nginx/nginx.conf"

        let templateContent = try! String(contentsOfFile: templatePath)
        let substitutedContent = templateContent
            .replacingOccurrences(of: "$DOMAIN", with: domain)

        try! substitutedContent.write(toFile: outputPath, atomically: true, encoding: .utf8)
        print("Nginx configuration file created for \(domain) in \(projectDir).")
    }
}

