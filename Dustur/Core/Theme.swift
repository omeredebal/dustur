import SwiftUI

/// Düstur — Sade, modern ve Apple Human Interface Guidelines uyumlu tasarım sistemi.
public enum DusturTheme {
    // MARK: - Tipografi
    
    public static func monoNumber(size: CGFloat = 14, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif).monospacedDigit()
    }

    // MARK: - Kategori Renkleri (Sakin, Muted & Apple HIG Uyumlu)
    
    public static func categoryColor(for id: String) -> Color {
        switch id {
        case "para":     return Color(hex: "#2E7D5B") // Zümrüt Yeşili
        case "hukuk":    return Color(hex: "#3F628D") // Çelik Mavisi
        case "gorgu":    return Color(hex: "#8B6B4E") // Sıcak Toprak
        case "iliski":   return Color(hex: "#9E4857") // Gül Kurusu
        case "kariyer":  return Color(hex: "#3B7A8C") // Okyanus
        case "saglik":   return Color(hex: "#438257") // Yaprak Yeşili
        case "pratik":   return Color(hex: "#8A6834") // Kehribar
        case "gorunum":  return Color(hex: "#625782") // Lavanta Gri
        case "dijital":  return Color(hex: "#2F7C85") // Petrol
        case "zihin":    return Color(hex: "#5B5F66") // Grafit
        default:         return Color(hex: "#3F628D")
        }
    }
}

// MARK: - Optimize Edilmiş Renk Çözümleyici

public extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard let intVal = UInt64(clean, radix: 16) else {
            self = .clear
            return
        }

        let r, g, b: Double
        switch clean.count {
        case 6:
            r = Double((intVal >> 16) & 0xFF) / 255.0
            g = Double((intVal >> 8) & 0xFF) / 255.0
            b = Double(intVal & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}
