import Foundation

@MainActor
final class RentalDetailViewModel: ObservableObject {
    @Published var state: State = .loading

    enum State {
        case loading
        case success(NoleggioDettaglio)
        case error(String)
    }

    private let appSession: AppSession
    private let noleggioId: Int

    init(appSession: AppSession, noleggioId: Int) {
        self.appSession = appSession
        self.noleggioId = noleggioId
    }

    func load() async {
        guard let token = appSession.apiToken else {
            state = .error("Token non trovato. Effettua il login.")
            return
        }

        guard noleggioId > 0 else {
            state = .error("ID noleggio non valido")
            return
        }

        state = .loading

        do {
            let noleggio = try await APIClient.fetchNoleggioDetail(id: noleggioId, apiToken: token)
            state = .success(noleggio)
        } catch {
            if let apiError = error as? APIClient.APIError {
                state = .error(apiError.localizedDescription)
            } else {
                state = .error(error.localizedDescription)
            }
        }
    }
}

