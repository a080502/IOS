import SwiftUI

struct RentalsListView: View {
    @EnvironmentObject private var appSession: AppSession
    @StateObject private var viewModel: RentalsViewModel

    init(appSession: AppSession) {
        _viewModel = StateObject(wrappedValue: RentalsViewModel(appSession: appSession))
    }

    var body: some View {
        List {
            switch viewModel.state {
            case .loading:
                Section {
                    HStack {
                        Spacer()
                        ProgressView("Caricamento noleggi...")
                        Spacer()
                    }
                }
            case .error(let message):
                Section {
                    Text(message)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            case .success(let noleggi):
                if noleggi.isEmpty {
                    Section {
                        Text("Nessun noleggio trovato")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                } else {
                    Section {
                        ForEach(noleggi) { noleggio in
                            NavigationLink {
                                RentalDetailView(noleggioId: noleggio.id, appSession: appSession)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Noleggio #\(noleggio.numeroNoleggio)")
                                        .font(.headline)
                                    Text(noleggio.clienteNome)
                                        .font(.subheadline)
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
        .navigationTitle("Storico noleggi")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(RentalsViewModel.Filter.allCases) { filter in
                        Button {
                            Task { await viewModel.applyFilter(filter) }
                        } label: {
                            if filter == viewModel.currentFilter {
                                Label(filter.label, systemImage: "checkmark")
                            } else {
                                Text(filter.label)
                            }
                        }
                    }
                } label: {
                    Text(viewModel.currentFilter.label)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}


