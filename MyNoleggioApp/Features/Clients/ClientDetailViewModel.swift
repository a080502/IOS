import Foundation

@MainActor
final class ClientDetailViewModel: ObservableObject {
    @Published var state: State = .loading

    enum State {
        case loading
        case success(cliente: Cliente, noleggi: [StoricoNoleggio])
        case error(String)
    }

    private let appSession: AppSession
    private let clienteId: Int

    init(appSession: AppSession, clienteId: Int) {
        self.appSession = appSession
        self.clienteId = clienteId
    }

    func load() async {
        guard let token = appSession.apiToken else {
            state = .error("Token non trovato. Effettua il login.")
            return
        }

        state = .loading

        do {
            let (cliente, noleggi) = try await APIClient.fetchClienteDetail(id: clienteId, apiToken: token)
            state = .success(cliente: cliente, noleggi: noleggi)
        } catch {
            if let apiError = error as? APIClient.APIError {
                state = .error(apiError.localizedDescription)
            } else {
                state = .error(error.localizedDescription)
            }
        }
    }
}


