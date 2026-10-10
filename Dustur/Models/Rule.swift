import Foundation

/// Düstur hayat kuralı modeli.
public struct Rule: Codable, Identifiable, Hashable {
    public let id: Int
    public let seq: Int
    public let categoryId: String
    public let text: String
    public let verify: Bool
    public let variants: [String: String]?

    public init(
        id: Int,
        seq: Int,
        categoryId: String,
        text: String,
        verify: Bool,
        variants: [String: String]? = nil
    ) {
        self.id = id
        self.seq = seq
        self.categoryId = categoryId
        self.text = text
        self.verify = verify
        self.variants = variants
    }

    /// Kullanıcının seçtiği cinsiyete göre en uygun kural metnini döndürür.
    public func displayText(for gender: AppGender = AppSettings.gender) -> String {
        if let variants = variants {
            if gender == .female, let femaleText = variants["female"] {
                return femaleText
            } else if gender == .male, let maleText = variants["male"] {
                return maleText
            }
        }
        return text
    }

    public static let fallback = Rule(
        id: 0,
        seq: 0,
        categoryId: "para",
        text: "Kural yüklenemedi. rules.json dosyasının Target Membership ayarını kontrol et.",
        verify: false,
        variants: nil
    )
}

/// JSON kök dokümanı
public struct RulesDocument: Codable {
    public let version: Int
    public let title: String
    public let categories: [RuleCategory]
    public let rules: [Rule]
}
