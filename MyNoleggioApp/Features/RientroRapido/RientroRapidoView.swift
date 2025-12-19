import SwiftUI

struct RientroRapidoView: View {
    @EnvironmentObject var session: AppSession
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = RientroRapidoViewModel()
    @State private var showScanner = false
    @State private var showSiglaPrompt = false
    @State private var siglaOperatore = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                if let noleggio = viewModel.noleggioTrovato {
                    dettaglioRientroView(noleggio)
                } else {
                    emptyStateView
                }
                
                if viewModel.isLoading {
                    ProgressView("Caricamento...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .navigationTitle("Rientro Rapido")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showScanner = true }) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                BarcodeScannerView(isPresented: $showScanner) { barcode in
                    Task {
                        await viewModel.cercaNoleggio(barcode: barcode, token: session.apiToken ?? "")
                    }
                }
            }
            .sheet(isPresented: $showSiglaPrompt) {
                siglaPromptView
            }
            .alert("Errore", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Successo", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(viewModel.successMessage)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Scansiona QR Code")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Inquadra il QR code del noleggio per avviare il rientro")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showScanner = true }) {
                Label("Avvia Scanner", systemImage: "qrcode.viewfinder")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Dettaglio Rientro
    
    private func dettaglioRientroView(_ noleggio: RientroRapidoNoleggio) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Noleggio
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Noleggio")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(noleggio.stato.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statoColor(noleggio.stato).opacity(0.2))
                            .foregroundColor(statoColor(noleggio.stato))
                            .cornerRadius(4)
                    }
                    
                    Text(noleggio.numeroNoleggio)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(noleggio.clienteNome)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label(formatDate(noleggio.dataInizio), systemImage: "calendar")
                        Spacer()
                        if let fine = noleggio.dataFinePrevista {
                            Label(formatDate(fine), systemImage: "calendar.badge.clock")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Stats
                HStack(spacing: 16) {
                    StatCardSmall(
                        title: "Attivi",
                        value: "\(noleggio.articoliAttivi)",
                        icon: "cube.box",
                        color: .blue
                    )
                    
                    StatCardSmall(
                        title: "Rientrati",
                        value: "\(noleggio.articoliRientrati)",
                        icon: "checkmark.circle",
                        color: .green
                    )
                }
                
                // Articoli
                VStack(alignment: .leading, spacing: 12) {
                    Text("Articoli da Rientrare")
                        .font(.headline)
                    
                    ForEach(noleggio.dettagli.filter { $0.statoRiga == "attivo" }) { dettaglio in
                        ArticoloRientroRow(
                            dettaglio: dettaglio,
                            isSelected: viewModel.righeSelezionate.contains(dettaglio.id)
                        ) {
                            viewModel.toggleRiga(dettaglio.id)
                        }
                    }
                }
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.selezionaTutto(noleggio.dettagli.filter { $0.statoRiga == "attivo" }.map { $0.id })
                    }) {
                        Label("Seleziona Tutto", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        if viewModel.righeSelezionate.isEmpty {
                            viewModel.errorMessage = "Seleziona almeno un articolo"
                            viewModel.showError = true
                        } else {
                            showSiglaPrompt = true
                        }
                    }) {
                        Label("Procedi con Rientro", systemImage: "arrow.down.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.righeSelezionate.isEmpty ? Color.gray : Color.green)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.righeSelezionate.isEmpty)
                }
                .padding(.top)
            }
            .padding()
        }
    }
    
    // MARK: - Sigla Prompt
    
    private var siglaPromptView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.text.rectangle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Inserisci Sigla Operatore")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                TextField("Sigla (es. AB)", text: $siglaOperatore)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .padding(.horizontal, 40)
                
                Button(action: processaRientro) {
                    Text("Conferma Rientro")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(siglaOperatore.count >= 2 ? Color.green : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(siglaOperatore.count < 2)
                .padding(.horizontal, 40)
            }
            .padding()
            .navigationTitle("Conferma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        showSiglaPrompt = false
                        siglaOperatore = ""
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func processaRientro() {
        guard let noleggio = viewModel.noleggioTrovato else { return }
        
        showSiglaPrompt = false
        
        Task {
            await viewModel.processaRientro(
                noleggioId: noleggio.id,
                sigla: siglaOperatore,
                token: session.apiToken ?? ""
            )
            siglaOperatore = ""
        }
    }
    
    // MARK: - Helpers
    
    private func statoColor(_ stato: String) -> Color {
        switch stato.lowercased() {
        case "attivo": return .blue
        case "parziale": return .orange
        default: return .gray
        }
    }
    
    private func formatDate(_ date: String) -> String {
        // Format: "2024-01-15" -> "15 Gen"
        let components = date.split(separator: "-")
        if components.count == 3 {
            let day = components[2]
            let month = components[1]
            let monthNames = ["Gen", "Feb", "Mar", "Apr", "Mag", "Giu", "Lug", "Ago", "Set", "Ott", "Nov", "Dic"]
            if let monthInt = Int(month), monthInt > 0 && monthInt <= 12 {
                return "\(day) \(monthNames[monthInt - 1])"
            }
        }
        return date
    }
}

// MARK: - Supporting Views

struct StatCardSmall: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct ArticoloRientroRow: View {
    let dettaglio: RientroRapidoDettaglio
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(dettaglio.attrezzaturaNome)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        if let matricola = dettaglio.matricola {
                            Text("Mat. \(matricola)")
                                .font(.caption)
                        }
                        if let codice = dettaglio.codice {
                            Text("• \(codice)")
                                .font(.caption)
                        }
                        Text("• Q.tà \(dettaglio.quantita)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("€\(String(format: "%.2f", dettaglio.costoGiornaliero))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if dettaglio.prezzoMovimentazione > 0 {
                        Text("+€\(String(format: "%.2f", dettaglio.prezzoMovimentazione))")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - ViewModel

@MainActor
class RientroRapidoViewModel: ObservableObject {
    @Published var noleggioTrovato: RientroRapidoNoleggio?
    @Published var righeSelezionate: Set<Int> = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    func cercaNoleggio(barcode: String, token: String) async {
        isLoading = true
        
        do {
            let noleggio = try await APIClient.cercaNoleggioPerBarcode(barcode, apiToken: token)
            noleggioTrovato = noleggio
            
            // Pre-seleziona tutti gli articoli attivi
            righeSelezionate = Set(noleggio.dettagli.filter { $0.statoRiga == "attivo" }.map { $0.id })
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func toggleRiga(_ id: Int) {
        if righeSelezionate.contains(id) {
            righeSelezionate.remove(id)
        } else {
            righeSelezionate.insert(id)
        }
    }
    
    func selezionaTutto(_ ids: [Int]) {
        righeSelezionate = Set(ids)
    }
    
    func processaRientro(noleggioId: Int, sigla: String, token: String) async {
        isLoading = true
        
        do {
            let result = try await APIClient.processaRientro(
                noleggioId: noleggioId,
                sigla: sigla,
                righeIds: Array(righeSelezionate),
                rientroTotale: false,
                apiToken: token
            )
            
            successMessage = result.message ?? "Rientro completato con successo!"
            showSuccess = true
            
            // Reset
            noleggioTrovato = nil
            righeSelezionate.removeAll()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}
