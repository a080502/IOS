import Foundation
import LocalAuthentication

/// Helper for biometric authentication (Face ID / Touch ID)
/// Replicates Android BiometricHelper functionality
final class BiometricHelper {
    
    enum BiometricStatus {
        case available
        case noHardware
        case hardwareUnavailable
        case noneEnrolled
        case securityUpdateRequired
        case unknownError
    }
    
    private let context = LAContext()
    
    /// Check if biometric authentication is available
    func isBiometricAvailable() -> Bool {
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return canEvaluate && error == nil
    }
    
    /// Get detailed biometric status
    func getBiometricStatus() -> BiometricStatus {
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if canEvaluate {
            return .available
        }
        
        guard let error = error else {
            return .unknownError
        }
        
        switch error.code {
        case LAError.biometryNotAvailable.rawValue:
            return .hardwareUnavailable
        case LAError.biometryNotEnrolled.rawValue:
            return .noneEnrolled
        case LAError.biometryLockout.rawValue:
            return .securityUpdateRequired
        default:
            return .unknownError
        }
    }
    
    /// Show biometric authentication prompt
    func authenticate(
        reason: String = "Usa la tua impronta digitale per accedere",
        onSuccess: @escaping () -> Void,
        onError: @escaping (String) -> Void,
        onFailed: @escaping () -> Void
    ) {
        let context = LAContext()
        context.localizedFallbackTitle = "Usa Password"
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, error in
            DispatchQueue.main.async {
                if success {
                    onSuccess()
                } else if let error = error as? LAError {
                    switch error.code {
                    case .userCancel, .appCancel:
                        // User cancelled, don't show error
                        break
                    case .userFallback:
                        // User chose fallback (password)
                        break
                    default:
                        onError(error.localizedDescription)
                    }
                } else {
                    onFailed()
                }
            }
        }
    }
}

