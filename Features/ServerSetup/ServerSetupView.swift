import SwiftUI

struct ServerSetupView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var host: String = ""
    @State private var port: String = ""
    @State private var useHttps: Bool = true
    @State private var errorHost: String?
    @State private var errorPort: String?

    var body: some View {
        Form {
            Section("Server") {
                TextField("Host (es. tuo-server.it)", text: $host)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if let errorHost {
                    Text(errorHost)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                TextField("Porta (opzionale)", text: $port)
                    .keyboardType(.numberPad)

                if let errorPort {
                    Text(errorPort)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Toggle("Usa HTTPS", isOn: $useHttps)

                Text("URL risultante: \(exampleUrl)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Section {
                Button("Salva configurazione") {
                    saveConfiguration()
                }
            }
        }
        .navigationTitle("Configurazione server")
        .onAppear(perform: populateCurrentValues)
    }

    private var exampleUrl: String {
        let hostValue = host.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "tuo-server.it"
            : host.trimmingCharacters(in: .whitespacesAndNewlines)
        let scheme = useHttps ? "https" : "http"

        if !port.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(scheme)://\(hostValue):\(port)"
        } else {
            let standardPort = useHttps ? 443 : 80
            return "\(scheme)://\(hostValue) (porta standard: \(standardPort))"
        }
    }

    private func populateCurrentValues() {
        if ServerConfig.isConfigured {
            let base = ServerConfig.baseUrl
            if let url = URL(string: base) {
                host = url.host ?? ""
                if let portNumber = url.port {
                    port = String(portNumber)
                }
                useHttps = (url.scheme?.lowercased() == "https")
            }
        } else {
            host = ""
            port = ""
            useHttps = true
        }
    }

    private func saveConfiguration() {
        errorHost = nil
        errorPort = nil

        var hostValue = host.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !hostValue.isEmpty else {
            errorHost = "Campo obbligatorio"
            return
        }

        // Rimuovi schema e porta come in Android
        hostValue = hostValue
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")

        var providedPort: String?
        if let idx = hostValue.firstIndex(of: ":") {
            providedPort = String(hostValue[hostValue.index(after: idx)...])
            hostValue = String(hostValue[..<idx])
        }

        hostValue = hostValue.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()

        guard !hostValue.isEmpty else {
            errorHost = "Indirizzo non valido"
            return
        }

        var portText = port.trimmingCharacters(in: .whitespacesAndNewlines)
        if portText.isEmpty {
            portText = providedPort ?? ""
        }

        let scheme = useHttps ? "https" : "http"
        let baseUrl: String

        if !portText.isEmpty {
            guard let portValue = Int(portText), (1...65535).contains(portValue) else {
                errorPort = "Porta non valida (1-65535) o lascia vuota per porta standard"
                return
            }
            baseUrl = "\(scheme)://\(hostValue):\(portValue)"
        } else {
            baseUrl = "\(scheme)://\(hostValue)"
        }

        ServerConfig.setBaseUrl(baseUrl)
        ServerConfig.markFirstSetupDone()
        dismiss()
    }
}

struct ServerSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ServerSetupView()
        }
    }
}


