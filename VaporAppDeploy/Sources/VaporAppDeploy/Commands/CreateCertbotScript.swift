import Foundation
import ArgumentParser

/// Command to create the Certbot script for SSL certificate management.
struct CreateCertbotScript: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Create the Certbot script."
    )

    /// Execute the command to create the Certbot script.
    func run() {
        createCertbotDirectoryStructure()
        downloadTlsParameters()
        createCertbotScriptFile()
    }

    /// Create the directory structure required for Certbot.
    private func createCertbotDirectoryStructure() {
        let config = readConfig()
        let projectDir = config.projectDirectory
        validateProjectDirectory(projectDir)

        let fileManager = FileManager.default
        let directories = [
            "\(projectDir)/certbot/conf",
            "\(projectDir)/certbot/www"
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

    /// Download the recommended TLS parameters for Nginx.
    private func downloadTlsParameters() {
        let config = readConfig()
        let projectDir = config.projectDirectory
        validateProjectDirectory(projectDir)

        let optionsSslNginxPath = "\(projectDir)/certbot/conf/options-ssl-nginx.conf"
        let sslDhparamsPath = "\(projectDir)/certbot/conf/ssl-dhparams.pem"

        if !FileManager.default.fileExists(atPath: optionsSslNginxPath) || !FileManager.default.fileExists(atPath: sslDhparamsPath) {
            print("### Downloading recommended TLS parameters ...")
            let optionsSslNginxURL = URL(string: "https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/options-ssl-nginx.conf")!
            let sslDhparamsURL = URL(string: "https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem")!

            try! Data(contentsOf: optionsSslNginxURL).write(to: URL(fileURLWithPath: optionsSslNginxPath))
            try! Data(contentsOf: sslDhparamsURL).write(to: URL(fileURLWithPath: sslDhparamsPath))

            print("TLS parameters downloaded.")
        } else {
            print("TLS parameters already exist.")
        }
    }

    /// Create the Certbot script file with the necessary substitutions.
    private func createCertbotScriptFile() {
        let config = readConfig()
        let projectDir = config.projectDirectory
        let domain = config.domain
        validateProjectDirectory(projectDir)
        validateDomainName(domain)

        let templatePath = "./config/init-letsencrypt-template.sh"
        let outputPath = "\(projectDir)/certbot/init-letsencrypt.sh"

        let templateContent = try! String(contentsOfFile: templatePath)
        let substitutedContent = templateContent
            .replacingOccurrences(of: "$DOMAIN", with: domain)
            .replacingOccurrences(of: "$EMAIL", with: config.email)
            .replacingOccurrences(of: "$STAGING", with: String(config.staging))

        try! substitutedContent.write(toFile: outputPath, atomically: true, encoding: .utf8)
        try! FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: outputPath)

        print("Let's Encrypt certificate generation script created for \(domain) in \(projectDir).")
    }
}

