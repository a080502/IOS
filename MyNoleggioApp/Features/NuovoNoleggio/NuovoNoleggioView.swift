import SwiftUI

struct NuovoNoleggioView: View {
    @EnvironmentObject var session: AppSession
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = NuovoNoleggioViewModel()
    @State private var showClientePicker = false
    @State private var showAttrezzaturaPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                // Sezione Cliente
                Section("Cliente") {
                    if let cliente = viewModel.clienteSelezionato {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(cliente.displayName)
                                    .font(.headline)
                                if let email = cliente.email {
                                    Text(email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Button("Cambia") {
                                showClientePicker = true
                            }
                            .font(.caption)
                        }
                    } else {
                        Button(action: { showClientePicker = true }) {
                            Label("Seleziona Cliente", systemImage: "person.crop.circle.badge.plus")
                        }
                    }
                }
                
                // Sezione Date
                Section("Periodo Noleggio") {
                    DatePicker("Data Inizio", selection: $viewModel.dataInizio, displayedComponents: .date)
                    DatePicker("Data Fine Prevista", selection: $viewModel.dataFinePrevista, displayedComponents: .date)
                }
                
                // Sezione Articoli
                Section {
                    ForEach(viewModel.articoli) { articolo in
                        ArticoloNoleggioRow(articolo: articolo) {
                            viewModel.rimuoviArticolo(articolo)
                        } onQuantityChange: { newQty in
                            viewModel.aggiornaQuantita(articolo, quantita: newQty)
                        }
                    }
                    
                    Button(action: { showAttrezzaturaPicker = true }) {
                        Label("Aggiungi Attrezzatura", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Attrezzature (\(viewModel.articoli.count))")
                } footer: {
                    if !viewModel.articoli.isEmpty {
                        HStack {
                            Text("Totale stimato")
                                .font(.subheadline)
                            Spacer()
                            Text("€\(String(format: "%.2f", viewModel.totaleStimato))")
                                .font(.headline)
                        }
                    }
                }
                
                // Sezione Note
                Section("Note (opzionali)") {
                    TextEditor(text: $viewModel.note)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Nuovo Noleggio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crea") {
                        Task {
                            await viewModel.creaNuovoNoleggio(token: session.authToken ?? "")
                            if viewModel.noleggioCreato {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.puoCreareNoleggio)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showClientePicker) {
                ClientePickerView(selectedCliente: $viewModel.clienteSelezionato)
                    .environmentObject(session)
            }
            .sheet(isPresented: $showAttrezzaturaPicker) {
                AttrezzaturaPickerView { attrezzatura, quantita in
                    viewModel.aggiungiArticolo(attrezzatura, quantita: quantita)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView("Creazione noleggio...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                }
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
                Text("Noleggio creato con successo!")
            }
        }
    }
}

// MARK: - Supporting Views

struct ArticoloNoleggioRow: View {
    let articolo: ArticoloNoleggio
    let onDelete: () -> Void
    let onQuantityChange: (Int) -> Void
    
    @State private var quantita: Int
    
    init(articolo: ArticoloNoleggio, onDelete: @escaping () -> Void, onQuantityChange: @escaping (Int) -> Void) {
        self.articolo = articolo
        self.onDelete = onDelete
        self.onQuantityChange = onQuantityChange
        _quantita = State(initialValue: articolo.quantita)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(articolo.nome)
                        .font(.headline)
                    
                    if let codice = articolo.codice {
                        Text("Cod: \(codice)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            HStack {
                // Stepper quantità
                HStack {
                    Button(action: {
                        if quantita > 1 {
                            quantita -= 1
                            onQuantityChange(quantita)
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(quantita > 1 ? .blue : .gray)
                    }
                    .disabled(quantita <= 1)
                    
                    Text("\(quantita)")
                        .frame(minWidth: 30)
                        .font(.headline)
                    
                    Button(action: {
                        quantita += 1
                        onQuantityChange(quantita)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("€\(String(format: "%.2f", articolo.prezzoGiorno))/gg")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Cliente Picker

struct ClientePickerView: View {
    @EnvironmentObject var session: AppSession
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCliente: Cliente?
    
    @StateObject private var viewModel = ClientsViewModel()
    @State private var searchText = ""
    
    var filteredClienti: [Cliente] {
        if searchText.isEmpty {
            return viewModel.clienti
        }
        return viewModel.clienti.filter { cliente in
            cliente.displayName.localizedCaseInsensitiveContains(searchText) ||
            (cliente.email?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredClienti) { cliente in
                    Button(action: {
                        selectedCliente = cliente
                        dismiss()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cliente.displayName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let email = cliente.email {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Cerca cliente...")
            .navigationTitle("Seleziona Cliente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.load(token: session.authToken ?? "")
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

// MARK: - Attrezzatura Picker (Semplificato)

struct AttrezzaturaPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (AttrezzaturaBase, Int) -> Void
    
    @State private var searchText = ""
    @State private var quantita = 1
    @State private var attrezzature: [AttrezzaturaBase] = []
    
    // Mock data per ora - da sostituire con chiamata API reale
    var body: some View {
        NavigationView {
            VStack {
                Text("Attrezzatura Picker")
                    .font(.headline)
                    .padding()
                
                Text("🚧 Coming Soon")
                    .font(.title)
                    .foregroundColor(.orange)
                
                Text("Per ora, usa il web per aggiungere attrezzature")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Aggiungi Attrezzatura")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Models

struct ArticoloNoleggio: Identifiable {
    let id = UUID()
    let attrezzaturaId: Int
    let nome: String
    let codice: String?
    var quantita: Int
    let prezzoGiorno: Double
}

struct AttrezzaturaBase {
    let id: Int
    let nome: String
    let codice: String?
    let prezzoGiorno: Double
}

// MARK: - ViewModel

@MainActor
class NuovoNoleggioViewModel: ObservableObject {
    @Published var clienteSelezionato: Cliente?
    @Published var dataInizio = Date()
    @Published var dataFinePrevista = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @Published var articoli: [ArticoloNoleggio] = []
    @Published var note = ""
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var noleggioCreato = false
    
    var puoCreareNoleggio: Bool {
        clienteSelezionato != nil && !articoli.isEmpty
    }
    
    var totaleStimato: Double {
        let giorni = Calendar.current.dateComponents([.day], from: dataInizio, to: dataFinePrevista).day ?? 1
        return articoli.reduce(0) { total, articolo in
            total + (Double(articolo.quantita) * articolo.prezzoGiorno * Double(max(giorni, 1)))
        }
    }
    
    func aggiungiArticolo(_ attrezzatura: AttrezzaturaBase, quantita: Int) {
        let articolo = ArticoloNoleggio(
            attrezzaturaId: attrezzatura.id,
            nome: attrezzatura.nome,
            codice: attrezzatura.codice,
            quantita: quantita,
            prezzoGiorno: attrezzatura.prezzoGiorno
        )
        articoli.append(articolo)
    }
    
    func rimuoviArticolo(_ articolo: ArticoloNoleggio) {
        articoli.removeAll { $0.id == articolo.id }
    }
    
    func aggiornaQuantita(_ articolo: ArticoloNoleggio, quantita: Int) {
        if let index = articoli.firstIndex(where: { $0.id == articolo.id }) {
            articoli[index] = ArticoloNoleggio(
                attrezzaturaId: articolo.attrezzaturaId,
                nome: articolo.nome,
                codice: articolo.codice,
                quantita: quantita,
                prezzoGiorno: articolo.prezzoGiorno
            )
        }
    }
    
    func creaNuovoNoleggio(token: String) async {
        guard let clienteId = clienteSelezionato?.id else {
            errorMessage = "Seleziona un cliente"
            showError = true
            return
        }
        
        guard !articoli.isEmpty else {
            errorMessage = "Aggiungi almeno un'attrezzatura"
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            let result = try await APIClient.creaNuovoNoleggio(
                clienteId: clienteId,
                dataInizio: formatDate(dataInizio),
                dataFinePrevista: formatDate(dataFinePrevista),
                articoli: articoli.map { articolo in
                    [
                        "attrezzatura_id": articolo.attrezzaturaId,
                        "quantita": articolo.quantita,
                        "costo_giornaliero": articolo.prezzoGiorno
                    ] as [String : Any]
                },
                note: note.isEmpty ? nil : note,
                apiToken: token
            )
            
            noleggioCreato = true
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
