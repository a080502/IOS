import Foundation
import Security

/// Secure storage manager using Keychain
/// Replicates Android SecureStorageManager functionality using Keychain instead of EncryptedSharedPreferences
final class SecureStorageManager {
    
    private let service = "com.mynoleggioapp.secure"
    
    private enum Keys {
        static let username = "username"
        static let password = "password"
        static let pin = "pin"
        static let biometricEnabled = "biometric_enabled"
        static let pinEnabled = "pin_enabled"
        static let quickLoginEnabled = "quick_login_enabled"
    }
    
    // MARK: - Credentials
    
    func saveCredentials(username: String, password: String) {
        saveToKeychain(key: Keys.username, value: username)
        saveToKeychain(key: Keys.password, value: password)
    }
    
    func getUsername() -> String? {
        return getFromKeychain(key: Keys.username)
    }
    
    func getPassword() -> String? {
        return getFromKeychain(key: Keys.password)
    }
    
    func hasCredentials() -> Bool {
        return getUsername() != nil && getPassword() != nil
    }
    
    func clearCredentials() {
        deleteFromKeychain(key: Keys.username)
        deleteFromKeychain(key: Keys.password)
    }
    
    // MARK: - PIN
    
    func savePin(_ pin: String) {
        saveToKeychain(key: Keys.pin, value: pin)
    }
    
    func verifyPin(_ pin: String) -> Bool {
        guard let savedPin = getFromKeychain(key: Keys.pin) else {
            return false
        }
        return savedPin == pin
    }
    
    func hasPin() -> Bool {
        return getFromKeychain(key: Keys.pin) != nil
    }
    
    func removePin() {
        deleteFromKeychain(key: Keys.pin)
    }
    
    // MARK: - Settings (using UserDefaults for boolean flags)
    
    func setBiometricEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.biometricEnabled)
    }
    
    func isBiometricEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.biometricEnabled)
    }
    
    func setPinEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.pinEnabled)
    }
    
    func isPinEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.pinEnabled)
    }
    
    func setQuickLoginEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.quickLoginEnabled)
    }
    
    func isQuickLoginEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.quickLoginEnabled)
    }
    
    func clearAll() {
        clearCredentials()
        removePin()
        UserDefaults.standard.removeObject(forKey: Keys.biometricEnabled)
        UserDefaults.standard.removeObject(forKey: Keys.pinEnabled)
        UserDefaults.standard.removeObject(forKey: Keys.quickLoginEnabled)
    }
    
    // MARK: - Keychain Helpers
    
    private func saveToKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!
        
        // Delete existing item first
        deleteFromKeychain(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Failed to save to keychain: \(status)")
            return
        }
    }
    
    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

