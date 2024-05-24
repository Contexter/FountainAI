import Foundation
import ArgumentParser

/// Main entry point for the VaporAppDeploy utility.
@main
struct VaporAppDeploy: ParsableCommand {
    /// Configuration for the VaporAppDeploy command.
    static var configuration = CommandConfiguration(
        /// The command name for this utility.
        commandName: "vaporappdeploy",
        
        /// A brief description of what this utility does.
        abstract: "A utility for deploying a Vapor application.",
        
        /// Subcommands available within this utility.
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
