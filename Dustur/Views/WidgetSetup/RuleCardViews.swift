import SwiftUI
import WidgetKit

/// Widget ve uygulama içi canlı önizlemede kullanılan, metinlerin asla kesilmediği lüks kart içeriği.
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
        let catColor = DusturTheme.categoryColor(for: category.id)

        switch family {
        case .accessoryRectangular:
            // MARK: - Kilit Ekranı (Accessory Rectangular)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: category.symbol)
                        .font(.system(size: 8.5, weight: .bold))
                    Text(category.name.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .widgetAccentable()

                Text(text)
                    .font(.system(size: text.count > 80 ? 9.5 : (text.count > 55 ? 10.5 : 11.5), weight: .medium))
                    .lineLimit(4)
                    .minimumScaleFactor(0.60)
                    .lineSpacing(0.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

        case .systemMedium:
            // MARK: - Ana Ekran Yatay Widget
            VStack(alignment: .leading, spacing: 8) {
                // Başlık Satırı
                HStack(alignment: .center, spacing: 6) {
                    HStack(spacing: 5) {
                        Image(systemName: category.symbol)
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundStyle(catColor)
                        Text(category.name)
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundStyle(.white.opacity(0.92))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }

                    Spacer()

                    Text("DÜSTUR · \(String(format: "%03d", rule.seq))")
                        .font(DusturTheme.monoNumber(size: 9.5, weight: .bold))
                        .foregroundStyle(.white.opacity(0.65))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                }

                // Kural Metni (Geniş yatay alan, 2-3 satır, asla taşmaz)
                Text(text)
                    .font(.system(size: text.count > 80 ? 14.0 : 15.5, weight: .medium, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(3.0)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.70)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

        default:
            // MARK: - Ana Ekran Kare Widget (.systemSmall)
            VStack(alignment: .leading, spacing: 6) {
                // Kompakt Başlık Satırı (Tek satır, asla taşmaz)
                HStack(alignment: .center, spacing: 5) {
                    Image(systemName: category.symbol)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(catColor)

                    Text(category.name)
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Spacer(minLength: 0)

                    Text(String(format: "#%03d", rule.seq))
                        .font(DusturTheme.monoNumber(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.40))
                }

                // Kural Metni (Karakter uzunluğuna göre dinamik ölçeklenen tipografi)
                let charCount = text.count
                let fontSize: CGFloat = charCount > 90 ? 11.5 : (charCount > 60 ? 12.5 : 14.0)
                let lineSpacing: CGFloat = charCount > 90 ? 1.5 : 2.5

                Text(text)
                    .font(.system(size: fontSize, weight: .medium, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(lineSpacing)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.65)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

/// Kategori rengine göre rafine, ultra-lüks ve göz yormayan derin arka plan
public struct RuleCardBackground: View {
    public let category: RuleCategory

    public init(category: RuleCategory) {
        self.category = category
    }

    public var body: some View {
        let catColor = DusturTheme.categoryColor(for: category.id)
        ZStack {
            // 1. Derin Lüks Siyah
            Color(hex: "#0E1116")

            // 2. Kategori Vurgulu Işıma (Üst Sağdan)
            RadialGradient(
                colors: [
                    catColor.opacity(0.48),
                    catColor.opacity(0.12),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 200
            )

            // 3. İnce Derinlik Gradyanı
            LinearGradient(
                colors: [
                    Color.white.opacity(0.04),
                    Color.clear,
                    Color.black.opacity(0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
