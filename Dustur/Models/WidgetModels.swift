import SwiftUI
import WidgetKit

/// Uygulama içi önizleme ve kullanıcı yönlendirmesi için widget boyutları.
public enum WidgetShape: String, CaseIterable, Identifiable {
    case small
    case medium
    case lockRectangular

    public var id: String { rawValue }

    public var shortTitle: String {
        switch self {
        case .small: return "Kare"
        case .medium: return "Yatay"
        case .lockRectangular: return "Kilit"
        }
    }

    public var title: String {
        switch self {
        case .small: return "Kare Widget"
        case .medium: return "Yatay Widget"
        case .lockRectangular: return "Kilit Ekranı"
        }
    }

    public var note: String {
        switch self {
        case .small: return "Ana ekran · 2×2 kompakt kare"
        case .medium: return "Ana ekran · 4×2 geniş yatay"
        case .lockRectangular: return "Kilit ekranı · saatin altındaki dikdörtgen"
        }
    }

    public var previewSize: CGSize {
        switch self {
        case .small: return CGSize(width: 158, height: 158)
        case .medium: return CGSize(width: 338, height: 158)
        case .lockRectangular: return CGSize(width: 160, height: 72)
        }
    }

    public var widgetFamily: WidgetFamily {
        switch self {
        case .small: return .systemSmall
        case .medium: return .systemMedium
        case .lockRectangular: return .accessoryRectangular
        }
    }
}
