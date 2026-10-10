import Foundation

/// Kuralları ve kategorileri diskten yükleyip hafızada O(1) hızında yöneten optimize servis.
public enum RuleRepository {
    public static let document: RulesDocument = {
        if let url = Bundle.main.url(forResource: "rules", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let doc = try? JSONDecoder().decode(RulesDocument.self, from: data) {
            return doc
        }

        #if SWIFT_PACKAGE
        if let url = Bundle.module.url(forResource: "rules", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let doc = try? JSONDecoder().decode(RulesDocument.self, from: data) {
            return doc
        }
        #endif

        return RulesDocument(version: 0, title: AppInfo.name, categories: [], rules: [])
    }()

    /// Sıralı kategori listesi
    public static let categories: [RuleCategory] =
        document.categories.sorted { $0.order < $1.order }

    /// Widget rotasyon sırası (seq 1...1000)
    public static let bySequence: [Rule] =
        document.rules.sorted { $0.seq < $1.seq }

    /// Kategori ID'sine göre önceden gruplanmış ve sıralanmış kural önbelleği (O(1) erişim)
    private static let categoryRulesCache: [String: [Rule]] = {
        var dict: [String: [Rule]] = [:]
        for cat in document.categories {
            dict[cat.id] = document.rules
                .filter { $0.categoryId == cat.id }
                .sorted { $0.id < $1.id }
        }
        return dict
    }()

    private static let categoryMap: [String: RuleCategory] = {
        Dictionary(uniqueKeysWithValues: document.categories.map { ($0.id, $0) })
    }()

    /// Belirli bir kategorinin 100 kuralını O(1) sürede döndürür
    public static func rules(in categoryId: String) -> [Rule] {
        categoryRulesCache[categoryId] ?? []
    }

    /// Kategori ID'sine göre kategori detayını O(1) sürede döndürür
    public static func category(id: String) -> RuleCategory? {
        categoryMap[id]
    }
}
