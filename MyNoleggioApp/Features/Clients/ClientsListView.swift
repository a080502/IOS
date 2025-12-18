import SwiftUI

struct ClientsListView: View {
    @EnvironmentObject private var appSession: AppSession
    @StateObject private var viewModel: ClientsViewModel

    @State private var selectedCliente: Cliente?
    @State private var showDetail = false

    init(appSession: AppSession) {
        _viewModel = StateObject(wrappedValue: ClientsViewModel(appSession: appSession))
    }

    var body: some View {
        List {
            switch viewModel.state {
            case .idle, .loading:
                Section {
                    HStack {
                        Spacer()
                        ProgressView("Caricamento clienti...")
                        Spacer()
                    }
                }
            case .error(let message):
                Section {
                    Text(message)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            case .success(let clienti):
                if clienti.isEmpty {
                    Section {
                        Text("Nessun cliente trovato")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                } else {
                    ForEach(clienti) { cliente in
                        Button {
                            selectedCliente = cliente
                            showDetail = true
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cliente.displayName)
                                    .font(.headline)
                                if let email = cliente.email, !email.isEmpty {
                                    Text(email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                if let telefono = cliente.telefono, !telefono.isEmpty {
                                    Text(telefono)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                HStack(spacing: 12) {
                                    Text("\(cliente.noleggiAttivi) attivi")
                                    Text("\(cliente.totaleNoleggi) totali")
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
        .navigationTitle("Clienti")
        .searchable(text: $viewModel.searchQuery, prompt: "Cerca clienti")
        .onSubmit(of: .search) {
            Task {
                await viewModel.searchClients(viewModel.searchQuery)
            }
        }
        .onChange(of: viewModel.searchQuery) { _, newValue in
            Task {
                await viewModel.searchClients(newValue)
            }
        }
        .task {
            await viewModel.loadClients()
        }
        .background(
            NavigationLink(
                isActive: $showDetail,
                destination: {
                    if let selectedCliente {
                        ClientDetailView(clienteId: selectedCliente.id, appSession: appSession)
                    } else {
                        EmptyView()
                    }
                },
                label: { EmptyView() }
            )
        )
    }
}


