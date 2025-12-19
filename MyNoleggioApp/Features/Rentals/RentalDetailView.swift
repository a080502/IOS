import SwiftUI

struct RentalDetailView: View {
    @EnvironmentObject private var appSession: AppSession
    @StateObject private var viewModel: RentalDetailViewModel
    @State private var showRientroRapido = false

    init(noleggioId: Int, appSession: AppSession) {
        _viewModel = StateObject(wrappedValue: RentalDetailViewModel(appSession: appSession, noleggioId: noleggioId))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Caricamento dettaglio noleggio...")
            case .error(let message):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(message)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            case .success(let noleggio):
                List {
                    Section("Informazioni noleggio") {
                        HStack {
                            Text("Numero")
                            Spacer()
                            Text(noleggio.numeroNoleggio)
                                .fontWeight(.semibold)
                        }
                        HStack {
                            Text("Cliente")
                            Spacer()
                            Text(noleggio.clienteNome ?? "-")
                        }
                        HStack {
                            Text("Stato")
                            Spacer()
                            Text(noleggio.stato.uppercased())
                                .foregroundColor(colorForStato(noleggio.stato))
                                .fontWeight(.semibold)
                        }
                    }

                    Section("Periodo") {
                        HStack {
                            Text("Data inizio")
                            Spacer()
                            Text(noleggio.dataInizio)
                        }
                        if let dataFinePrevista = noleggio.dataFinePrevista {
                            HStack {
                                Text("Data fine prevista")
                                Spacer()
                                Text(dataFinePrevista)
                            }
                        }
                        if let dataFineEffettiva = noleggio.dataFineEffettiva {
                            HStack {
                                Text("Data fine effettiva")
                                Spacer()
                                Text(dataFineEffettiva)
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    Section("Totale") {
                        if let totalePrevisto = noleggio.totalePrevisto {
                            HStack {
                                Text("Totale previsto")
                                Spacer()
                                Text(String(format: "€ %.2f", totalePrevisto))
                            }
                        }
                        if let totaleFinale = noleggio.totaleFinale {
                            HStack {
                                Text("Totale finale")
                                Spacer()
                                Text(String(format: "€ %.2f", totaleFinale))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        } else if let totalePrevisto = noleggio.totalePrevisto {
                            HStack {
                                Text("Totale finale")
                                Spacer()
                                Text(String(format: "€ %.2f", totalePrevisto))
                                    .fontWeight(.semibold)
                            }
                        }
                    }

                    if let articoli = noleggio.articoli, !articoli.isEmpty {
                        Section("Articoli noleggiati") {
                            ForEach(articoli) { articolo in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(articolo.attrezzaturaNome)
                                        .font(.headline)
                                    HStack {
                                        Text("Quantità: \(articolo.quantita)")
                                        Spacer()
                                        Text(String(format: "€ %.2f/giorno", articolo.costoGiornaliero))
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }

                    if let note = noleggio.note, !note.isEmpty {
                        Section("Note") {
                            Text(note)
                                .font(.body)
                        }
                    }
                    
                    // Azioni rapide per noleggi attivi o parziali
                    if noleggio.stato.lowercased() == "attivo" || noleggio.stato.lowercased() == "parziale" {
                        Section("Azioni") {
                            Button {
                                showRientroRapido = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("Rientro Rapido")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Dettaglio noleggio")
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $showRientroRapido) {
            if case .success(let noleggio) = viewModel.state {
                NavigationStack {
                    RientroRapidoView(initialNoleggio: noleggio)
                        .environmentObject(appSession)
                }
            }
        }
    }

    private func colorForStato(_ stato: String) -> Color {
        switch stato.lowercased() {
        case "attivo":
            return .green
        case "completato":
            return .blue
        case "annullato":
            return .red
        default:
            return .primary
        }
    }
}

