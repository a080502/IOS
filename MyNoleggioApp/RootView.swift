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
                MainPlaceholderView()
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

/// Temporary placeholder for the main home once client/rental lists are implemented.
struct MainPlaceholderView: View {
    @EnvironmentObject private var appSession: AppSession

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Home iOS")
                            .font(.largeTitle.bold())
                        if let user = appSession.user {
                            Text("Ciao, \(user.nome)")
                                .font(.title2)
                            Text("Ruolo: \(user.ruolo) | Filiale: \(user.filiale ?? "-")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Navigazione") {
                    NavigationLink("Clienti") {
                        ClientsListView(appSession: appSession)
                    }
                    NavigationLink("Storico noleggi") {
                        RentalsListView(appSession: appSession)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        appSession.performForcedLogout()
                    } label: {
                        Text("Logout")
                    }
                }
            }
            .navigationTitle("Home")
        }
    }
}


