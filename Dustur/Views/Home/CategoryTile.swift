import SwiftUI

/// Sade, profesyonel ve Apple yerel tasarım diline uygun kare kategori kartı.
public struct CategoryTile: View {
    public let category: RuleCategory
    private let color: Color
    private let count: Int

    public init(category: RuleCategory) {
        self.category = category
        self.color = DusturTheme.categoryColor(for: category.id)
        self.count = RuleRepository.rules(in: category.id).count
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            // Mat, asil ve göz yormayan gradyan zemin
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(color.gradient)

            VStack(alignment: .leading, spacing: 0) {
                // SF Symbol İkonu
                Image(systemName: category.symbol)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)

                Spacer()

                // Kategori Adı
                Text(category.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.85)

                // Kural Sayısı
                Text("\(count) kural")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.80))
                    .padding(.top, 4)
            }
            .padding(16)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
