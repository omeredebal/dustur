import SwiftUI

/// Düstur ana ekranı — 3D Krom & Cam menü kartlarıyla kaplanmış ultra-lüks ana ekran.
public struct HomeView: View {
    @State private var showAddWidget = false
    @State private var showSettings = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                // Derin Siyah Zemin
                Color.black.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Üst Header
                        HomeHeaderBar(onSettingsTap: { showSettings = true })
                            .padding(.top, 4)

                        // Widget Ekle Butonu
                        AddWidgetGlassButton {
                            showAddWidget = true
                        }

                        // 3D Krom & Cam Menü Kartları (2 Sütun × 5 Satır)
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
                    .padding(.horizontal, 16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarHidden(true)
            .navigationDestination(for: RuleCategory.self) { category in
                RuleListView(category: category)
            }
            .sheet(isPresented: $showAddWidget) {
                AddWidgetSheet()
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Sade ve Asil Header

struct HomeHeaderBar: View {
    let onSettingsTap: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(AppInfo.name.uppercased())
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .tracking(3.5)
                    .foregroundStyle(.white)

                Text(AppInfo.tagline)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.50))
                    .tracking(0.5)
            }

            Spacer()

            Button(action: onSettingsTap) {
                Image(systemName: "gearshape")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: 38, height: 38)
                    .background(
                        Circle().fill(Color(hex: "#13161C"))
                    )
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Widget Ekle Butonu

struct AddWidgetGlassButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 38, height: 38)

                    Image(systemName: "rectangle.badge.plus")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Widget Ekle")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("Şekli ve değişim süresini belirle")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.50))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                Color(hex: "#13161C"),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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
