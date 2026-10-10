import SwiftUI

/// Kullanıcının cinsiyet tercihini, bildirim saatini ve widget hızını yönettiği lüks ayarlar sayfası.
public struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedGender: AppGender = AppSettings.gender
    @State private var selectedHours: Int = AppSettings.intervalHours
    @State private var notificationsEnabled: Bool = AppSettings.notificationsEnabled
    @State private var notificationTime: Date = AppSettings.notificationTime
    @State private var showPermissionAlert = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                DusturTheme.bgDeep.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        // MARK: - Cinsiyet Uyarlaması Kartı
                        SettingsCard(title: "CİNSİYET UYARLAMASI") {
                            VStack(alignment: .leading, spacing: 12) {
                                Picker("Cinsiyet", selection: $selectedGender) {
                                    ForEach(AppGender.allCases) { gender in
                                        Label(gender.title, systemImage: gender.symbol).tag(gender)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .onChange(of: selectedGender) { _, newValue in
                                    AppSettings.gender = newValue
                                    if notificationsEnabled {
                                        NotificationManager.scheduleDailyNotification(at: notificationTime)
                                    }
                                }

                                Text(selectedGender.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.60))
                                    .padding(.top, 2)
                            }
                        }

                        // MARK: - Widget Hızı Kartı
                        SettingsCard(title: "WİDGET DEĞİŞİM SÜRESİ") {
                            VStack(spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Değişim Periyodu")
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(.white)
                                        Text(AppSettings.cycleNote(for: selectedHours))
                                            .font(.caption)
                                            .foregroundStyle(DusturTheme.brassLight)
                                    }

                                    Spacer()

                                    Picker("Süre", selection: $selectedHours) {
                                        ForEach(1...24, id: \.self) { h in
                                            Text("\(h) saat").tag(h)
                                        }
                                    }
                                    .tint(DusturTheme.brassLight)
                                    .pickerStyle(.menu)
                                }
                                .onChange(of: selectedHours) { _, newHours in
                                    AppSettings.intervalHours = newHours
                                }
                            }
                        }

                        // MARK: - Günlük Hatırlatıcılar Kartı
                        SettingsCard(title: "GÜNLÜK HATIRLATICI") {
                            VStack(spacing: 14) {
                                Toggle(isOn: $notificationsEnabled) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Günün Düsturu Bildirimi")
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(.white)
                                        Text("Her gün seçilen saatte ilham verici bir kural iletilir.")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.50))
                                    }
                                }
                                .tint(DusturTheme.brass)
                                .onChange(of: notificationsEnabled) { _, isEnabled in
                                    if isEnabled {
                                        NotificationManager.requestAuthorization { granted in
                                            if granted {
                                                AppSettings.notificationsEnabled = true
                                                NotificationManager.scheduleDailyNotification(at: notificationTime)
                                            } else {
                                                notificationsEnabled = false
                                                AppSettings.notificationsEnabled = false
                                                showPermissionAlert = true
                                            }
                                        }
                                    } else {
                                        AppSettings.notificationsEnabled = false
                                        NotificationManager.cancelNotifications()
                                    }
                                }

                                if notificationsEnabled {
                                    Divider().overlay(DusturTheme.divider)

                                    HStack {
                                        Text("Bildirim Saati")
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(.white)

                                        Spacer()

                                        DatePicker(
                                            "",
                                            selection: $notificationTime,
                                            displayedComponents: .hourAndMinute
                                        )
                                        .labelsHidden()
                                        .colorInvert()
                                        .colorMultiply(DusturTheme.brassLight)
                                        .onChange(of: notificationTime) { _, newTime in
                                            AppSettings.notificationTime = newTime
                                            NotificationManager.scheduleDailyNotification(at: newTime)
                                        }
                                    }
                                }
                            }
                        }

                        // MARK: - Hakkında Kartı
                        SettingsCard(title: "HAKKINDA") {
                            VStack(spacing: 10) {
                                InfoRow(label: "Uygulama", value: AppInfo.name)
                                Divider().overlay(DusturTheme.divider)
                                InfoRow(label: "Sürüm", value: AppInfo.version)
                                Divider().overlay(DusturTheme.divider)
                                InfoRow(label: "Koleksiyon", value: "\(AppInfo.totalRules) İlke · 10 Kategori")
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamam") { dismiss() }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(DusturTheme.brassLight)
                }
            }
            .alert("Bildirim İzni Gerekli", isPresented: $showPermissionAlert) {
                Button("Ayarlar'a Git") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Günün kuralı bildirimlerini alabilmek için sistem ayarlarından bildirim iznini açmanız gerekir.")
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Özel Ayarlar Kartı Şablonu

struct SettingsCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DusturTheme.brass)
                .tracking(1.5)
                .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(DusturTheme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(DusturTheme.glassStroke, lineWidth: 1)
                    )
            )
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
            Text(value)
                .font(.body.weight(.medium))
                .foregroundStyle(DusturTheme.brassLight)
        }
    }
}
