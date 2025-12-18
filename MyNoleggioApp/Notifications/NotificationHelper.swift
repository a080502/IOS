import Foundation
import UserNotifications

/// Notification helper for iOS
/// Replicates Android NotificationHelper functionality using UserNotifications framework
final class NotificationHelper {
    
    enum NotificationType {
        case revisioni
        case noleggi
        case alert
        
        var identifier: String {
            switch self {
            case .revisioni: return "revisioni_channel"
            case .noleggi: return "noleggi_channel"
            case .alert: return "alerts_channel"
            }
        }
        
        var name: String {
            switch self {
            case .revisioni: return "Revisioni Attrezzature"
            case .noleggi: return "Noleggi Scaduti"
            case .alert: return "Alert Sistema"
            }
        }
        
        var notificationId: Int {
            switch self {
            case .revisioni: return 1001
            case .noleggi: return 1002
            case .alert: return 1003
            }
        }
    }
    
    static let shared = NotificationHelper()
    
    private init() {}
    
    /// Request notification permissions and create channels
    func setup() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            if granted {
                createNotificationCategories()
            }
        } catch {
            print("Failed to request notification permissions: \(error)")
        }
    }
    
    private func createNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        
        // Create categories for different notification types
        let revisioniCategory = UNNotificationCategory(
            identifier: NotificationType.revisioni.identifier,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        let noleggiCategory = UNNotificationCategory(
            identifier: NotificationType.noleggi.identifier,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        let alertCategory = UNNotificationCategory(
            identifier: NotificationType.alert.identifier,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([
            revisioniCategory,
            noleggiCategory,
            alertCategory
        ])
    }
    
    /// Show notification for revisioni
    func showRevisioneNotification(title: String, message: String, count: Int = 0) {
        showNotification(
            type: .revisioni,
            title: title,
            message: message,
            count: count
        )
    }
    
    /// Show notification for noleggi
    func showNoleggioNotification(title: String, message: String, count: Int = 0) {
        showNotification(
            type: .noleggi,
            title: title,
            message: message,
            count: count
        )
    }
    
    /// Show generic alert notification
    func showAlertNotification(title: String, message: String) {
        showNotification(
            type: .alert,
            title: title,
            message: message
        )
    }
    
    private func showNotification(
        type: NotificationType,
        title: String,
        message: String,
        count: Int = 0
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        content.categoryIdentifier = type.identifier
        
        if count > 0 {
            content.badge = NSNumber(value: count)
        }
        
        let request = UNNotificationRequest(
            identifier: "\(type.identifier)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // Immediate notification
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }
    
    /// Cancel all notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    /// Cancel specific notification
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}

