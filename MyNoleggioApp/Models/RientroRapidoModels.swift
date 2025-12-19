import Foundation

// MARK: - Rientro Rapido Models

struct RientroRapidoDettaglio: Codable, Identifiable {
    let id: Int
    let attrezzaturaId: Int
    let unitaId: Int?
    let quantita: Int
    let statoRiga: String
    let costoGiornaliero: Double
    let dataRientro: String?
    let attrezzaturaNome: String
    let codice: String?
    let matricola: String?
    let numeroSeriale: String?
    let prezzoMovimentazione: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case attrezzaturaId = "attrezzatura_id"
        case unitaId = "unita_id"
        case quantita
        case statoRiga = "stato_riga"
        case costoGiornaliero = "costo_giornaliero"
        case dataRientro = "data_rientro"
        case attrezzaturaNome = "attrezzatura_nome"
        case codice
        case matricola
        case numeroSeriale = "numero_seriale"
        case prezzoMovimentazione = "prezzo_movimentazione"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        attrezzaturaId = try container.decode(Int.self, forKey: .attrezzaturaId)
        unitaId = try? container.decode(Int.self, forKey: .unitaId)
        quantita = try container.decode(Int.self, forKey: .quantita)
        statoRiga = try container.decode(String.self, forKey: .statoRiga)
        dataRientro = try? container.decode(String.self, forKey: .dataRientro)
        attrezzaturaNome = try container.decode(String.self, forKey: .attrezzaturaNome)
        codice = try? container.decode(String.self, forKey: .codice)
        matricola = try? container.decode(String.self, forKey: .matricola)
        numeroSeriale = try? container.decode(String.self, forKey: .numeroSeriale)
        
        // Flexible parsing
        if let val = try? container.decode(Double.self, forKey: .costoGiornaliero) {
            costoGiornaliero = val
        } else if let str = try? container.decode(String.self, forKey: .costoGiornaliero), let val = Double(str) {
            costoGiornaliero = val
        } else {
            costoGiornaliero = 0.0
        }
        
        if let val = try? container.decode(Double.self, forKey: .prezzoMovimentazione) {
            prezzoMovimentazione = val
        } else if let str = try? container.decode(String.self, forKey: .prezzoMovimentazione), let val = Double(str) {
            prezzoMovimentazione = val
        } else {
            prezzoMovimentazione = 0.0
        }
    }
}

struct RientroRapidoNoleggio: Codable {
    let id: Int
    let numeroNoleggio: String
    let clienteNome: String
    let clienteEmail: String?
    let dataInizio: String
    let dataFinePrevista: String?
    let stato: String
    let articoliAttivi: Int
    let articoliRientrati: Int
    let dettagli: [RientroRapidoDettaglio]
    
    enum CodingKeys: String, CodingKey {
        case id
        case numeroNoleggio = "numero_noleggio"
        case clienteNome = "cliente_nome"
        case clienteEmail = "cliente_email"
        case dataInizio = "data_inizio"
        case dataFinePrevista = "data_fine_prevista"
        case stato
        case articoliAttivi = "articoli_attivi"
        case articoliRientrati = "articoli_rientrati"
        case dettagli
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        numeroNoleggio = try container.decode(String.self, forKey: .numeroNoleggio)
        clienteNome = try container.decode(String.self, forKey: .clienteNome)
        clienteEmail = try? container.decode(String.self, forKey: .clienteEmail)
        dataInizio = try container.decode(String.self, forKey: .dataInizio)
        dataFinePrevista = try? container.decode(String.self, forKey: .dataFinePrevista)
        stato = try container.decode(String.self, forKey: .stato)
        dettagli = (try? container.decode([RientroRapidoDettaglio].self, forKey: .dettagli)) ?? []
        
        // Flexible int parsing
        if let val = try? container.decode(Int.self, forKey: .articoliAttivi) {
            articoliAttivi = val
        } else if let str = try? container.decode(String.self, forKey: .articoliAttivi), let val = Int(str) {
            articoliAttivi = val
        } else {
            articoliAttivi = 0
        }
        
        if let val = try? container.decode(Int.self, forKey: .articoliRientrati) {
            articoliRientrati = val
        } else if let str = try? container.decode(String.self, forKey: .articoliRientrati), let val = Int(str) {
            articoliRientrati = val
        } else {
            articoliRientrati = 0
        }
    }
}

struct RientroRapidoResponseDTO: Codable {
    let success: Bool
    let noleggio: RientroRapidoNoleggio?
    let message: String?
}

struct RientroResultDTO: Codable {
    let success: Bool
    let message: String?
    let noleggioId: Int?
    let totaleFinale: Double?
    let emailInviata: Bool?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case noleggioId = "noleggio_id"
        case totaleFinale = "totale_finale"
        case emailInviata = "email_inviata"
    }
}
