import Foundation
import Combine

/// Manages periodic heartbeat checks to verify session validity.
/// Replicates the logic from Android MainActivity.checkSession() and heartbeatHandler.
final class HeartbeatManager: ObservableObject {
    private var heartbeatTask: Task<Void, Never>?
    private var isRunning = false
    
    // First check after 15 seconds, then every 30 seconds (as in Android)
    private let initialDelay: TimeInterval = 15.0
    private let heartbeatInterval: TimeInterval = 30.0
    
    /// Callback when session is killed by admin
    var onSessionKilled: (() -> Void)?
    
    /// Starts heartbeat monitoring. Should be called when user logs in.
    func start(sessionId: String?, apiToken: String?) {
        guard !isRunning else { return }
        isRunning = true
        
        heartbeatTask = Task { [weak self] in
            guard let self = self else { return }
            
            // First check after initial delay (15 seconds)
            try? await Task.sleep(nanoseconds: UInt64(self.initialDelay * 1_000_000_000))
            
            // Then check periodically
            while !Task.isCancelled && self.isRunning {
                await self.checkSession(sessionId: sessionId, apiToken: apiToken)
                
                // Wait before next check
                try? await Task.sleep(nanoseconds: UInt64(self.heartbeatInterval * 1_000_000_000))
            }
        }
    }
    
    /// Stops heartbeat monitoring. Should be called on logout or when app goes to background.
    func stop() {
        isRunning = false
        heartbeatTask?.cancel()
        heartbeatTask = nil
    }
    
    private func checkSession(sessionId: String?, apiToken: String?) async {
        guard isRunning else { return }
        
        do {
            let response = try await APIClient.heartbeat(sessionId: sessionId, apiToken: apiToken)
            
            if !response.success {
                // Session killed by admin
                await MainActor.run {
                    self.stop()
                    self.onSessionKilled?()
                }
            }
            // If success, continue with next check (handled by loop)
        } catch {
            // On error, continue checking (as in Android - retry after interval)
            // The loop will continue and retry after heartbeatInterval
        }
    }
}

