import Foundation

/// Validates the project directory path.
///
/// - Parameter projectDir: The project directory path to validate.
/// - Throws: A fatal error if the project directory is empty.
func validateProjectDirectory(_ projectDir: String) {
    if projectDir.isEmpty {
        fatalError("Error: Project directory cannot be empty")
    }
}

/// Validates the domain name.
///
/// - Parameter domain: The domain name to validate.
/// - Throws: A fatal error if the domain name is invalid.
func validateDomainName(_ domain: String) {
    let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
    if regex.firstMatch(in: domain, options: [], range: NSRange(location: 0, length: domain.count)) == nil {
        fatalError("Error: Invalid domain name")
    }
}

/// Validates the email address.
///
/// - Parameter email: The email address to validate.
/// - Throws: A fatal error if the email address is invalid.
func validateEmail(_ email: String) {
    let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
    if regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) == nil {
        fatalError("Error: Invalid email address")
    }
}
