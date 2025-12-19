import SwiftUI

/// Decides whether to show login flow, server setup, or main content.
struct RootView: View {
    @EnvironmentObject private var appSession: AppSession
    @State private var isInitialized = false
    @AppStorage("FIRST_SETUP_DONE") private var isFirstSetupDone = false

    var body: some View {
        Group {
            if !isInitialized {
                ProgressView("Caricamento...")
                    .onAppear {
                        // Small delay to ensure all systems are ready
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isInitialized = true
                        }
                    }
            } else if !isFirstSetupDone {
                NavigationStack {
                    ServerSetupView()
                }
            } else if appSession.isLoggedIn {
                HomeView()
                    .onAppear {
                        // Ensure heartbeat is running when main view appears
                        if !appSession.sessionKilled {
                            appSession.startHeartbeat()
                        }
                    }
                    .onDisappear {
                        // Stop heartbeat when view disappears (app goes to background)
                        appSession.stopHeartbeat()
                    }
                    .alert("⚠️ Sessione Terminata", isPresented: Binding(
                        get: { appSession.sessionKilled },
                        set: { _ in }
                    )) {
                        Button("OK") {
                            appSession.performForcedLogout()
                        }
                    } message: {
                        Text("La tua sessione è stata terminata da un amministratore.\n\nVerrai reindirizzato alla schermata di login.")
                    }
            } else {
                LoginView(appSession: appSession)
            }
        }
    }
}


