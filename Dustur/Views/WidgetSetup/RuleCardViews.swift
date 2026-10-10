import SwiftUI
import WidgetKit

/// Hem gerçek widget'ta hem uygulama içi canlı önizlemede kullanılan kart içeriği.
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
            // Kilit Ekranı Dikdörtgen Widget'ı
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: category.symbol)
                        .font(.system(size: 9, weight: .bold))
                    Text(category.name.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .serif))
                }
                .widgetAccentable()

                Text(text)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        default:
            // Ana Ekran (Küçük Kare, Yatay Orta, Büyük Kare)
            VStack(alignment: .leading, spacing: spacingForFamily) {
                HStack(spacing: 6) {
                    Image(systemName: category.symbol)
                        .font(.system(size: iconSize, weight: .semibold))
                    Text(category.name)
                        .font(DusturTheme.editorialTitle(size: headerFontSize, weight: .semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(.white.opacity(0.88))

                Spacer(minLength: 0)

                Text(text)
                    .font(bodyFont)
                    .foregroundStyle(.white)
                    .lineSpacing(3)
                    .minimumScaleFactor(0.72)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Spacer(minLength: 0)

                // Altta zarif "Düstur" damgası
                HStack {
                    Spacer()
                    Text(AppInfo.name)
                        .font(.system(size: 9, weight: .regular, design: .serif))
                        .foregroundStyle(.white.opacity(0.45))
                        .tracking(1.5)
                }
            }
            .padding(contentPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var contentPadding: CGFloat {
        switch family {
        case .systemSmall: return 12
        case .systemLarge: return 20
        default:           return 16
        }
    }

    private var spacingForFamily: CGFloat {
        switch family {
        case .systemSmall: return 6
        case .systemLarge: return 14
        default:           return 10
        }
    }

    private var iconSize: CGFloat {
        switch family {
        case .systemSmall: return 11
        case .systemLarge: return 16
        default:           return 13
        }
    }

    private var headerFontSize: CGFloat {
        switch family {
        case .systemSmall: return 11
        case .systemLarge: return 15
        default:           return 13
        }
    }

    private var bodyFont: Font {
        switch family {
        case .systemSmall: return .system(size: 12.5, weight: .medium)
        case .systemLarge: return .system(size: 17, weight: .medium)
        default:           return .system(size: 14.5, weight: .medium)
        }
    }
}

/// Kategori rengine göre asil gradyan arka planı.
public struct RuleCardBackground: View {
    public let category: RuleCategory

    public init(category: RuleCategory) {
        self.category = category
    }

    public var body: some View {
        let baseColor = Color(hex: category.colorHex)
        ZStack {
            LinearGradient(
                colors: [
                    baseColor.opacity(0.95),
                    baseColor.opacity(0.75),
                    Color(hex: "#121316").opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // İnce lüks kontur çizgisi
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(DusturTheme.subtleBorder, lineWidth: 1)
        }
    }
}
