import Foundation
import UserNotifications
import UIKit

/// Yerel bildirim izinlerini yöneten ve günlük düstur hatırlatıcısını planlayan servis.
public enum NotificationManager {
    public static let notificationIdentifier = "dustur.daily.reminder"

    /// Uygulama açılışında iOS sistemine bildirim kaydı yaptırır.
    /// Bu çağrı sayesinde iPhone Ayarları -> Düstur altında "Bildirimler" menüsü anında belirir.
    public static func registerWithSystem(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    AppSettings.notificationsEnabled = true
                    scheduleDailyNotification(at: AppSettings.notificationTime)
                }
                completion?(granted)
            }
        }
    }

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
                let isAuthorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
                completion(isAuthorized)
            }
        }
    }

    /// Kullanıcıyı doğrudan iPhone Ayarları uygulamasındaki Düstur bildirim sayfasına yönlendirir.
    public static func openSystemSettings() {
        let selector = NSSelectorFromString("sharedApplication")
        guard let appClass = NSClassFromString("UIApplication") as AnyObject?,
              let app = appClass.perform(selector)?.takeUnretainedValue() as? UIApplication else {
            return
        }
        if #available(iOS 16.0, *),
           let url = URL(string: UIApplication.openNotificationSettingsURLString),
           app.canOpenURL(url) {
            app.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            app.open(url)
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
