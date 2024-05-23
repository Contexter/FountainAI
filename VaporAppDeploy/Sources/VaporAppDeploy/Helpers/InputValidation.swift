import Foundation

func validateProjectDirectory(_ projectDir: String) {
    if projectDir.isEmpty {
        fatalError("Error: Project directory cannot be empty")
    }
}

func validateDomainName(_ domain: String) {
    let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
    if regex.firstMatch(in: domain, options: [], range: NSRange(location: 0, length: domain.count)) == nil {
        fatalError("Error: Invalid domain name")
    }
}

func validateEmail(_ email: String) {
    let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
    if regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) == nil {
        fatalError("Error: Invalid email address")
    }
}
