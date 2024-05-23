import Foundation

struct Config: Decodable {
    var projectDirectory: String
    var domain: String
    var email: String
    var database: DatabaseConfig
    var redis: RedisConfig
    var staging: Int
}

struct DatabaseConfig: Decodable {
    var host: String
    var username: String
    var password: String
    var name: String
}

struct RedisConfig: Decodable {
    var host: String
    var port: Int
}

func readConfig() -> Config {
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
