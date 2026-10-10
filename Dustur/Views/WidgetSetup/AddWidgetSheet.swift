import SwiftUI
import WidgetKit

/// Widget şekli ve alarm saati stiliyle manuel değişim süresini belirleme ekranı.
public struct AddWidgetSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var shape: WidgetShape = .small
    @State private var selectedHours: Int = AppSettings.intervalHours
    @State private var showSteps = false

    public init() {}

    private var sample: (rule: Rule, category: RuleCategory) {
        let slot = RotationEngine.slotIndex(for: Date(), intervalHours: selectedHours)
        let rule = RotationEngine.rule(forSlot: slot) ?? Rule.fallback
        let category = RuleRepository.category(id: rule.categoryId) ?? RuleCategory.fallback
        return (rule, category)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                DusturTheme.bgDeep.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // MARK: - Şekil Seçimi (Segmented)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("WİDGET BOYUTU")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(DusturTheme.brass)
                                .tracking(1.5)

                            Picker("Şekil", selection: $shape) {
                                ForEach(WidgetShape.allCases) { item in
                                    Text(item.shortTitle).tag(item)
                                }
                            }
                            .pickerStyle(.segmented)

                            // Canlı Önizleme Sahnesi
                            VStack {
                                WidgetPreview(shape: shape, rule: sample.rule, category: sample.category)
                                    .padding(.vertical, 16)
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(DusturTheme.cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .stroke(DusturTheme.glassStroke, lineWidth: 1)
                                    )
                            )

                            Text(shape.note)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.50))
                                .padding(.horizontal, 4)
                        }

                        // MARK: - Alarm Saati Stili Değişim Süresi Seçici
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SÖZLERİN DEĞİŞİM SÜRESİ")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(DusturTheme.brass)
                                .tracking(1.5)

                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    Spacer()

                                    // Alarm Çarkı (Wheel Picker)
                                    Picker("Saat", selection: $selectedHours) {
                                        ForEach(1...24, id: \.self) { hour in
                                            Text("\(hour)")
                                                .font(DusturTheme.monoNumber(size: 26, weight: .bold))
                                                .foregroundStyle(.white)
                                                .tag(hour)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(width: 80, height: 120)
                                    .clipped()

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("saatte bir")
                                            .font(DusturTheme.serifTitle(size: 20, weight: .bold))
                                            .foregroundStyle(DusturTheme.goldLight)

                                        Text("otomatik değişir")
                                            .font(.footnote)
                                            .foregroundStyle(.white.opacity(0.60))
                                    }

                                    Spacer()
                                }

                                Divider()
                                    .overlay(DusturTheme.divider)

                                HStack(spacing: 6) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(DusturTheme.brass)
                                    Text(AppSettings.cycleNote(for: selectedHours))
                                        .font(.footnote)
                                        .foregroundStyle(.white.opacity(0.65))
                                }
                            }
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(DusturTheme.cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .stroke(DusturTheme.glassStroke, lineWidth: 1)
                                    )
                            )
                        }

                        // MARK: - Kaydet ve Devam Butonu
                        Button {
                            AppSettings.intervalHours = selectedHours
                            showSteps = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Süreyi Kaydet ve Adımları Gör")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(DusturTheme.bgDeep)
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .background(
                                DusturTheme.brassLight,
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                            .shadow(color: DusturTheme.brass.opacity(0.30), radius: 10, x: 0, y: 5)
                        }

                        Text("iOS güvenlik kuralları gereği widget'ı kullanıcı ana ekrana ekler. Belirlediğin süre tüm widget'lara uygulanır.")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.40))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Widget Stüdyosu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                        .foregroundStyle(DusturTheme.brassLight)
                }
            }
            .sheet(isPresented: $showSteps) {
                AddWidgetSteps(shape: shape, hours: selectedHours) {
                    showSteps = false
                    dismiss()
                }
                .presentationDetents([.medium])
            }
        }
        .preferredColorScheme(.dark)
    }
}

/// Gerçek widget ile birebir aynı boyutta ve içerikte önizleme kutusu.
public struct WidgetPreview: View {
    public let shape: WidgetShape
    public let rule: Rule
    public let category: RuleCategory

    public init(shape: WidgetShape, rule: Rule, category: RuleCategory) {
        self.shape = shape
        self.rule = rule
        self.category = category
    }

    public var body: some View {
        let size = shape.previewSize
        let isLock = shape == .lockRectangular

        ZStack {
            if isLock {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            } else {
                RuleCardBackground(category: category)
            }

            RuleCardContent(
                rule: rule,
                category: category,
                family: shape.widgetFamily,
                gender: AppSettings.gender
            )
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: isLock ? 14 : 22, style: .continuous))
        .shadow(color: .black.opacity(0.40), radius: 14, x: 0, y: 6)
        .animation(.snappy, value: shape)
    }
}

/// Kullanıcının ana ekrana widget'ı nasıl ekleyeceğini gösteren lüks rehber.
public struct AddWidgetSteps: View {
    public let shape: WidgetShape
    public let hours: Int
    public let onDone: () -> Void

    public init(shape: WidgetShape, hours: Int, onDone: @escaping () -> Void) {
        self.shape = shape
        self.hours = hours
        self.onDone = onDone
    }

    private var steps: [String] {
        if shape == .lockRectangular {
            return [
                "Kilit ekranına basılı tutun ve Özelleştir'e dokunun.",
                "Kilit Ekranı görünümünü seçin.",
                "Saatin hemen altındaki widget alanına dokunun.",
                "\(AppInfo.name) uygulamasını bulup dikdörtgen widget'ı ekleyin."
            ]
        }
        return [
            "Ana ekranda boş bir alana uygulamalar titreyene kadar basılı tutun.",
            "Sol üst köşedeki (+) artı düğmesine dokunun.",
            "Arama çubuğuna \"\(AppInfo.name)\" yazın.",
            "\(shape.title) boyutunu seçip Widget Ekle'ye dokunun."
        ]
    }

    public var body: some View {
        ZStack {
            DusturTheme.bgDeep.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Süre Başarıyla Kaydedildi")
                        .font(DusturTheme.serifTitle(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Widget her \(hours) saatte bir yeni kural gösterecek.")
                        .font(.subheadline)
                        .foregroundStyle(DusturTheme.brassLight)
                }

                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text("\(index + 1)")
                                .font(DusturTheme.monoNumber(size: 13, weight: .bold))
                                .foregroundStyle(DusturTheme.bgDeep)
                                .frame(width: 24, height: 24)
                                .background(
                                    Circle().fill(DusturTheme.brassLight)
                                )

                            Text(step)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.90))
                                .lineSpacing(2)
                        }
                    }
                }

                Spacer()

                Button(action: onDone) {
                    Text("Tamam")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(DusturTheme.bgDeep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            DusturTheme.brassLight,
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                }
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
    }
}
