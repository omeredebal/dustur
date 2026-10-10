import Foundation

/// Düstur kategori modeli (10 kategori).
public struct RuleCategory: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let symbol: String
    public let colorHex: String
    public let order: Int

    public init(id: String, name: String, symbol: String, colorHex: String, order: Int) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.colorHex = colorHex
        self.order = order
    }

    public static let fallback = RuleCategory(
        id: "para",
        name: "Kurallar",
        symbol: "book.closed.fill",
        colorHex: "#2F6F5E",
        order: 0
    )
}
