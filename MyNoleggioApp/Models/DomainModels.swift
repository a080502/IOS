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

// MARK: - Attrezzature

struct Attrezzatura: Codable, Identifiable {
    let id: Int
    let nome: String
    let codice: String?
    let prezzoGiorno: Double
    let quantitaDisponibile: Int
    let fuoriRevisione: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case nome
        case codice
        case prezzoGiorno = "prezzo_giorno"
        case quantitaDisponibile = "quantita_disponibile"
        case fuoriRevisione = "fuori_revisione"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        nome = try container.decode(String.self, forKey: .nome)
        codice = try? container.decode(String.self, forKey: .codice)
        quantitaDisponibile = try container.decode(Int.self, forKey: .quantitaDisponibile)
        fuoriRevisione = (try? container.decode(Int.self, forKey: .fuoriRevisione)) == 1
        
        // Flexible prezzoGiorno decoding
        if let prezzoDbl = try? container.decode(Double.self, forKey: .prezzoGiorno) {
            prezzoGiorno = prezzoDbl
        } else if let prezzoStr = try? container.decode(String.self, forKey: .prezzoGiorno),
                  let prezzoDbl = Double(prezzoStr) {
            prezzoGiorno = prezzoDbl
        } else {
            prezzoGiorno = 0.0
        }
    }
}

struct AttrezzatureResponseDTO: Codable {
    let success: Bool
    let attrezzature: [Attrezzatura]?
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        numeroNoleggio = try container.decode(String.self, forKey: .numeroNoleggio)
        clienteNome = try container.decode(String.self, forKey: .clienteNome)
        dataInizio = try container.decode(String.self, forKey: .dataInizio)
        dataFine = try container.decode(String.self, forKey: .dataFine)
        stato = try container.decode(String.self, forKey: .stato)
        numArticoli = try container.decode(Int.self, forKey: .numArticoli)
        
        // Flexible totale decoding: accept both String and Double
        if let totaleDouble = try? container.decode(Double.self, forKey: .totale) {
            totale = totaleDouble
        } else if let totaleString = try? container.decode(String.self, forKey: .totale),
                  let totaleDouble = Double(totaleString) {
            totale = totaleDouble
        } else {
            totale = 0.0
        }
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
    let prezzoMovimentazione: Double?

    enum CodingKeys: String, CodingKey {
        case attrezzaturaNome = "attrezzatura_nome"
        case quantita
        case costoGiornaliero = "costo_giornaliero"
        case prezzoMovimentazione = "prezzo_movimentazione"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        attrezzaturaNome = try container.decode(String.self, forKey: .attrezzaturaNome)
        quantita = try container.decode(Int.self, forKey: .quantita)
        
        // Flexible costoGiornaliero parsing
        if let costoDouble = try? container.decode(Double.self, forKey: .costoGiornaliero) {
            costoGiornaliero = costoDouble
        } else if let costoString = try? container.decode(String.self, forKey: .costoGiornaliero),
                  let costoDouble = Double(costoString) {
            costoGiornaliero = costoDouble
        } else {
            costoGiornaliero = 0.0
        }
        
        // Flexible prezzoMovimentazione parsing
        if let prezzoDouble = try? container.decode(Double.self, forKey: .prezzoMovimentazione) {
            prezzoMovimentazione = prezzoDouble
        } else if let prezzoString = try? container.decode(String.self, forKey: .prezzoMovimentazione),
                  let prezzoDouble = Double(prezzoString) {
            prezzoMovimentazione = prezzoDouble
        } else {
            prezzoMovimentazione = nil
        }
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        numeroNoleggio = try container.decode(String.self, forKey: .numeroNoleggio)
        clienteNome = try? container.decode(String.self, forKey: .clienteNome)
        dataInizio = try container.decode(String.self, forKey: .dataInizio)
        dataFinePrevista = try? container.decode(String.self, forKey: .dataFinePrevista)
        dataFineEffettiva = try? container.decode(String.self, forKey: .dataFineEffettiva)
        stato = try container.decode(String.self, forKey: .stato)
        note = try? container.decode(String.self, forKey: .note)
        articoli = try? container.decode([ArticoloDettaglio].self, forKey: .articoli)
        
        // Flexible totalePrevisto parsing
        if let prevDouble = try? container.decode(Double.self, forKey: .totalePrevisto) {
            totalePrevisto = prevDouble
        } else if let prevString = try? container.decode(String.self, forKey: .totalePrevisto),
                  let prevDouble = Double(prevString) {
            totalePrevisto = prevDouble
        } else {
            totalePrevisto = nil
        }
        
        // Flexible totaleFinale parsing
        if let finDouble = try? container.decode(Double.self, forKey: .totaleFinale) {
            totaleFinale = finDouble
        } else if let finString = try? container.decode(String.self, forKey: .totaleFinale),
                  let finDouble = Double(finString) {
            totaleFinale = finDouble
        } else {
            totaleFinale = nil
        }
    }
}

struct NoleggioDettaglioResponseDTO: Codable {
    let success: Bool
    let noleggio: NoleggioDettaglio?
    let dettagli: [ArticoloDettaglio]?
    let message: String?
}