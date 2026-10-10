import SwiftUI

/// Düstur ana ekranı — Sade, ferah ve Apple yerel tasarım standartlarında profesyonel görünüm.
public struct HomeView: View {
    @State private var showAddWidget = false
    @State private var showSettings = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Üstte sade ve şık Widget Ekle butonu
                    AddWidgetBarButton {
                        showAddWidget = true
                    }

                    // 10 Kategori — 2 Sütun × 5 Satır Kare Kart Grid'i
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(RuleRepository.categories) { category in
                            NavigationLink(value: category) {
                                CategoryTile(category: category)
                            }
                            .buttonStyle(PlainPressableButtonStyle())
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(AppInfo.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.body)
                    }
                    .accessibilityLabel("Ayarlar")
                }
            }
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
    }
}

/// Sade ve Apple tarzı Widget Ekle hücresi
struct AddWidgetBarButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.badge.plus")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Widget Ekle")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("Şekli ve değişim süresini belirle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Hafif dokunma efekti
struct PlainPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.90 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
