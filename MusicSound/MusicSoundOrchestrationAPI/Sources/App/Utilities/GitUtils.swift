import Vapor

func shell(_ command: String) throws -> String {
    let process = Process()
    let pipe = Pipe()

    process.standardOutput = pipe
    process.standardError = pipe
    process.arguments = ["-c", command]
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    try process.run()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
}

func gitAddAndCommit(filePath: String, message: String, on req: Request) -> EventLoopFuture<String> {
    return req.eventLoop.future().flatMapThrowing {
        let repoPath = "output"
        if !FileManager.default.fileExists(atPath: "\(repoPath)/.git") {
            try shell("git -C \(repoPath) init")
            try shell("git -C \(repoPath) config user.name \"VaporApp\"")
            try shell("git -C \(repoPath) config user.email \"vapor@app.local\"")
        }
        try shell("git -C \(repoPath) add \(filePath)")
        try shell("git -C \(repoPath) commit -m \"\(message)\"")
        return "Committed \(filePath) with message: \(message)"
    }
}

func gitPush(remote: String, branch: String, on req: Request) -> EventLoopFuture<String> {
    return req.eventLoop.future().flatMapThrowing {
        let repoPath = "output"
        let result = try shell("git -C \(repoPath) push \(remote) \(branch)")
        return "Pushed to \(remote) \(branch): \(result)"
    }
}

extension Array where Element == String {
    func jsonEncodedString() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return String(data: data, encoding: .utf8) ?? "[]"
    }
}
