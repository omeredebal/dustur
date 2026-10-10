import Foundation
import UserNotifications

/// Yerel bildirim izinlerini yöneten ve günlük düstur hatırlatıcısını planlayan servis.
public enum NotificationManager {
    public static let notificationIdentifier = "dustur.daily.reminder"

    /// Kullanıcıdan bildirim izni talep eder.
    public static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// Mevcut bildirim izin durumunu sorgular.
    public static func checkAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    /// Belirlenen saatte her gün tekrarlanan yerel bildirimi kurar.
    public static func scheduleDailyNotification(at date: Date) {
        cancelNotifications()
        guard AppSettings.notificationsEnabled else { return }

        let cal = Calendar.current
        let hour = cal.component(.hour, from: date)
        let minute = cal.component(.minute, from: date)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "Günün Düsturu"
        content.sound = .default

        // Slot kuralı ve kullanıcının seçtiği cinsiyete uygun metin
        let slot = RotationEngine.slotIndex(for: Date(), intervalHours: AppSettings.intervalHours)
        if let rule = RotationEngine.rule(forSlot: slot) {
            let category = RuleRepository.category(id: rule.categoryId)?.name ?? AppInfo.name
            content.subtitle = category
            content.body = rule.displayText(for: AppSettings.gender)
        } else {
            content.body = "Bugünün yeni hayat kuralını görmek için dokunun."
        }

        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// Planlanmış bildirimleri iptal eder.
    public static func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }
}
