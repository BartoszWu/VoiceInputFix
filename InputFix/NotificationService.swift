import Foundation
import UserNotifications

/// Shared notification dispatch — both the audio lock and the Bluetooth
/// display-sleep release honor the same preferences toggle.
enum Notifier {
    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    static func send(title: String, body: String) {
        guard isEnabled else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
