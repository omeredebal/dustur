import SwiftUI

/// 3D Krom & Cam menü ikonlarıyla kaplanmış, ultra-lüks ve zarif kare kategori kartı.
public struct CategoryTile: View {
    public let category: RuleCategory

    public init(category: RuleCategory) {
        self.category = category
    }

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // MARK: - 1. Zemin (Derin Siyah)
            Color.black

            // MARK: - 2. 3D Krom & Cam Kategori İkonu (Kartı Tam Kaplar)
            CategoryIconLoader(id: category.id)
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            // MARK: - 3. Sinematik Karartma Gradyanı (Okunabilirlik ve Derinlik)
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.20),
                    Color.black.opacity(0.85)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            // MARK: - 4. İnce Lüks Krom Kontur
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.10),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            // MARK: - 5. Kart İçi Bilgiler
            VStack(alignment: .leading, spacing: 0) {
                // Üst Sağ: Sıra Numarası Rozeti
                HStack {
                    Spacer()
                    Text(String(format: "%02d", category.order))
                        .font(DusturTheme.monoNumber(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.80))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3.5)
                        .background(
                            Capsule().fill(Color.black.opacity(0.55))
                        )
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.20), lineWidth: 0.8)
                        )
                }

                Spacer()

                // Alt Kısım: Kategori Adı ve Yönlendirme İkonu
                HStack(alignment: .bottom, spacing: 6) {
                    Text(category.name)
                        .font(.system(size: 16.5, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.leading)
                        .shadow(color: .black.opacity(0.60), radius: 4, x: 0, y: 2)

                    Spacer(minLength: 0)

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.60))
                        .padding(5)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
            }
            .padding(14)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.40), radius: 8, x: 0, y: 4)
    }
}

/// İkonu hem Asset Catalog'dan hem diskten yüksek performansla yükleyen önbellekli loader
public struct CategoryIconLoader: View {
    let id: String
    private static let cache = NSCache<NSString, UIImage>()

    public var body: some View {
        if let uiImage = Self.image(for: id) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            // SF Symbol Fallback (Yüklenememe durumuna karşı)
            ZStack {
                Color(hex: "#15181E")
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
    }

    private static func image(for id: String) -> UIImage? {
        let key = id as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        // 1. Asset Catalog
        if let img = UIImage(named: id) {
            cache.setObject(img, forKey: key)
            return img
        }

        // 2. Bundle Root
        if let path = Bundle.main.path(forResource: id, ofType: "png"),
           let img = UIImage(contentsOfFile: path) {
            cache.setObject(img, forKey: key)
            return img
        }

        // 3. MenuIcons alt klasörü
        if let path = Bundle.main.path(forResource: id, ofType: "png", inDirectory: "MenuIcons"),
           let img = UIImage(contentsOfFile: path) {
            cache.setObject(img, forKey: key)
            return img
        }

        // 4. Bundle Resource dizininde case-insensitive arama
        if let resPath = Bundle.main.resourcePath,
           let items = try? FileManager.default.contentsOfDirectory(atPath: resPath) {
            if let match = items.first(where: { $0.lowercased().hasPrefix(id.lowercased()) && $0.hasSuffix(".png") }),
               let img = UIImage(contentsOfFile: (resPath as NSString).appendingPathComponent(match)) {
                cache.setObject(img, forKey: key)
                return img
            }
        }

        print("[Düstur] Uyarı: Kategori ikonu bulunamadı: \(id)")
        return nil
    }
}
