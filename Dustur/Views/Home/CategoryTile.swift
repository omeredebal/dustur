import SwiftUI

/// Ana ekranda 2 sütun × 5 satır kare grid içinde gösterilen ultra-lüks ve 120 FPS akıcı kategori kartı.
public struct CategoryTile: View {
    public let category: RuleCategory
    private let catColor: Color
    private let count: Int

    public init(category: RuleCategory) {
        self.category = category
        self.catColor = Color(hex: category.colorHex)
        self.count = RuleRepository.rules(in: category.id).count
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            // MARK: - Arka Plan (Donanım Hızlandırmalı Akıcı Gradyan)
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            catColor.opacity(0.85),
                            catColor.opacity(0.50),
                            DusturTheme.bgSecondary
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // İnce Mücevher Konturu
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.30),
                            catColor.opacity(0.35),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            // MARK: - Kart İçeriği
            VStack(alignment: .leading, spacing: 0) {
                // Üst Sıra: İkon + Sıra Rozeti
                HStack(alignment: .center) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.18), lineWidth: 0.8)
                            )

                        Image(systemName: category.symbol)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Text(String(format: "%02d", category.order))
                        .font(DusturTheme.monoNumber(size: 12.5, weight: .bold))
                        .foregroundStyle(DusturTheme.goldLight.opacity(0.85))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2.5)
                        .background(
                            Capsule().fill(Color.black.opacity(0.30))
                        )
                }

                Spacer(minLength: 8)

                // Kategori Başlığı
                Text(category.name)
                    .font(DusturTheme.serifTitle(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.80)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 6)

                // Alt Bilgi: Kural Sayısı ve Yön Oku
                HStack(spacing: 4) {
                    Text("\(count) İlke")
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundStyle(.white.opacity(0.70))

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundStyle(DusturTheme.goldLight.opacity(0.80))
                        .padding(4.5)
                        .background(
                            Circle().fill(Color.white.opacity(0.08))
                        )
                }
            }
            .padding(15)
        }
        .aspectRatio(1, contentMode: .fit)
        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
    }
}
