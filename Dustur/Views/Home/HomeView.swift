import SwiftUI

/// Düstur ana ekranı — Akıcı 120 FPS, Modern Editorial Luxe tasarımı ve Günün İlkesi vitrini.
public struct HomeView: View {
    @State private var showAddWidget = false
    @State private var showSettings = false
    @State private var todayRule: (rule: Rule, category: RuleCategory)?

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public init() {}

    private func refreshTodayRule() {
        let slot = RotationEngine.slotIndex(for: Date(), intervalHours: AppSettings.intervalHours)
        let rule = RotationEngine.rule(forSlot: slot) ?? Rule.fallback
        let category = RuleRepository.category(id: rule.categoryId) ?? RuleCategory.fallback
        self.todayRule = (rule, category)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Arka Plan (Derin Obsidyen)
                DusturTheme.bgDeep.ignoresSafeArea()

                // Üst Kısım Ambient Altın Parlaması (Performans dostu)
                LinearGradient(
                    colors: [
                        DusturTheme.brass.opacity(0.10),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()

                // MARK: - Ana İçerik Akışı
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        // Özel Lüks Header Bar
                        HeaderBar(onSettingsTap: { showSettings = true })
                            .padding(.top, 8)

                        // Günün Düsturu Hero Vitrin Kartı
                        if let current = todayRule {
                            HeroSpotlightCard(
                                rule: current.rule,
                                category: current.category,
                                onAddWidgetTap: { showAddWidget = true }
                            )
                        }

                        // Kategoriler Başlığı
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("KATEGORİLER")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(DusturTheme.brass)
                                    .tracking(2.0)

                                Spacer()

                                Text("\(AppInfo.totalRules) Temel İlke")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.40))
                            }
                        }
                        .padding(.top, 4)

                        // 2 Sütun × 5 Satır Kare Kartlar
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(RuleRepository.categories) { category in
                                NavigationLink(value: category) {
                                    CategoryTile(category: category)
                                }
                                .buttonStyle(TileScaleButtonStyle())
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 18)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: RuleCategory.self) { category in
                RuleListView(category: category)
            }
            .sheet(isPresented: $showAddWidget) {
                AddWidgetSheet()
                    .onDisappear { refreshTodayRule() }
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
                    .onDisappear { refreshTodayRule() }
            }
            .onAppear {
                refreshTodayRule()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Özel Header Bar

struct HeaderBar: View {
    let onSettingsTap: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(AppInfo.name.uppercased())
                    .font(DusturTheme.serifTitle(size: 26, weight: .bold))
                    .tracking(4.0)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, DusturTheme.goldLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(AppInfo.tagline)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DusturTheme.brass.opacity(0.85))
                    .tracking(1.0)
            }

            Spacer()

            // Cinsiyet rozeti + Ayarlar Butonu
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: AppSettings.gender.symbol)
                        .font(.system(size: 10, weight: .semibold))
                    Text(AppSettings.gender.title)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(DusturTheme.brass)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(DusturTheme.cardSurface)
                )
                .overlay(
                    Capsule().stroke(DusturTheme.goldStroke, lineWidth: 0.8)
                )

                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DusturTheme.brassLight)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle().fill(DusturTheme.cardSurface)
                        )
                        .overlay(
                            Circle().stroke(DusturTheme.goldStroke, lineWidth: 0.8)
                        )
                }
            }
        }
    }
}

// MARK: - Günün Düsturu Hero Vitrin Kartı

struct HeroSpotlightCard: View {
    let rule: Rule
    let category: RuleCategory
    let onAddWidgetTap: () -> Void

    var body: some View {
        let catColor = Color(hex: category.colorHex)

        ZStack(alignment: .topLeading) {
            // Arka Plan Katmanı
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            catColor.opacity(0.35),
                            DusturTheme.cardBg
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Lüks Kontur
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            catColor.opacity(0.55),
                            DusturTheme.goldStroke,
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            VStack(alignment: .leading, spacing: 14) {
                // Üst Başlık: Kategori ve Rotasyon Süresi
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: category.symbol)
                            .font(.system(size: 12, weight: .semibold))
                        Text(category.name.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .serif))
                    }
                    .foregroundStyle(DusturTheme.brassLight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(catColor.opacity(0.30))
                    )

                    Spacer()

                    HStack(spacing: 4) {
                        Circle()
                            .fill(DusturTheme.gold)
                            .frame(width: 6, height: 6)
                        Text("Günün Düsturu")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.65))
                    }
                }

                // Kural Metni (Tırnaklı, Edebi, Geniş)
                Text("“\(rule.displayText(for: AppSettings.gender))”")
                    .font(DusturTheme.serifTitle(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineSpacing(5)
                    .multilineTextAlignment(.leading)

                // Alt Aksiyon Butonları
                HStack {
                    Button(action: onAddWidgetTap) {
                        HStack(spacing: 7) {
                            Image(systemName: "plus.rectangle.on.rectangle")
                                .font(.system(size: 12, weight: .bold))
                            Text("Widget Olarak Ekle")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(DusturTheme.bgDeep)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            DusturTheme.brassLight,
                            in: Capsule()
                        )
                    }

                    Spacer()

                    Text("Her \(AppSettings.intervalHours) saatte bir değişir")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
            .padding(20)
        }
        .shadow(color: .black.opacity(0.20), radius: 10, x: 0, y: 5)
    }
}

/// Dokunma animasyonu
struct TileScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}
