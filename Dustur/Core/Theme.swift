import SwiftUI

/// Düstur — "Modern Editorial Luxe" üst düzey tasarım sistemi.
public enum DusturTheme {
    // MARK: - Arka Plan & Zemin Renkleri
    
    public static let bgDeep = Color(hex: "#090A0D")
    public static let bgSecondary = Color(hex: "#101217")
    public static let cardBg = Color(hex: "#151821").opacity(0.85)
    public static let cardSurface = Color(hex: "#1E222D").opacity(0.90)
    public static let glassFill = Color.white.opacity(0.06)
    
    // MARK: - Vurgu Renkleri
    
    public static let gold = Color(hex: "#D4AF37")
    public static let goldLight = Color(hex: "#F3E5AB")
    public static let brass = Color(hex: "#C5A880")
    public static let brassLight = Color(hex: "#E0C9A6")
    public static let antiqueBrass = Color(hex: "#C5A880")
    public static let antiqueBrassLight = Color(hex: "#D9C3A3")
    
    // MARK: - Kontur & Çizgi
    
    public static let goldStroke = Color(hex: "#C5A880").opacity(0.25)
    public static let glassStroke = Color.white.opacity(0.12)
    public static let subtleBorder = Color.white.opacity(0.12)
    public static let divider = Color.white.opacity(0.08)
    
    // MARK: - Tipografi
    
    public static func serifTitle(size: CGFloat = 20, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    public static func editorialTitle(size: CGFloat = 20, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
    
    public static func body(size: CGFloat = 15, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    
    public static func monoNumber(size: CGFloat = 14, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif).monospacedDigit()
    }

    public static func number(size: CGFloat = 14, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif).monospacedDigit()
    }
}

// MARK: - Ultra Hızlı Renk Önbelleği & Hex Ayrıştırıcı

private enum ColorCache {
    static var cache: [String: Color] = [:]
    static let lock = NSLock()

    static func color(for hex: String) -> Color {
        lock.lock()
        defer { lock.unlock() }
        if let cached = cache[hex] { return cached }

        let cleanHex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard let intVal = UInt64(cleanHex, radix: 16) else {
            return .clear
        }

        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3:
            (a, r, g, b) = (255, (intVal >> 8) * 17, (intVal >> 4 & 0xF) * 17, (intVal & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, intVal >> 16, intVal >> 8 & 0xFF, intVal & 0xFF)
        case 8:
            (a, r, g, b) = (intVal >> 24, intVal >> 16 & 0xFF, intVal >> 8 & 0xFF, intVal & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        let newColor = Color(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
        cache[hex] = newColor
        return newColor
    }
}

public extension Color {
    init(hex: String) {
        self = ColorCache.color(for: hex)
    }
}
