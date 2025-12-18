import SwiftUI

struct ClientDetailView: View {
    @EnvironmentObject private var appSession: AppSession
    @StateObject private var viewModel: ClientDetailViewModel

    init(clienteId: Int, appSession: AppSession) {
        _viewModel = StateObject(wrappedValue: ClientDetailViewModel(appSession: appSession, clienteId: clienteId))
    }

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Caricamento cliente...")
            case .error(let message):
                Text(message)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            case .success(let cliente, let noleggi):
                List {
                    Section("Dettagli cliente") {
                        Text(cliente.displayName)
                            .font(.headline)
                        if let email = cliente.email, !email.isEmpty {
                            Label(email, systemImage: "envelope")
                        }
                        if let telefono = cliente.telefono, !telefono.isEmpty {
                            Label(telefono, systemImage: "phone")
                        }
                        if let citta = cliente.citta, !citta.isEmpty {
                            Label(citta, systemImage: "mappin.and.ellipse")
                        }
                        HStack {
                            Text("Noleggi attivi")
                            Spacer()
                            Text("\(cliente.noleggiAttivi)")
                        }
                        HStack {
                            Text("Totale noleggi")
                            Spacer()
                            Text("\(cliente.totaleNoleggi)")
                        }
                    }

                    Section("Storico noleggi") {
                        if noleggi.isEmpty {
                            Text("Nessun noleggio trovato")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(noleggi) { noleggio in
                                NavigationLink {
                                    RentalDetailView(noleggioId: noleggio.id, appSession: appSession)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Noleggio #\(noleggio.numeroNoleggio)")
                                            .font(.headline)
                                        Text("\(noleggio.dataInizio) → \(noleggio.dataFine)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        HStack {
                                            Text(noleggio.stato.capitalized)
                                            Spacer()
                                            Text(String(format: "€ %.2f", noleggio.totale))
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Cliente")
        .task {
            await viewModel.load()
        }
    }
}


