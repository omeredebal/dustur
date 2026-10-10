import Foundation

/// Kullanıcının seçebildiği cinsiyet ve kural filtreleme modu.
public enum AppGender: String, Codable, CaseIterable, Identifiable {
    case neutral = "neutral"
    case female = "female"
    case male = "male"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .neutral: return "Genel"
        case .female:  return "Kadın"
        case .male:    return "Erkek"
        }
    }

    public var symbol: String {
        switch self {
        case .neutral: return "person.2.fill"
        case .female:  return "figure.stand.dress"
        case .male:    return "figure.stand"
        }
    }

    public var subtitle: String {
        switch self {
        case .neutral:
            return "Tüm kitleye hitap eden dengeli ve kapsayıcı kurallar."
        case .female:
            return "Kadın sağlığı, bakımı ve zarafetine özgü uyarlanmış kurallar."
        case .male:
            return "Erkek bakımı, stili ve yaşamına özgü kurallar."
        }
    }
}
