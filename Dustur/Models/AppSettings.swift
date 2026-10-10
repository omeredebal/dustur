import Foundation
import WidgetKit

/// Uygulama ve Widget Extension arasında App Group üzerinden paylaşılan ayarlar.
public enum AppSettings {
    private static let intervalHoursKey = "widget.intervalHours"
    private static let genderKey = "app.gender"
    private static let notifEnabledKey = "notifications.enabled"
    private static let notifHourKey = "notifications.hour"
    private static let notifMinuteKey = "notifications.minute"

    private static var store: UserDefaults {
        UserDefaults(suiteName: AppInfo.appGroup) ?? .standard
    }

    /// Kullanıcının alarm çarkıyla seçtiği saat (1...24 saat, varsayılan 12).
    public static var intervalHours: Int {
        get {
            let saved = store.integer(forKey: intervalHoursKey)
            return saved > 0 ? min(max(saved, 1), 24) : 12
        }
        set {
            store.set(newValue, forKey: intervalHoursKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    /// Kullanıcının seçtiği cinsiyet modu (Genel, Kadın, Erkek).
    public static var gender: AppGender {
        get {
            let val = store.string(forKey: genderKey) ?? AppGender.neutral.rawValue
            return AppGender(rawValue: val) ?? .neutral
        }
        set {
            store.set(newValue.rawValue, forKey: genderKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    /// Günlük düstur bildirimi açık mı?
    public static var notificationsEnabled: Bool {
        get { store.bool(forKey: notifEnabledKey) }
        set { store.set(newValue, forKey: notifEnabledKey) }
    }

    /// Bildirimin gönderileceği saat ve dakika (varsayılan 09:00).
    public static var notificationTime: Date {
        get {
            var c = DateComponents()
            c.hour = store.object(forKey: notifHourKey) != nil ? store.integer(forKey: notifHourKey) : 9
            c.minute = store.object(forKey: notifMinuteKey) != nil ? store.integer(forKey: notifMinuteKey) : 0
            return Calendar.current.date(from: c) ?? Date()
        }
        set {
            let cal = Calendar.current
            store.set(cal.component(.hour, from: newValue), forKey: notifHourKey)
            store.set(cal.component(.minute, from: newValue), forKey: notifMinuteKey)
        }
    }

    /// Seçilen saat süresine göre tüm kuralların kaç günde tamamlanacağını hesaplar.
    public static func cycleNote(for hours: Int) -> String {
        let total = AppInfo.totalRules
        let days = Int((Double(total) * Double(hours) / 24.0).rounded())
        return "1000 kural yaklaşık \(days) günde bir kez gösterilir."
    }
}
