import Vapor

func routes(_ app: Application) throws {
    app.post("generate_midi_file", use: generateMIDIFile)
    app.post("commit_file", use: commitFileHandler)
    app.post("push_to_github", use: pushToGitHubHandler)
}
