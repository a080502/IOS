import Foundation

/// Centralized storage for the server base URL (scheme + host + port),
/// mirroring the behaviour of the Android `ServerConfig` object.
enum ServerConfig {
    private static let baseUrlKey = "BASE_URL"
    private static let firstSetupDoneKey = "FIRST_SETUP_DONE"
    private static let companyLogoPathKey = "COMPANY_LOGO_PATH"
    private static let defaults = UserDefaults.standard
    private static let defaultBaseUrl = "https://spazio.crmnoleggio.it"

    static var isConfigured: Bool {
        defaults.string(forKey: baseUrlKey) != nil
    }

    static var isFirstSetupDone: Bool {
        defaults.bool(forKey: firstSetupDoneKey)
    }

    static func markFirstSetupDone() {
        defaults.set(true, forKey: firstSetupDoneKey)
    }

    static var baseUrl: String {
        let stored = defaults.string(forKey: baseUrlKey) ?? defaultBaseUrl
        return stored.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    static func setBaseUrl(_ rawUrl: String) {
        let normalized = normalizeBaseUrl(rawUrl)
        defaults.set(normalized, forKey: baseUrlKey)
    }

    static func buildUrl(path: String) -> URL {
        // Remove /noleggio prefix if present, same logic as Android
        let cleanPath: String
        if path.hasPrefix("/noleggio/") {
            cleanPath = String(path.dropFirst("/noleggio".count))
        } else {
            cleanPath = path
        }

        let normalizedPath = cleanPath.hasPrefix("/") ? cleanPath : "/\(cleanPath)"
        let full = baseUrl + normalizedPath
        guard let url = URL(string: full) else {
            // Fallback to default URL if construction fails
            return URL(string: "https://spazio.crmnoleggio.it")!
        }
        return url
    }

    static func normalizeBaseUrl(_ input: String) -> String {
        var value = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if !value.lowercased().hasPrefix("http://") && !value.lowercased().hasPrefix("https://") {
            value = "https://\(value)"
        }
        return value.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}


