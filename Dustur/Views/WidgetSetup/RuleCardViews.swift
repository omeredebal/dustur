import SwiftUI
import WidgetKit

/// Widget ve uygulama içi canlı önizlemede kullanılan sade kart içeriği.
public struct RuleCardContent: View {
    public let rule: Rule
    public let category: RuleCategory
    public let family: WidgetFamily
    public var gender: AppGender = AppSettings.gender

    public init(
        rule: Rule,
        category: RuleCategory,
        family: WidgetFamily,
        gender: AppGender = AppSettings.gender
    ) {
        self.rule = rule
        self.category = category
        self.family = family
        self.gender = gender
    }

    public var body: some View {
        let text = rule.displayText(for: gender)

        switch family {
        case .accessoryRectangular:
            // Kilit Ekranı
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name.uppercased())
                    .font(.caption2.weight(.bold))
                    .widgetAccentable()
                Text(text)
                    .font(.caption)
                    .lineLimit(4)
                    .minimumScaleFactor(0.80)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        default:
            // Ana Ekran (Kare, Yatay, Büyük)
            VStack(alignment: .leading, spacing: 8) {
                Label(category.name, systemImage: category.symbol)
                    .font(.caption.weight(.semibold))
                    .opacity(0.85)

                Text(text)
                    .font(bodyFont(for: family))
                    .minimumScaleFactor(0.75)
                    .lineSpacing(2)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private func bodyFont(for family: WidgetFamily) -> Font {
        switch family {
        case .systemSmall: return .footnote.weight(.medium)
        case .systemLarge: return .title3.weight(.medium)
        default:           return .callout.weight(.medium)
        }
    }
}

/// Kategori rengine göre pürüzsüz arka plan
public struct RuleCardBackground: View {
    public let category: RuleCategory

    public init(category: RuleCategory) {
        self.category = category
    }

    public var body: some View {
        let baseColor = DusturTheme.categoryColor(for: category.id)
        LinearGradient(
            colors: [baseColor, baseColor.opacity(0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
