import Foundation

/// Global session state shared across the SwiftUI app.
final class AppSession: ObservableObject {
    @Published var user: UserData?
    @Published var apiToken: String?
    @Published var sessionId: String?
    @Published var sessionKilled = false
    
    private let heartbeatManager = HeartbeatManager()
    
    var isLoggedIn: Bool {
        apiToken != nil && user != nil
    }
    
    init() {
        // Setup heartbeat callback
        heartbeatManager.onSessionKilled = { [weak self] in
            Task { @MainActor in
                self?.sessionKilled = true
            }
        }
    }
    
    /// Starts heartbeat monitoring (call after successful login)
    func startHeartbeat() {
        heartbeatManager.start(sessionId: sessionId, apiToken: apiToken)
    }
    
    /// Stops heartbeat monitoring (call on logout or app background)
    func stopHeartbeat() {
        heartbeatManager.stop()
    }
    
    /// Clears session data and stops heartbeat
    func clear() {
        stopHeartbeat()
        user = nil
        apiToken = nil
        sessionId = nil
        sessionKilled = false
    }
    
    /// Performs forced logout when session is killed by admin
    /// Clears API token and session ID from UserDefaults (as in Android performForcedLogout)
    func performForcedLogout() {
        // Clear from UserDefaults (as Android does with SharedPreferences)
        UserDefaults.standard.removeObject(forKey: "API_TOKEN")
        UserDefaults.standard.removeObject(forKey: "SESSION_ID")
        
        // Clear session
        clear()
    }
}


