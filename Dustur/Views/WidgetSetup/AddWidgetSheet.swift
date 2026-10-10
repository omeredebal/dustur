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
            Form {
                // MARK: - Şekil ve Canlı Önizleme
                Section {
                    Picker("Şekil", selection: $shape) {
                        ForEach(WidgetShape.allCases) { item in
                            Text(item.shortTitle).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)

                    WidgetPreview(shape: shape, rule: sample.rule, category: sample.category)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 6)
                } header: {
                    Text("Şekil")
                } footer: {
                    Text(shape.note)
                }

                // MARK: - Değişim Süresi (Alarm Saati Stili Tekerlek)
                Section {
                    VStack(spacing: 8) {
                        HStack {
                            Spacer()
                            Picker("Saat", selection: $selectedHours) {
                                ForEach(1...24, id: \.self) { hour in
                                    Text("\(hour)")
                                        .font(.title2.monospacedDigit().weight(.semibold))
                                        .tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 90, height: 120)
                            .clipped()

                            Text("saatte bir")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Spacer()
                        }

                        Text("Sözler her \(selectedHours) saatte bir otomatik değişir.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                } header: {
                    Text("Değişim Süresi")
                } footer: {
                    Text(AppSettings.cycleNote(for: selectedHours))
                }

                // MARK: - Kaydet Butonu
                Section {
                    Button {
                        AppSettings.intervalHours = selectedHours
                        showSteps = true
                    } label: {
                        Text("Kaydet ve nasıl ekleneceğini göster")
                            .frame(maxWidth: .infinity)
                    }
                } footer: {
                    Text("iOS kuralları gereği widget'ı kullanıcı ana ekrana ekler. Seçtiğin süre tüm Düstur widget'larına uygulanır.")
                }
            }
            .navigationTitle("Widget Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
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
    }
}

/// Gerçek widget ile birebir aynı boyutta önizleme kutusu
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
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemFill))
            } else {
                RuleCardBackground(category: category)
            }

            RuleCardContent(
                rule: rule,
                category: category,
                family: shape.widgetFamily,
                gender: AppSettings.gender
            )
            .padding(isLock ? 10 : 16)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: isLock ? 12 : 22, style: .continuous))
        .animation(.snappy, value: shape)
    }
}

/// Kurulum Adımları
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
            "\(AppInfo.name) uygulamasını bulun ve \(shape.title) boyutu seçin.",
            "Widget Ekle'ye dokunun ve Bitti'ye basın."
        ]
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Süre kaydedildi: Her \(hours) saatte bir")
                    .font(.headline)
                Text("Widget galerisinden aşağıdaki adımlarla ekleyebilirsiniz:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("\(index + 1)")
                            .font(.footnote.monospacedDigit().weight(.bold))
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Color(.secondarySystemFill)))

                        Text(step)
                            .font(.body)
                    }
                }
            }

            Spacer()

            Button(action: onDone) {
                Text("Tamam")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}
