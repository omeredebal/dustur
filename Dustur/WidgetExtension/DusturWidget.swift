import WidgetKit
import SwiftUI

/// Widget zaman çizelgesindeki her bir kural girişi.
public struct RuleEntry: TimelineEntry {
    public let date: Date
    public let rule: Rule
    public let category: RuleCategory
    public let gender: AppGender

    public init(date: Date, rule: Rule, category: RuleCategory, gender: AppGender) {
        self.date = date
        self.rule = rule
        self.category = category
        self.gender = gender
    }
}

/// Widget zaman çizelgesini hesaplayan sağlayıcı (Provider).
public struct RuleProvider: TimelineProvider {
    public init() {}

    public func placeholder(in context: Context) -> RuleEntry {
        let hours = AppSettings.intervalHours
        let slot = RotationEngine.slotIndex(for: Date(), intervalHours: hours)
        return makeEntry(slot: slot, date: Date())
    }

    public func getSnapshot(in context: Context, completion: @escaping (RuleEntry) -> Void) {
        completion(placeholder(in: context))
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<RuleEntry>) -> Void) {
        let now = Date()
        let hours = AppSettings.intervalHours
        let firstSlot = RotationEngine.slotIndex(for: now, intervalHours: hours)
        let count = RotationEngine.timelineLength(for: hours)

        // Kullanıcının seçtiği saat aralığında (1 saat, 2 saat, 5 saat...) slotlar üretilir
        let entries: [RuleEntry] = (0..<count).map { offset in
            let slot = firstSlot + offset
            let entryDate = offset == 0
                ? now
                : RotationEngine.startDate(ofSlot: slot, intervalHours: hours)
            return makeEntry(slot: slot, date: entryDate)
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func makeEntry(slot: Int, date: Date) -> RuleEntry {
        let rule = RotationEngine.rule(forSlot: slot) ?? Rule.fallback
        let category = RuleRepository.category(id: rule.categoryId) ?? RuleCategory.fallback
        return RuleEntry(
            date: date,
            rule: rule,
            category: category,
            gender: AppSettings.gender
        )
    }
}

/// Widget arayüz görünümü
public struct RuleWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    public let entry: RuleEntry

    public init(entry: RuleEntry) {
        self.entry = entry
    }

    public var body: some View {
        RuleCardContent(
            rule: entry.rule,
            category: entry.category,
            family: family,
            gender: entry.gender
        )
        .containerBackground(for: .widget) {
            if family == .accessoryRectangular {
                Color.clear
            } else {
                RuleCardBackground(category: entry.category)
            }
        }
    }
}

@main
public struct DusturWidget: Widget {
    public let kind = "DusturWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RuleProvider()) { entry in
            RuleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Günün Düsturu")
        .description("Belirlediğin sürede bir yeni hayat kuralı gösterir.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular
        ])
    }
}
