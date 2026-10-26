import Foundation
import UserNotifications

public final class NotificationService {
    public static let shared = NotificationService()

    private var hasNotifiedForThreshold: Bool = false
    private var lastNotifiedThreshold: Int = 0

    private init() {
        requestAuthorization()
    }

    public func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification auth error: \(error)")
            }
        }
    }

    public func checkAndNotify(totalTokens: Int, threshold: Int, model: String) {
        guard totalTokens > threshold else {
            // Reset if tokens were cleared
            if totalTokens < threshold / 2 {
                hasNotifiedForThreshold = false
                lastNotifiedThreshold = 0
            }
            return
        }

        // Only notify once per threshold crossing
        if !hasNotifiedForThreshold || threshold != lastNotifiedThreshold {
            hasNotifiedForThreshold = true
            lastNotifiedThreshold = threshold

            sendThresholdNotification(totalTokens: totalTokens, threshold: threshold, model: model)
        }
    }

    private func sendThresholdNotification(totalTokens: Int, threshold: Int, model: String) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Use Token Bar: Limite de Tokens Atingido"
        content.subtitle = "IA: \(model)"
        content.body = "O consumo atual atingiu \(TokenStats.formattedNumber(totalTokens)) tokens, ultrapassando seu teto configurado de \(TokenStats.formattedNumber(threshold))."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "UseTokenBarThresholdExceeded-\(UUID().uuidString)",
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error delivering notification: \(error)")
            }
        }
    }
}
