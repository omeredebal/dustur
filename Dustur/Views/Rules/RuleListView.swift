import SwiftUI

/// Seçilen kategorideki 100 kuralı sade ve ferah bir liste halinde sunan ekran.
public struct RuleListView: View {
    public let category: RuleCategory
    private let rules: [Rule]
    private let categoryColor: Color

    public init(category: RuleCategory) {
        self.category = category
        self.rules = RuleRepository.rules(in: category.id)
        self.categoryColor = DusturTheme.categoryColor(for: category.id)
    }

    public var body: some View {
        List {
            ForEach(Array(rules.enumerated()), id: \.element.id) { index, rule in
                HStack(alignment: .firstTextBaseline, spacing: 14) {
                    // Kural Numarası
                    Text("\(index + 1)")
                        .font(.footnote.monospacedDigit().weight(.bold))
                        .foregroundStyle(categoryColor)
                        .frame(width: 28, alignment: .trailing)

                    // Kural Metni
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.displayText(for: AppSettings.gender))
                            .font(.body)
                            .foregroundStyle(.primary)

                        if rule.verify {
                            Text("Genel bilgi, güncel kaynakla doğrula")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
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
        .listStyle(.insetGrouped)
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
