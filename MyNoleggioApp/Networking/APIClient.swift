import Foundation

/// Simple API client that talks to the existing PHP backend using JSON,
/// reproducing the logic of the Android `LoginActivity.performLogin`.
struct APIClient {
    enum APIError: Error, LocalizedError {
        case invalidResponse
        case httpError(Int)
        case serverMessage(String)

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Risposta del server non valida"
            case .httpError(let code):
                return "Errore server: \(code)"
            case .serverMessage(let message):
                return message
            }
        }
    }

    static func login(
        username: String,
        password: String,
        appVersion: String = "2.0"
    ) async throws -> LoginResponse {
        let url = ServerConfig.buildUrl(path: "/noleggio/api/login.php")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "identifier": username,
            "password": password,
            "tipo_accesso": "app",
            "versione_app": appVersion
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard http.statusCode == 200 else {
            throw APIError.httpError(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)

        if !decoded.success {
            throw APIError.serverMessage(decoded.error ?? "Login fallito")
        }

        return decoded
    }
    
    /// Checks if the current session is still valid (heartbeat)
    static func heartbeat(sessionId: String?, apiToken: String?) async throws -> HeartbeatResponse {
        var components = URLComponents(url: ServerConfig.buildUrl(path: "/noleggio/api/sessioni_online.php"), resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "action", value: "heartbeat")]
        
        if let sessionId = sessionId {
            queryItems.append(URLQueryItem(name: "session_id", value: sessionId))
        }
        if let apiToken = apiToken {
            queryItems.append(URLQueryItem(name: "api_token", value: apiToken))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw APIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard http.statusCode == 200 else {
            throw APIError.httpError(http.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(HeartbeatResponse.self, from: data)
        return decoded
    }

    // MARK: - Clienti

    static func fetchClienti(query: String? = nil, apiToken: String?) async throws -> [Cliente] {
        var path = "/noleggio/api/clienti.php"
        if let query, !query.isEmpty {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            path += "?search=\(encoded)"
        }

        var request = URLRequest(url: ServerConfig.buildUrl(path: path))
        request.httpMethod = "GET"
        if let apiToken {
            request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard http.statusCode == 200 else {
            throw APIError.httpError(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(ClientiResponseDTO.self, from: data)
        if decoded.success {
            return decoded.data ?? []
        } else {
            throw APIError.serverMessage(decoded.error ?? "Errore nel caricamento clienti")
        }
    }

    static func fetchClienteDetail(id: Int, apiToken: String?) async throws -> (Cliente, [StoricoNoleggio]) {
        let path = "/noleggio/api/clienti.php?id=\(id)&detail=true"
        var request = URLRequest(url: ServerConfig.buildUrl(path: path))
        request.httpMethod = "GET"
        if let apiToken {
            request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard http.statusCode == 200 else {
            throw APIError.httpError(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(ClienteDetailResponseDTO.self, from: data)
        if decoded.success, let cliente = decoded.cliente {
            return (cliente, decoded.noleggi ?? [])
        } else {
            throw APIError.serverMessage(decoded.error ?? "Cliente non trovato")
        }
    }

    // MARK: - Storico Noleggi

    static func fetchStoricoNoleggi(filter: String? = nil, limit: Int = 50, apiToken: String) async throws -> [StoricoNoleggio] {
        var query = "limit=\(limit)"
        if let filter, !filter.isEmpty {
            query += "&stato=\(filter)"
        }

        let path = "/noleggio/api/storico_noleggi.php?\(query)"
        var request = URLRequest(url: ServerConfig.buildUrl(path: path))
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard http.statusCode == 200 else {
            throw APIError.httpError(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(StoricoResponseDTO.self, from: data)
        if decoded.success, let list = decoded.noleggi {
            return list
        } else {
            // Coerente con ViewModel Android: restituisce lista vuota con messaggio
            return []
        }
    }

    // MARK: - Dettaglio Noleggio

    static func fetchNoleggioDetail(id: Int, apiToken: String) async throws -> NoleggioDettaglio {
        let path = "/noleggio/api/noleggi.php?id=\(id)"
        var request = URLRequest(url: ServerConfig.buildUrl(path: path))
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard http.statusCode == 200 else {
            throw APIError.httpError(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(NoleggioDettaglioResponseDTO.self, from: data)
        
        if decoded.success, var noleggio = decoded.noleggio {
            // Merge dettagli articoli nel noleggio (come fa Android)
            noleggio = NoleggioDettaglio(
                id: noleggio.id,
                numeroNoleggio: noleggio.numeroNoleggio,
                clienteNome: noleggio.clienteNome,
                dataInizio: noleggio.dataInizio,
                dataFinePrevista: noleggio.dataFinePrevista,
                dataFineEffettiva: noleggio.dataFineEffettiva,
                stato: noleggio.stato,
                totalePrevisto: noleggio.totalePrevisto,
                totaleFinale: noleggio.totaleFinale,
                note: noleggio.note,
                articoli: decoded.dettagli ?? noleggio.articoli
            )
            return noleggio
        } else {
            throw APIError.serverMessage(decoded.message ?? "Noleggio non trovato")
        }
    }
}


