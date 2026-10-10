import Foundation

/// Uygulama genelinde kullanılan temel yapılandırma ve kimlik bilgileri.
public enum AppInfo {
    public static let name = "Düstur"
    public static let tagline = "Hayatın temel kuralları"
    public static let version = "2.1.0"
    public static let totalRules = 1000
    public static let totalCategories = 10
    
    /// Target Signing & Capabilities > App Groups altında tanımlanan grup.
    /// Hem ana uygulama hem Widget Extension bu ortak grubu kullanır.
    public static let appGroup = "group.com.example.dustur"
}
