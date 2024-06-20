import Vapor

public func routes(_ app: Application) throws {
    app.post("generate_csound_file", use: generateCsoundFile)
    app.post("generate_lilypond_file", use: generateLilyPondFile)
    app.post("generate_midi_file", use: generateMIDIFile)
    app.post("commit_file", use: commitFile)
    app.post("push_to_github", use: pushToGitHub)
    app.get("list_files", use: listFiles)
    app.get("get_file_content", use: getFileContent)
    app.get("get_file_history", use: getFileHistory)
}
