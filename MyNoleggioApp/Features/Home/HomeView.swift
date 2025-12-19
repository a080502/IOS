import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appSession: AppSession
    @State private var showScanner = false
    @State private var showSettings = false
    @State private var showRientroRapido = false
    @State private var showNuovoNoleggio = false
    @State private var noleggioAttivi = "—"
    @State private var scadenze = "—"
    @State private var clientiTotali = "—"
    @State private var attrezzature = "—"
    @State private var isLoadingStats = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header con benvenuto
                    headerSection
                    
                    // Card statistiche rapide
                    statsSection
                    
                    // Menu principale
                    mainMenuSection
                    
                    // Azioni rapide
                    quickActionsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("MyNoleggio")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                BarcodeScannerView(isPresented: $showScanner) { code in
                    handleScannedCode(code)
                }
            }
            .sheet(isPresented: $showRientroRapido) {
                RientroRapidoView()
                    .environmentObject(appSession)
            }
            .sheet(isPresented: $showNuovoNoleggio) {
                NuovoNoleggioView()
                    .environmentObject(appSession)
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView()
                }
            }
            .onAppear {
                Task {
                    await loadDashboardStats()
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let user = appSession.user {
                Text("Ciao, \(user.nome) 👋")
                    .font(.title.bold())
                
                HStack {
                    Label(user.ruolo, systemImage: "person.badge.shield.checkmark")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let filiale = user.filiale {
                        Divider()
                            .frame(height: 12)
                        Label(filiale, systemImage: "building.2")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        VStack(spacing: 12) {
            Text("Panoramica")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Noleggi Attivi",
                    value: noleggioAttivi,
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "In Scadenza",
                    value: scadenze,
                    icon: "clock.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Clienti Totali",
                    value: clientiTotali,
                    icon: "person.3.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Attrezzature",
                    value: attrezzature,
                    icon: "wrench.and.screwdriver.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Main Menu Section
    
    private var mainMenuSection: some View {
        VStack(spacing: 12) {
            Text("Menu Principale")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                MenuButton(
                    title: "Clienti",
                    subtitle: "Gestisci anagrafica clienti",
                    icon: "person.2.fill",
                    color: .blue
                ) {
                    ClientsListView(appSession: appSession)
                }
                
                MenuButton(
                    title: "Noleggi",
                    subtitle: "Visualizza e gestisci noleggi",
                    icon: "doc.text.fill",
                    color: .green
                ) {
                    RentalsListView(appSession: appSession)
                }
                
                MenuButton(
                    title: "Prenotazioni",
                    subtitle: "Gestisci prenotazioni",
                    icon: "calendar.badge.clock",
                    color: .orange,
                    comingSoon: true
                )
                
                MenuButton(
                    title: "Magazzino",
                    subtitle: "Inventario attrezzature",
                    icon: "shippingbox.fill",
                    color: .purple,
                    comingSoon: true
                )
                
                MenuButton(
                    title: "Reports",
                    subtitle: "Statistiche e reports",
                    icon: "chart.bar.fill",
                    color: .pink,
                    comingSoon: true
                )
            }
        }
    }
    
    // MARK: - Quick Actions Section
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Azioni Rapide")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Scanner",
                    icon: "qrcode.viewfinder",
                    color: .blue
                ) {
                    showScanner = true
                }
                
                QuickActionButton(
                    title: "Rientro Rapido",
                    icon: "arrow.down.circle.fill",
                    color: .green
                ) {
                    showRientroRapido = true
                }
                
                QuickActionButton(
                    title: "Nuovo Noleggio",
                    icon: "plus.circle.fill",
                    color: .orange
                ) {
                    showNuovoNoleggio = true
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadDashboardStats() async {
        guard let token = appSession.apiToken else { 
            print("❌ No API token available")
            return 
        }
        isLoadingStats = true
        
        print("📊 Loading dashboard stats...")
        
        do {
            // Fetch storico noleggi to count active ones
            print("🔄 Fetching noleggi attivi...")
            let noleggi = try await APIClient.fetchStoricoNoleggi(filter: "attivo", limit: 100, apiToken: token)
            noleggioAttivi = "\(noleggi.count)"
            print("✅ Noleggi attivi: \(noleggi.count)")
            
            // Count scadenze (noleggi attivi con data fine entro 7 giorni)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let today = Date()
            let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: today)!
            
            let scadenzeCount = noleggi.filter { noleggio in
                guard let dataFine = dateFormatter.date(from: noleggio.dataFine) else { return false }
                return dataFine >= today && dataFine <= weekFromNow
            }.count
            scadenze = "\(scadenzeCount)"
            print("✅ Scadenze: \(scadenzeCount)")
            
            // Fetch clienti to count total
            print("🔄 Fetching clienti...")
            let clienti = try await APIClient.fetchClienti(query: nil, apiToken: token)
            clientiTotali = "\(clienti.count)"
            print("✅ Clienti totali: \(clienti.count)")
            
            // For now, set attrezzature as placeholder (would need specific API)
            attrezzature = "N/D"
        } catch {
            // On error, keep "—" values
            print("❌ Error loading dashboard stats: \(error)")
            if let apiError = error as? APIClient.APIError {
                print("   API Error: \(apiError.localizedDescription)")
            }
        }
        
        isLoadingStats = false
        print("📊 Dashboard stats loading complete")
    }
    
    private func handleScannedCode(_ code: String) {
        // TODO: Gestire codice scansionato
        print("📱 Scanned code: \(code)")
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MenuButton<Destination: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var comingSoon: Bool = false
    var destination: (() -> Destination)?
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        comingSoon: Bool = false,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.comingSoon = comingSoon
        self.destination = destination
    }
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        comingSoon: Bool = false
    ) where Destination == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.comingSoon = comingSoon
        self.destination = nil
    }
    
    var body: some View {
        Group {
            if comingSoon {
                buttonContent
                    .opacity(0.6)
            } else if let destination = destination {
                NavigationLink(destination: destination) {
                    buttonContent
                }
            }
        }
    }
    
    private var buttonContent: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if comingSoon {
                        Text("Presto")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !comingSoon {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    var comingSoon: Bool = false
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                
                if comingSoon {
                    Text("Presto")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .disabled(comingSoon)
        .opacity(comingSoon ? 0.6 : 1)
    }
}

struct SettingsView: View {
    @EnvironmentObject private var appSession: AppSession
    @Environment(\.dismiss) private var dismiss
    @AppStorage("BASE_URL") private var baseUrl: String = ""
    @State private var showServerSetup = false
    
    var body: some View {
        List {
            Section("Account") {
                if let user = appSession.user {
                    LabeledContent("Nome", value: user.nome)
                    LabeledContent("Ruolo", value: user.ruolo)
                    if let filiale = user.filiale {
                        LabeledContent("Filiale", value: filiale)
                    }
                }
            }
            
            Section("Server") {
                LabeledContent("URL", value: baseUrl)
                
                Button("Modifica configurazione server") {
                    showServerSetup = true
                }
            }
            
            Section("App") {
                LabeledContent("Versione", value: "2.0 iOS")
                LabeledContent("Build", value: "1")
            }
            
            Section {
                Button(role: .destructive) {
                    appSession.performForcedLogout()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Logout")
                    }
                }
            }
        }
        .navigationTitle("Impostazioni")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Fine") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showServerSetup) {
            NavigationStack {
                ServerSetupView()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppSession())
}
