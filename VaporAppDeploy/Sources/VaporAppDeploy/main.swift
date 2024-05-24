import Foundation
import ArgumentParser

@main
struct VaporAppDeploy: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "vaporappdeploy",
        abstract: "A utility for deploying a Vapor application.",
        subcommands: [
            CreateDirectories.self,
            SetupVaporProject.self,
            BuildVaporApp.self,
            RunVaporLocal.self,
            CreateDockerComposeFile.self,
            CreateNginxConfigFile.self,
            CreateCertbotScript.self,
            SetupProject.self,
            MasterScript.self,
            SetupCiCdPipeline.self
        ]
    )
}
