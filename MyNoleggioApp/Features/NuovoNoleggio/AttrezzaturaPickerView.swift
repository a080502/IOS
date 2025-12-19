import SwiftUI

struct AttrezzaturaPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel: AttrezzaturaPickerViewModel
    
    let onSelect: (Attrezzatura, Int) -> Void
    
    @State private var searchText = ""
    @State private var selectedAttrezzatura: Attrezzatura?
    @State private var quantita: Int = 1
    
    init(onSelect: @escaping (Attrezzatura, Int) -> Void) {
        self.onSelect = onSelect
        _viewModel = StateObject(wrappedValue: AttrezzaturaPickerViewModel())
    }
    
    var filteredAttrezzature: [Attrezzatura] {
        guard case .success(let attrezzature) = viewModel.state else {
            return []
        }
        
        if searchText.isEmpty {
            return attrezzature
        }
        return attrezzature.filter { attrezzatura in
            attrezzatura.nome.localizedCaseInsensitiveContains(searchText) ||
            (attrezzatura.codice?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Caricamento...")
                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(message)
                            .multilineTextAlignment(.center)
                        Button("Riprova") {
                            Task {
                                await viewModel.load(token: session.apiToken ?? "")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                case .success:
                    if filteredAttrezzature.isEmpty {
                        ContentUnavailableView(
                            "Nessuna attrezzatura trovata",
                            systemImage: "magnifyingglass",
                            description: Text(searchText.isEmpty ? "Nessuna attrezzatura disponibile" : "Prova con altri termini di ricerca")
                        )
                    } else {
                        List(filteredAttrezzature) { attrezzatura in
                            Button {
                                selectedAttrezzatura = attrezzatura
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(attrezzatura.nome)
                                        .font(.headline)
                                    
                                    if let codice = attrezzatura.codice {
                                        Text("Cod: \(codice)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Text("Disponibili: \(attrezzatura.quantitaDisponibile)")
                                            .font(.caption)
                                            .foregroundColor(attrezzatura.quantitaDisponibile > 0 ? .green : .red)
                                        
                                        Spacer()
                                        
                                        Text("€\(String(format: "%.2f", attrezzatura.prezzoGiorno))/giorno")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if attrezzatura.fuoriRevisione {
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                            Text("Fuori revisione")
                                        }
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .disabled(attrezzatura.quantitaDisponibile == 0)
                        }
                    }
                }
            }
            .navigationTitle("Seleziona Attrezzatura")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Cerca per nome o codice")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.load(token: session.apiToken ?? "")
            }
            .sheet(item: $selectedAttrezzatura) { attrezzatura in
                QuantitaPickerView(
                    attrezzatura: attrezzatura,
                    onConfirm: { qty in
                        onSelect(attrezzatura, qty)
                        dismiss()
                    }
                )
            }
        }
    }
}

// MARK: - Quantita Picker

struct QuantitaPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let attrezzatura: Attrezzatura
    let onConfirm: (Int) -> Void
    
    @State private var quantita: Int = 1
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(attrezzatura.nome)
                            .font(.headline)
                        if let codice = attrezzatura.codice {
                            Text("Codice: \(codice)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Text("Disponibili: \(attrezzatura.quantitaDisponibile)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Quantità") {
                    Stepper("\(quantita)", value: $quantita, in: 1...attrezzatura.quantitaDisponibile)
                        .font(.title2)
                }
                
                Section {
                    HStack {
                        Text("Prezzo/giorno:")
                        Spacer()
                        Text("€\(String(format: "%.2f", attrezzatura.prezzoGiorno))")
                    }
                    HStack {
                        Text("Totale stimato:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("€\(String(format: "%.2f", attrezzatura.prezzoGiorno * Double(quantita)))")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Quantità")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aggiungi") {
                        onConfirm(quantita)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class AttrezzaturaPickerViewModel: ObservableObject {
    @Published var state: State = .loading
    
    enum State {
        case loading
        case success([Attrezzatura])
        case error(String)
    }
    
    func load(token: String) async {
        state = .loading
        
        do {
            let attrezzature = try await APIClient.fetchAttrezzature(apiToken: token)
            state = .success(attrezzature)
        } catch {
            if let apiError = error as? APIClient.APIError {
                state = .error(apiError.localizedDescription)
            } else {
                state = .error(error.localizedDescription)
            }
        }
    }
}
