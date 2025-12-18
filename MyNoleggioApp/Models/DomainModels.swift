import Foundation

// MARK: - Clienti

struct Cliente: Codable, Identifiable {
    let id: Int
    let nome: String?
    let cognome: String?
    let ragioneSociale: String?
    let codiceFiscale: String?
    let partitaIva: String?
    let telefono: String?
    let email: String?
    let citta: String?
    let noleggiAttivi: Int
    let totaleNoleggi: Int

    enum CodingKeys: String, CodingKey {
        case id
        case nome
        case cognome
        case ragioneSociale = "ragione_sociale"
        case codiceFiscale = "codice_fiscale"
        case partitaIva = "partita_iva"
        case telefono
        case email
        case citta
        case noleggiAttivi
        case totaleNoleggi
    }

    var displayName: String {
        if let ragioneSociale, !ragioneSociale.isEmpty {
            return ragioneSociale
        }
        let fullName = [nome, cognome].compactMap { $0 }.joined(separator: " ")
        return fullName.isEmpty ? "Cliente #\(id)" : fullName
    }
}

struct ClientiResponseDTO: Codable {
    let success: Bool
    let data: [Cliente]?
    let error: String?
}

struct ClienteDetailResponseDTO: Codable {
    let success: Bool
    let cliente: Cliente?
    let noleggi: [StoricoNoleggio]?
    let error: String?
}

// MARK: - Storico Noleggi

struct StoricoNoleggio: Codable, Identifiable {
    let id: Int
    let numeroNoleggio: String
    let clienteNome: String
    let dataInizio: String
    let dataFine: String
    let stato: String
    let totale: Double
    let numArticoli: Int

    enum CodingKeys: String, CodingKey {
        case id
        case numeroNoleggio = "numero_noleggio"
        case clienteNome = "cliente_nome"
        case dataInizio = "data_inizio"
        case dataFine = "data_fine"
        case stato
        case totale
        case numArticoli = "num_articoli"
    }
}

struct StoricoResponseDTO: Codable {
    let success: Bool
    let noleggi: [StoricoNoleggio]?
    let message: String?
}
 
// MARK: - Dettaglio Noleggio

struct ArticoloDettaglio: Codable, Identifiable {
    var id: String { "\(attrezzaturaNome)-\(quantita)-\(costoGiornaliero)" }

    let attrezzaturaNome: String
    let quantita: Int
    let costoGiornaliero: Double

    enum CodingKeys: String, CodingKey {
        case attrezzaturaNome = "attrezzatura_nome"
        case quantita
        case costoGiornaliero = "costo_giornaliero"
    }
}

struct NoleggioDettaglio: Codable, Identifiable {
    let id: Int
    let numeroNoleggio: String
    let clienteNome: String?
    let dataInizio: String
    let dataFinePrevista: String?
    let dataFineEffettiva: String?
    let stato: String
    let totalePrevisto: Double?
    let totaleFinale: Double?
    let note: String?
    let articoli: [ArticoloDettaglio]?

    enum CodingKeys: String, CodingKey {
        case id
        case numeroNoleggio = "numero_noleggio"
        case clienteNome = "cliente_nome"
        case dataInizio = "data_inizio"
        case dataFinePrevista = "data_fine_prevista"
        case dataFineEffettiva = "data_fine_effettiva"
        case stato
        case totalePrevisto = "totale_previsto"
        case totaleFinale = "totale_finale"
        case note
        case articoli
    }
}

struct NoleggioDettaglioResponseDTO: Codable {
    let success: Bool
    let noleggio: NoleggioDettaglio?
    let dettagli: [ArticoloDettaglio]?
    let message: String?
}