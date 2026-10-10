import SwiftUI

/// Seçilen kategorideki 100 ilkeyi edebi bir dergi/kitap estetiğinde sunan lüks ve 120 FPS akıcı kural listesi.
public struct RuleListView: View {
    public let category: RuleCategory
    private let catColor: Color
    private let rules: [Rule]
    @Environment(\.dismiss) private var dismiss
    @State private var copiedRuleId: Int?

    public init(category: RuleCategory) {
        self.category = category
        self.catColor = Color(hex: category.colorHex)
        self.rules = RuleRepository.rules(in: category.id)
    }

    public var body: some View {
        ZStack {
            // MARK: - Arka Plan
            DusturTheme.bgDeep.ignoresSafeArea()

            // Kategori Rengi Ambient Parlaması (Hafif ve GPU dostu)
            LinearGradient(
                colors: [catColor.opacity(0.14), Color.clear],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            // MARK: - Kural Kartları Akışı
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Kategori Hero Başlık Kartı
                    CategoryHeaderBanner(category: category, catColor: catColor)
                        .padding(.top, 12)

                    // 100 Kural Listesi Kartları (LazyVStack ile sanal bellek yönetimi)
                    LazyVStack(spacing: 12) {
                        ForEach(Array(rules.enumerated()), id: \.element.id) { index, rule in
                            RuleItemCard(
                                index: index + 1,
                                rule: rule,
                                catColor: catColor,
                                isCopied: copiedRuleId == rule.id,
                                onCopy: { copyRuleText(rule) }
                            )
                        }
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                        Text("Düstur")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundStyle(DusturTheme.brassLight)
                }
            }

            ToolbarItem(placement: .principal) {
                Text(category.name)
                    .font(DusturTheme.serifTitle(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func copyRuleText(_ rule: Rule) {
        let text = rule.displayText(for: AppSettings.gender)
        UIPasteboard.general.string = text
        copiedRuleId = rule.id

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if copiedRuleId == rule.id {
                copiedRuleId = nil
            }
        }
    }
}

// MARK: - Kategori Hero Başlık Kartı

struct CategoryHeaderBanner: View {
    let category: RuleCategory
    let catColor: Color

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(catColor.opacity(0.25))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle().stroke(catColor.opacity(0.45), lineWidth: 1)
                    )

                Image(systemName: category.symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text(category.name)
                .font(DusturTheme.serifTitle(size: 22, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                Text("100 Temel İlke")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DusturTheme.brassLight)

                Text("•")
                    .foregroundStyle(.white.opacity(0.30))

                Text("\(AppSettings.gender.title) İçerik")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.60))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DusturTheme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(DusturTheme.glassStroke, lineWidth: 1)
                )
        )
    }
}

// MARK: - Tekil Kural Kartı (Hafif ve Performanslı)

struct RuleItemCard: View {
    let index: Int
    let rule: Rule
    let catColor: Color
    let isCopied: Bool
    let onCopy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                // Numara Rozeti
                Text(String(format: "%03d", index))
                    .font(DusturTheme.monoNumber(size: 13, weight: .bold))
                    .foregroundStyle(DusturTheme.goldLight)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2.5)
                    .background(
                        Capsule().fill(catColor.opacity(0.25))
                    )

                Spacer()

                // Kopyala Butonu
                Button(action: onCopy) {
                    HStack(spacing: 4) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 10, weight: .semibold))
                        Text(isCopied ? "Kopyalandı" : "Kopyala")
                            .font(.system(size: 10.5, weight: .medium))
                    }
                    .foregroundStyle(isCopied ? DusturTheme.goldLight : .white.opacity(0.50))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Color.white.opacity(0.06))
                    )
                }
            }

            // Kural Metni
            Text(rule.displayText(for: AppSettings.gender))
                .font(.system(size: 15.5, weight: .regular))
                .lineSpacing(4)
                .foregroundStyle(.white.opacity(0.92))
                .multilineTextAlignment(.leading)

            // Doğrulama Rozeti
            if rule.verify {
                HStack(spacing: 5) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 10))
                    Text("Genel tavsiye niteliğindedir; resmi kaynakla doğrulayınız.")
                        .font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.40))
                .padding(.top, 2)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(DusturTheme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(DusturTheme.glassStroke, lineWidth: 1)
                )
        )
    }
}
