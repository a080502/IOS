import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let appSession: AppSession
    private let secureStorage = SecureStorageManager()
    private let biometricHelper = BiometricHelper()

    init(appSession: AppSession) {
        self.appSession = appSession
        loadSavedCredentials()
    }
    
    func loadSavedCredentials() {
        if let savedUsername = secureStorage.getUsername() {
            username = savedUsername
        }
    }
    
    var hasSavedCredentials: Bool {
        secureStorage.hasCredentials()
    }
    
    var canUseBiometric: Bool {
        biometricHelper.isBiometricAvailable() && secureStorage.isBiometricEnabled()
    }
    
    var canUsePin: Bool {
        secureStorage.hasPin() && secureStorage.isPinEnabled()
    }

    func login(saveCredentials: Bool = true) async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Inserisci username e password"
            return
        }

        guard ServerConfig.isConfigured else {
            errorMessage = "Configura il server per continuare"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await APIClient.login(
                username: username,
                password: password
            )

            appSession.user = response.user
            appSession.apiToken = response.apiToken
            appSession.sessionId = response.sessionId

            // Persist token/session id in UserDefaults for heartbeat etc.
            let defaults = UserDefaults.standard
            defaults.set(response.apiToken, forKey: "API_TOKEN")
            defaults.set(response.sessionId, forKey: "SESSION_ID")
            
            // Save credentials if requested (as Android does)
            if saveCredentials {
                secureStorage.saveCredentials(username: username, password: password)
            }
            
            // Start heartbeat monitoring (as Android MainActivity does after login)
            appSession.startHeartbeat()
        } catch {
            if let apiError = error as? APIClient.APIError {
                errorMessage = apiError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }
    
    func performBiometricLogin() {
        guard let savedPassword = secureStorage.getPassword() else {
            errorMessage = "Credenziali non salvate"
            return
        }
        
        biometricHelper.authenticate(
            reason: "Usa Face ID per accedere",
            onSuccess: { [weak self] in
                guard let self = self else { return }
                Task {
                    self.password = savedPassword
                    await self.login(saveCredentials: false)
                }
            },
            onError: { [weak self] error in
                self?.errorMessage = error
            },
            onFailed: { [weak self] in
                self?.errorMessage = "Autenticazione biometrica fallita"
            }
        )
    }
    
    func performPinLogin(pin: String) -> Bool {
        guard secureStorage.verifyPin(pin) else {
            return false
        }
        
        guard let savedPassword = secureStorage.getPassword() else {
            errorMessage = "Credenziali non salvate"
            return false
        }
        
        Task {
            password = savedPassword
            await login(saveCredentials: false)
        }
        
        return true
    }
}


