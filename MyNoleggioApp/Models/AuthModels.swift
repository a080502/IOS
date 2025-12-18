import Foundation

/// Mirrors the Android `UserData` data class for compatibility with the existing backend.
struct UserData: Codable, Identifiable {
    let id: Int
    let nome: String
    let ruolo: String
    let azienda: String
    let aziendaLogo: String?
    let filiale: String?

    enum CodingKeys: String, CodingKey {
        case id
        case nome
        case ruolo
        case azienda
        case aziendaLogo = "azienda_logo"
        case filiale
    }
}

/// Mirrors the Android `LoginResponse` data class.
struct LoginResponse: Codable {
    let success: Bool
    let error: String?
    let user: UserData?
    let sessionId: String?
    let apiToken: String?

    enum CodingKeys: String, CodingKey {
        case success
        case error
        case user
        case sessionId = "session_id"
        case apiToken = "api_token"
    }
}

/// Heartbeat API response (session check) - mirrors Android HeartbeatResponse
struct HeartbeatResponse: Codable {
    let success: Bool
    let message: String?
}


