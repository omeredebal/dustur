import SwiftUI

/// Seçilen kategorideki 100 kuralı, 3D krom kategori ikonu eşliğinde dergi/kitap estetiğinde sunan ekran.
public struct RuleListView: View {
    public let category: RuleCategory
    private let rules: [Rule]
    @Environment(\.dismiss) private var dismiss

    public init(category: RuleCategory) {
        self.category = category
        self.rules = RuleRepository.rules(in: category.id)
    }

    public var body: some View {
        ZStack {
            // Arka Plan (Derin Siyah/Obsidyen)
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // 3D Krom İkonlu Kategori Başlık Kartı
                    CategoryHeaderBanner(category: category)
                        .padding(.top, 8)

                    // 100 Kural Listesi
                    LazyVStack(spacing: 10) {
                        ForEach(Array(rules.enumerated()), id: \.element.id) { index, rule in
                            RuleListItem(
                                index: index + 1,
                                rule: rule
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
                    .foregroundStyle(.white.opacity(0.85))
                }
            }

            ToolbarItem(placement: .principal) {
                Text(category.name)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - 3D Krom İkonlu Kategori Başlık Kartı

struct CategoryHeaderBanner: View {
    let category: RuleCategory

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Zemin İkonu (Krom ve Cam)
            CategoryIconLoader(id: category.id)
                .scaledToFill()
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipped()

            // Karartma Gradyanı
            LinearGradient(
                colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.70),
                    Color.black.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Başlık Bilgisi
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    Text("100 Temel İlke")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))

                    Text("•")
                        .foregroundStyle(.white.opacity(0.35))

                    Text("\(AppSettings.gender.title) Modu")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.60))
                }
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Sade ve Şık Kural Satırı

struct RuleListItem: View {
    let index: Int
    let rule: Rule
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(String(format: "%03d", index))
                    .font(DusturTheme.monoNumber(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.40))
                    .frame(width: 32, alignment: .leading)

                Text(rule.displayText(for: AppSettings.gender))
                    .font(.system(size: 15.5, weight: .regular))
                    .foregroundStyle(.white.opacity(0.92))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if rule.verify {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 10))
                    Text("Genel bilgi, güncel kaynakla doğrula")
                        .font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.40))
                .padding(.leading, 44)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: "#13161C"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .contextMenu {
            Button {
                UIPasteboard.general.string = rule.displayText(for: AppSettings.gender)
            } label: {
                Label("Kopyala", systemImage: "doc.on.doc")
            }

            ShareLink(item: rule.displayText(for: AppSettings.gender)) {
                Label("Paylaş", systemImage: "square.and.arrow.up")
            }
        }
    }
}
