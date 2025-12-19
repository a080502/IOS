import SwiftUI

@main
struct MyNoleggioApp: App {
    @StateObject private var appSession = AppSession()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Prevent crashes on launch
        #if DEBUG
        print("🚀 App initialized")
        #endif
        
        // Setup notifications on app launch (replicates Android NotificationHelper.createNotificationChannels)
        Task {
            do {
                await NotificationHelper.shared.setup()
            } catch {
                #if DEBUG
                print("⚠️ Notification setup failed: \(error.localizedDescription)")
                #endif
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appSession)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    // Handle app lifecycle: restart heartbeat when app comes to foreground
                    // (replicates Android MainActivity.onResume/onPause behavior)
                    if newPhase == .active && appSession.isLoggedIn && !appSession.sessionKilled {
                        appSession.startHeartbeat()
                    } else if newPhase == .background || newPhase == .inactive {
                        appSession.stopHeartbeat()
                    }
                }
        }
    }
}


