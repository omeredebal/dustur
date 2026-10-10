import SwiftUI

/// Sade, profesyonel ve Apple yerel standartlarında ayarlar ekranı.
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
            Form {
                // MARK: - Cinsiyet Tercihi
                Section {
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
                } header: {
                    Text("Cinsiyet Tercihi")
                } footer: {
                    Text(selectedGender.subtitle)
                }

                // MARK: - Widget Değişim Süresi
                Section {
                    Picker("Değişim Süresi", selection: $selectedHours) {
                        ForEach(1...24, id: \.self) { h in
                            Text("\(h) saatte bir").tag(h)
                        }
                    }
                    .onChange(of: selectedHours) { _, newHours in
                        AppSettings.intervalHours = newHours
                    }
                } header: {
                    Text("Widget Hızı")
                } footer: {
                    Text(AppSettings.cycleNote(for: selectedHours))
                }

                // MARK: - Günlük Bildirimler
                Section {
                    Toggle("Günlük Düstur Bildirimi", isOn: $notificationsEnabled)
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
                        DatePicker(
                            "Bildirim Saati",
                            selection: $notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: notificationTime) { _, newTime in
                            AppSettings.notificationTime = newTime
                            NotificationManager.scheduleDailyNotification(at: newTime)
                        }
                    }
                } header: {
                    Text("Hatırlatıcılar")
                } footer: {
                    Text("Her gün belirlediğin saatte günün öne çıkan kuralı bildirim olarak iletilir.")
                }

                // MARK: - Uygulama Bilgisi
                Section {
                    HStack {
                        Text("Sürüm")
                        Spacer()
                        Text(AppInfo.version).foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Toplam Kural")
                        Spacer()
                        Text("\(AppInfo.totalRules) İlke · \(AppInfo.totalCategories) Kategori")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Hakkında")
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamam") { dismiss() }
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
                Text("Günlük kural bildirimlerini alabilmek için sistem ayarlarından bildirim izni vermelisiniz.")
            }
        }
    }
}
