import Foundation
import Yams

/// The configuration structure for the Vapor application deployment.
struct Config: Decodable {
    /// The project directory path.
    var projectDirectory: String
    /// The domain name for the project.
    var domain: String
    /// The email address associated with the project.
    var email: String
    /// The database configuration.
    var database: DatabaseConfig
    /// The Redis configuration.
    var redis: RedisConfig
    /// The staging environment indicator.
    var staging: Int
}

/// The database configuration structure.
struct DatabaseConfig: Decodable {
    /// The database host address.
    var host: String
    /// The database username.
    var username: String
    /// The database password.
    var password: String
    /// The database name.
    var name: String
}

/// The Redis configuration structure.
struct RedisConfig: Decodable {
    /// The Redis host address.
    var host: String
    /// The Redis port number.
    var port: Int
}

/// Reads and decodes the configuration file.
///
/// - Returns: The decoded configuration structure.
/// - Throws: A fatal error if the configuration file is not found or cannot be decoded.
func readConfig() -> Config {
    /// The file URL for the configuration file.
    let fileURL = URL(fileURLWithPath: "./config/config.yaml")
    guard let data = try? Data(contentsOf: fileURL) else {
        fatalError("Configuration file not found: ./config/config.yaml")
    }

    let decoder = YAMLDecoder()
    guard let config = try? decoder.decode(Config.self, from: data) else {
        fatalError("Failed to decode configuration file")
    }

    return config
}
