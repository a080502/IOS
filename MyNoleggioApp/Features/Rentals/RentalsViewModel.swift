import Foundation

@MainActor
final class RentalsViewModel: ObservableObject {
    @Published var state: State = .loading
    @Published var currentFilter: Filter = .active

    enum State {
        case loading
        case success([StoricoNoleggio])
        case error(String)
    }

    enum Filter: String, CaseIterable, Identifiable {
        case all
        case active
        case completed
        case cancelled

        var id: String { rawValue }

        var label: String {
            switch self {
            case .all: return "Tutti"
            case .active: return "Attivi"
            case .completed: return "Completati"
            case .cancelled: return "Annullati"
            }
        }

        var apiValue: String? {
            switch self {
            case .all: return nil
            case .active: return "attivo"
            case .completed: return "completato"
            case .cancelled: return "annullato"
            }
        }
    }

    private let appSession: AppSession

    init(appSession: AppSession) {
        self.appSession = appSession
    }

    func load() async {
        await fetch(filter: currentFilter)
    }

    func applyFilter(_ filter: Filter) async {
        currentFilter = filter
        await fetch(filter: filter)
    }

    private func fetch(filter: Filter) async {
        guard let token = appSession.apiToken else {
            state = .error("Token non trovato. Effettua il login.")
            return
        }

        state = .loading

        do {
            let list = try await APIClient.fetchStoricoNoleggi(
                filter: filter.apiValue,
                limit: 50,
                apiToken: token
            )
            state = .success(list)
        } catch {
            if let apiError = error as? APIClient.APIError {
                state = .error(apiError.localizedDescription)
            } else {
                state = .error(error.localizedDescription)
            }
        }
    }
}


