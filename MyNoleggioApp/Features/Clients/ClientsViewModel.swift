import Foundation

@MainActor
final class ClientsViewModel: ObservableObject {
    @Published var state: State = .idle
    @Published var searchQuery: String = ""

    enum State {
        case idle
        case loading
        case success([Cliente])
        case error(String)
    }

    private let appSession: AppSession

    init(appSession: AppSession) {
        self.appSession = appSession
    }

    func loadClients() async {
        await fetchClients(query: "")
    }

    func searchClients(_ query: String) async {
        await fetchClients(query: query)
    }

    private func fetchClients(query: String) async {
        guard let token = appSession.apiToken else {
            state = .error("Token non trovato. Effettua il login.")
            return
        }

        state = .loading

        do {
            let clienti = try await APIClient.fetchClienti(query: query, apiToken: token)
            state = .success(clienti)
        } catch {
            if let apiError = error as? APIClient.APIError {
                state = .error(apiError.localizedDescription)
            } else {
                state = .error(error.localizedDescription)
            }
        }
    }
}


