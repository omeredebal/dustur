import Foundation

/// Kullanıcının seçtiği saat aralığına göre (1 saat, 2 saat... 24 saat)
/// widget ve bildirim slotlarını hesaplayan evrensel rotasyon motoru.
public enum RotationEngine {
    /// Rotasyonun başlangıç referans tarihi (10 Ekim 2026, 00:00).
    public static let anchor: Date = {
        var c = DateComponents()
        c.year = 2026; c.month = 10; c.day = 10
        c.hour = 0; c.minute = 0; c.second = 0
        return Calendar.current.date(from: c) ?? Date()
    }()

    /// Verilen tarih ve saat süresi için geçerli olan slot indeksini hesaplar.
    /// Matematik: Geçen toplam saat / seçilen periyot saati.
    public static func slotIndex(
        for date: Date,
        intervalHours: Int,
        calendar: Calendar = .current
    ) -> Int {
        let safeInterval = max(intervalHours, 1)
        let totalHours = calendar.dateComponents([.hour], from: anchor, to: date).hour ?? 0
        return max(0, totalHours / safeInterval)
    }

    /// Verilen slotun başlangıç tarihini döndürür.
    public static func startDate(
        ofSlot slot: Int,
        intervalHours: Int,
        calendar: Calendar = .current
    ) -> Date {
        let safeInterval = max(intervalHours, 1)
        return calendar.date(byAdding: .hour, value: slot * safeInterval, to: anchor) ?? anchor
    }

    /// Slot indeksine denk gelen kuralı döndürür (1000 kural döngüsel).
    public static func rule(forSlot slot: Int) -> Rule? {
        let list = RuleRepository.bySequence
        guard !list.isEmpty else { return nil }
        return list[slot % list.count]
    }

    /// WidgetKit zaman çizelgesine kaç giriş ekleneceğini belirler (12 ile 60 arası).
    public static func timelineLength(for intervalHours: Int) -> Int {
        let safe = max(intervalHours, 1)
        let entriesForTwoDays = 48 / safe
        return min(max(entriesForTwoDays, 12), 60)
    }
}
