import Foundation

func shell(_ command: String) throws -> String {
    let process = Process()
    let pipe = Pipe()
    
    process.standardOutput = pipe
    process.standardError = pipe
    process.arguments = ["-c", command]
    process.launchPath = "/bin/zsh"
    process.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    
    if process.terminationStatus != 0 {
        let output = String(data: data, encoding: .utf8) ?? ""
        throw NSError(domain: "", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: output])
    }
    
    return String(data: data, encoding: .utf8) ?? ""
}

func gitAddAndCommit(filePath: String, message: String, repoPath: String) throws {
    _ = try shell("git -C \(repoPath) init")
    _ = try shell("git -C \(repoPath) config user.name \"VaporApp\"")
    _ = try shell("git -C \(repoPath) config user.email \"vapor@app.local\"")
    _ = try shell("git -C \(repoPath) add \(filePath)")
    _ = try shell("git -C \(repoPath) commit -m \"\(message)\"")
}
