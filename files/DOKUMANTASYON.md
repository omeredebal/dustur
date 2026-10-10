# Düstur — Dokümantasyon

Günlük hayatın temel kurallarını kategorilere ayıran, kişisel kullanım için bir iOS uygulaması. Ana ekranda kare kategori kartları, karta basınca o kategorinin 100 kuralı, sağ üstte ayarlar menüsü (cinsiyet seçimi ve bildirim izinleri), ayrıca kullanıcının şeklini ve değişim süresini **tıpkı bir alarm saati / sayaç gibi manuel olarak (1 saat, 2 saat, 3 saat... 24 saat)** tekerlekle seçebildiği ana ekran ve kilit ekranı widget'ı.

**Teknoloji:** Swift 5.9+, SwiftUI, WidgetKit, UserNotifications · **Minimum:** iOS 17 · **Xcode:** 15+  
**Not:** Kodu Linux ortamında yazdım, Xcode'da derleyip çalıştırmadım. Hata çıkarsa hatayı yapıştır, düzeltirim.

---

## 0. Bu sürümde değişenler

| Değişiklik | Neden |
|---|---|
| **Alarm / Sayaç tarzı manuel süre seçici (Wheel Picker)** | İstek. Kullanıcı artık sabit birkaç buton yerine, tıpkı iOS Saat / Alarm uygulamasındaki gibi tekerleği çevirerek 1 saat, 2 saat, 3 saat... 24 saat arasından dilediği süreyi manuel olarak seçebilir |
| **Genelleştirilmiş Kesintisiz Rotasyon Motoru (`RotationEngine`)** | 24'e tam bölünme zorunluluğu kaldırıldı. Toplam saat üzerinden lineer slot algoritmasıyla 2 saat, 5 saat, 7 saat gibi tüm sürelerde hatasız çalışır |
| **Ayarlar menüsü (`SettingsSheet`)** | İstek. Sağ üstteki çark simgesiyle açılır; cinsiyet seçimi ve bildirim izinlerini yönetir |
| **Dinamik cinsiyet uyarlaması (`male` / `female` / `neutral`)** | İstek. Kuralların erkek odaklı kalmaması için 28 kurala cinsiyet varyantı eklendi. Kadın seçildiğinde erkek kuralları yerine kadınlara özel eşdeğerleri gösterilir |
| **Bildirim izinleri ve Günlük Düstur Hatırlatıcısı** | İstek. Kullanıcının belirlediği saatte (varsayılan 09:00) günün öne çıkan kuralını bildiren yerel bildirim sistemi (`UserNotifications`) |
| **App Group ile Çoklu Senkronizasyon** | Uygulamada seçilen süre (`intervalHours`) ve cinsiyet (`gender`) App Group ile widget'a aktarılır; widget anında güncellenir |
| **Uygulama adı: Düstur** | Tüm kitleye hitap eden, profesyonel ve kuralla doğrudan ilişkili ad |
| **Kategori ekranı 2 sütun × 5 satır, kare kartlar** | Kartlar `aspectRatio(1)` ile her ekran genişliğinde kare kalır |
| **Yatay "Widget Ekle" butonu** | Tıklayınca şekil + alarm stili süre seçimi ve kurulum adımları açılır |

### Önemli sınır: widget'ı uygulama kendisi ekleyemez

iOS, bir uygulamanın widget'ı kullanıcının ana ekranına veya kilit ekranına **kendiliğinden eklemesine izin vermez**. Bunu sadece kullanıcı sistem menüsünden yapabilir. Bu yüzden "Widget Ekle" butonunun yaptığı şey:

1. Kullanıcı şekli ve değişim süresini alarm tekerleğiyle seçer, canlı önizlemeyi görür.
2. **Kaydet**'e basınca süre kaydedilir (tüm Düstur widget'larına uygulanır).
3. Seçilen şekle özel, kısa bir "şimdi şöyle ekle" adım listesi açılır.

Widget'ın boyutunu son aşamada sistemin widget galerisi belirler. Uygulamadaki şekil seçimi, kullanıcıya hangi boyutu seçeceğini ve nasıl görüneceğini gösterir.

---

## 1. Uygulama Adı ve Cinsiyet Uyarlaması

### Uygulama Adı: Düstur

"Düstur", Türkçede "ilke, hayat kuralı" demek. Widget'ın yaptığı iş de tam olarak bu: her gün birkaç düstur göstermek. Tek kelime, ciddi ama soğuk değil, cinsiyetsiz, simgeleşmesi kolay. Eski kanun derlemelerinin adı olması otorite hissi de verir.

| Ad | Artı | Eksi |
|---|---|---|
| **Düstur** (öneri) | Anlamı birebir uyuyor, akılda kalıcı, profesyonel | Biraz resmî, İngilizce telaffuz zor |
| **Esas** | Kısa, modern, "temel ilke" anlamı | Çok yaygın bir sözcük, mağazada bulunması zor |
| **Usul** | Kısa, "yöntem / görgü" çağrışımı | Anlamı daha dar, hukuk çağrışımı baskın |
| **Kılavuz** | Çok net, herkes anlar | Sıradan, ayırt edici değil |

**Yayına çıkmadan önce kontrol et:**
- App Store TR ve Google Play'de ad araması
- TÜRKPATENT marka sorgusu
- Alan adı ve sosyal medya kullanıcı adı müsaitliği

**Mağaza alt başlığı önerisi:** "Hayatın temel kuralları" · **Bundle ID önerisi:** `com.<senin-adın>.dustur` (Xcode'da ASCII proje adı: `Dustur`)

---

### Cinsiyet Uyarlaması: Kişiye Özel Kural Sistemi

Önceki taslakta yer alan sakal, tıraş, kravat, ceket düğmesi, testis/prostat kontrolü, "baba olacaksan" gibi yaklaşık 28 kural, uygulamadan çıkarılmak yerine **akıllı varyant sistemi (`variants`)** ile dönüştürüldü:

1. **Kadın Seçildiğinde:**
   - Sakal ve tıraş kuralları ➔ Cilt bakımı, epilasyon hijyeni, makyaj temizliği ve nemlendirme kurallarına dönüşür.
   - Kravat ve papyon kuralları ➔ Fular/şal bağlama, topuklu ayakkabı ergonomisi ve takı/çanta aksesuar dengesine dönüşür.
   - Takım elbise/ceket düğmesi ➔ Blazer proporsiyonu, vücut tipine oturan kalıplar ve kapsül gardırop ilkelerine dönüşür.
   - Prostat ve testis taramaları ➔ Meme ve rahim ağzı taramaları, kendi kendine meme muayenesi ve rutin jinekolojik kontrollere dönüşür.
   - "Baba olacaksan" maddesi ➔ "Anne olacaksan her şeyi tek başına üstlenmek zorunda olmadığını bil; destek iste" düsturuna dönüşür.
   - Askerlik yükümlülüğü ➔ KADES, 112 ve ALO 183 resmi güvenlik ve destek kanallarına dönüşür.
2. **Erkek Seçildiğinde:**
   - Orijinal erkek bakım, sağlık, giyim ve babalık kuralları erkeklere özel detaylarıyla gösterilir.
3. **Genel / Nötr Seçildiğinde (Varsayılan):**
   - Her iki cinsiyeti de kapsayan dengeli, genel düstur metinleri gösterilir.
4. **Ortak Kurallar:**
   - Para, hukuk, dijital güvenlik, zihin ve sosyal görgü gibi kalan 972 kural tüm kullanıcılar için ortaktır ve aynı şekilde sunulur.

---

## 2. İçerik: `rules.json`

| | |
|---|---|
| Toplam kural | 1000 (10 kategori × 100) |
| Cinsiyet varyantı içeren kural | 28 kural (Görünüm 19, Sağlık 4, İlişki 1, Pratik 1, Hukuk 1 ve ilgili alanlar) |
| En uzun kural | 118 karakter (widget'a sığar) |
| `verify: true` işaretli | 151 kural (hukuk 56, sağlık 46, pratik 27, para 6, görünüm 5, kariyer 4, zihin 4, ilişkiler 2, dijital 1) |
| Tekrar eden kural | 0 (kod ile kontrol edildi) |

### Kategoriler (ekranda bu sırayla, soldan sağa, yukarıdan aşağıya)

| # | id | Ad | SF Symbol |
|---|---|---|---|
| 1 | `para` | Para | `banknote` |
| 2 | `hukuk` | Hukuk ve Bürokrasi | `building.columns` |
| 3 | `gorgu` | Görgü ve Sosyal Hayat | `person.2` |
| 4 | `iliski` | İlişkiler | `heart` |
| 5 | `kariyer` | Kariyer | `briefcase` |
| 6 | `saglik` | Sağlık ve Beden | `cross.case` |
| 7 | `pratik` | Pratik Beceriler | `wrench.and.screwdriver` |
| 8 | `gorunum` | Görünüm ve Bakım | `tshirt` |
| 9 | `dijital` | Dijital Güvenlik | `lock.shield` |
| 10 | `zihin` | Zihin ve Karakter | `brain.head.profile` |

### Şema

```json
{
  "version": 2,
  "title": "Düstur — Hayatın Temel Kuralları",
  "rotation": { "intervalHours": 12, "orderField": "seq", "totalSlots": 1000 },
  "categories": [
    { "id": "para", "name": "Para", "symbol": "banknote", "colorHex": "#2F6F5E", "order": 1 }
  ],
  "rules": [
    {
      "id": 747,
      "seq": 162,
      "categoryId": "gorunum",
      "text": "Tıraş olurken temiz jilet kullan ve sonrasında cildini nemlendir.",
      "verify": false,
      "variants": {
        "male": "Tıraş olurken temiz jilet kullan, sakal yönünde kes ve sonrasında cildini nemlendir.",
        "female": "Epilasyon ve cilt temizliğinde hijyene dikkat et; batıkları ve tahrişi önlemek için nemlendir."
      }
    }
  ]
}
```

---

## 3. Widget Rotasyon Mantığı ve Alarm Tarzı Süre Seçimi

Kullanıcı süreyi **1 saat ile 24 saat arasında herhangi bir tam sayı** olarak tıpkı alarm saati veya zamanlayıcı kurar gibi serbestçe seçebilir.

### Matematiksel Model (Evrensel Lineer Slot Sistemi)

Sabit bir başlangıç referansı (`anchor`: 10 Ekim 2026 00:00) baz alınır. Bu referanstan şu ana kadar geçen toplam saat hesaplanır:

```
toplamSaat      = Calendar.current.dateComponents([.hour], from: anchor, to: tarih).hour
slot            = max(0, toplamSaat / secilenSaat)
gösterilenKural = seqSıralıListe[slot % 1000]
slotBaşlangıcı  = anchor + (slot * secilenSaat) saat
```

Bu formül sayesinde:
- **1 saat seçilirse:** Her saat başı değişir (00:00, 01:00, 02:00, ...). ≈ 42 günde tüm 1000 kural biter.
- **2 saat seçilirse:** 00:00, 02:00, 04:00, 06:00... şeklinde 2 saatte bir değişir. ≈ 83 günde döngü tamamlanır.
- **3 saat seçilirse:** 00:00, 03:00, 06:00... ≈ 125 gün.
- **4 saat seçilirse:** 00:00, 04:00, 08:00... ≈ 167 gün.
- **5 saat seçilirse:** 00:00, 05:00, 10:00, 15:00... (24'e tam bölünmese dahi lineer zaman çizgisinde hatasız devam eder).
- **12 saat seçilirse:** 00:00 ve 12:00. ≈ 500 gün.
- **24 saat seçilirse:** Her gece 00:00'da günde bir kez değişir. ≈ 1000 gün.

### WidgetKit Zaman Çizelgesi (`TimelineProvider`) Nasıl Çalışır?

iOS WidgetKit, pil tasarrufu için widget'ların arka planda sürekli kod çalıştırmasına izin vermez. Bunun yerine `RuleProvider.getTimeline()` metodu sisteme önceden bir **zaman çizelgesi listesi (`TimelineEntry`)** verir:
- Örneğin kullanıcı "2 saatte bir" seçtiyse, önümüzdeki 48–72 saat için sıradaki slotların saatleri ve kuralları sisteme teslim edilir.
- iOS saati geldiğinde hiçbir internet veya CPU gücü harcamadan ekranı anında bir sonraki kurala geçirir.
- Liste sonuna yaklaşıldığında sistem otomatik olarak yeni bir zaman çizelgesi talep eder (`.atEnd`).
- Kullanıcı uygulamadan süreyi veya cinsiyeti değiştirdiğinde `WidgetCenter.shared.reloadAllTimelines()` çağrılır ve mevcut widget'lar anında yeni ayarlarla baştan çizilir.

---

## 4. Xcode Kurulumu

1. **Yeni proje:** File → New → Project → iOS → **App**. Ad: `Dustur`, Interface: SwiftUI, Language: Swift. Deployment Target: **iOS 17.0**. Görünen ad: `Düstur`.
2. **Widget ekle:** File → New → Target → **Widget Extension**. Ad: `DusturWidget`. "Include Live Activity" ve "Include Configuration App Intent" **işaretsiz** olsun. Şablonun ürettiği örnek dosyaları sil.
3. **App Group Yetkisi:** Her iki hedef için (`Dustur` ve `DusturWidget`) Signing & Capabilities → **+ Capability → App Groups** → aynı grubu ekle (ör. `group.com.<senin-adın>.dustur`). Bu değeri `AppInfo.appGroup` içine yaz.
4. **Dosya hedefleri (Target Membership):**

| Dosya | Dustur (uygulama) | DusturWidget |
|---|---|---|
| `rules.json` | ✅ | ✅ |
| `Models.swift` | ✅ | ✅ |
| `RuleCardViews.swift` | ✅ | ✅ |
| `DusturApp.swift` | ✅ | |
| `HomeView.swift` | ✅ | |
| `SettingsSheet.swift` | ✅ | |
| `NotificationManager.swift` | ✅ | |
| `AddWidgetSheet.swift` | ✅ | |
| `RuleListView.swift` | ✅ | |
| `RuleWidget.swift` | | ✅ |

---

## 5. Kod Dosyaları

### `Models.swift` (iki hedef de: `Dustur` ve `DusturWidget`)

```swift
import Foundation
import SwiftUI
import WidgetKit

// MARK: - Uygulama Bilgisi

enum AppInfo {
    static let name = "Düstur"
    static let tagline = "Hayatın temel kuralları"
    /// Signing & Capabilities → App Groups'ta tanımladığın grupla aynı olmalı.
    static let appGroup = "group.com.example.dustur"
}

// MARK: - Cinsiyet Tercihi

enum AppGender: String, CaseIterable, Identifiable {
    case neutral = "neutral"
    case female = "female"
    case male = "male"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .neutral: return "Genel"
        case .female:  return "Kadın"
        case .male:    return "Erkek"
        }
    }

    var symbol: String {
        switch self {
        case .neutral: return "person.2"
        case .female:  return "figure.stand.dress"
        case .male:    return "figure.stand"
        }
    }
}

// MARK: - Veri Modelleri

struct RuleCategory: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let colorHex: String
    let order: Int

    static let fallback = RuleCategory(
        id: "para", name: "Kurallar", symbol: "book", colorHex: "#2F6F5E", order: 0
    )
}

struct Rule: Codable, Identifiable, Hashable {
    let id: Int
    let seq: Int
    let categoryId: String
    let text: String
    let verify: Bool
    let variants: [String: String]?

    /// Kullanıcının seçtiği cinsiyete göre doğru kural metnini döndürür.
    func displayText(for gender: AppGender = AppSettings.gender) -> String {
        if let variants = variants {
            if gender == .female, let femaleText = variants["female"] {
                return femaleText
            } else if gender == .male, let maleText = variants["male"] {
                return maleText
            }
        }
        return text
    }

    static let fallback = Rule(
        id: 0, seq: 0, categoryId: "para",
        text: "Kural yüklenemedi. rules.json dosyasının Target Membership ayarını kontrol et.",
        verify: false, variants: nil
    )
}

struct RulesDocument: Codable {
    let version: Int
    let title: String
    let categories: [RuleCategory]
    let rules: [Rule]
}

enum RuleRepository {
    static let document: RulesDocument = {
        guard
            let url = Bundle.main.url(forResource: "rules", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let doc = try? JSONDecoder().decode(RulesDocument.self, from: data)
        else {
            return RulesDocument(version: 0, title: "", categories: [], rules: [])
        }
        return doc
    }()

    static let categories: [RuleCategory] =
        document.categories.sorted { $0.order < $1.order }

    /// Widget sırası (seq 1...1000).
    static let bySequence: [Rule] =
        document.rules.sorted { $0.seq < $1.seq }

    static func rules(in categoryId: String) -> [Rule] {
        document.rules
            .filter { $0.categoryId == categoryId }
            .sorted { $0.id < $1.id }
    }

    static func category(id: String) -> RuleCategory? {
        document.categories.first { $0.id == id }
    }
}

// MARK: - Widget Şekilleri

enum WidgetShape: String, CaseIterable, Identifiable {
    case small, medium, large, lockRectangular

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .small: return "Kare"
        case .medium: return "Yatay"
        case .large: return "Büyük"
        case .lockRectangular: return "Kilit"
        }
    }

    var title: String {
        switch self {
        case .small: return "küçük kare"
        case .medium: return "yatay orta"
        case .large: return "büyük"
        case .lockRectangular: return "dikdörtgen"
        }
    }

    var note: String {
        switch self {
        case .small: return "Ana ekran · 2×2"
        case .medium: return "Ana ekran · 4×2, yatay"
        case .large: return "Ana ekran · 4×4"
        case .lockRectangular: return "Kilit ekranı · dikdörtgen"
        }
    }

    var previewSize: CGSize {
        switch self {
        case .small: return CGSize(width: 158, height: 158)
        case .medium: return CGSize(width: 338, height: 158)
        case .large: return CGSize(width: 338, height: 354)
        case .lockRectangular: return CGSize(width: 160, height: 72)
        }
    }

    var widgetFamily: WidgetFamily {
        switch self {
        case .small: return .systemSmall
        case .medium: return .systemMedium
        case .large: return .systemLarge
        case .lockRectangular: return .accessoryRectangular
        }
    }
}

// MARK: - App Group Ayarları

enum AppSettings {
    private static let intervalHoursKey = "widget.intervalHours"
    private static let genderKey = "app.gender"
    private static let notifEnabledKey = "notifications.enabled"
    private static let notifHourKey = "notifications.hour"
    private static let notifMinuteKey = "notifications.minute"

    private static var store: UserDefaults {
        UserDefaults(suiteName: AppInfo.appGroup) ?? .standard
    }

    /// Kullanıcının alarm çarkıyla seçtiği saat (1...24 saat, varsayılan 12).
    static var intervalHours: Int {
        get {
            let saved = store.integer(forKey: intervalHoursKey)
            return saved > 0 ? min(max(saved, 1), 24) : 12
        }
        set {
            store.set(newValue, forKey: intervalHoursKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    static var gender: AppGender {
        get {
            let val = store.string(forKey: genderKey) ?? AppGender.neutral.rawValue
            return AppGender(rawValue: val) ?? .neutral
        }
        set {
            store.set(newValue.rawValue, forKey: genderKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    static var notificationsEnabled: Bool {
        get { store.bool(forKey: notifEnabledKey) }
        set { store.set(newValue, forKey: notifEnabledKey) }
    }

    static var notificationTime: Date {
        get {
            var c = DateComponents()
            c.hour = store.object(forKey: notifHourKey) != nil ? store.integer(forKey: notifHourKey) : 9
            c.minute = store.object(forKey: notifMinuteKey) != nil ? store.integer(forKey: notifMinuteKey) : 0
            return Calendar.current.date(from: c) ?? Date()
        }
        set {
            let cal = Calendar.current
            store.set(cal.component(.hour, from: newValue), forKey: notifHourKey)
            store.set(cal.component(.minute, from: newValue), forKey: notifMinuteKey)
        }
    }

    /// Seçilen saate göre döngü tamamlanma süresi açıklaması
    static func cycleNote(for hours: Int) -> String {
        let total = max(RuleRepository.bySequence.count, 1)
        let days = Int((Double(total) * Double(hours) / 24.0).rounded())
        return "Tüm kurallar yaklaşık \(days) günde bir kez gösterilir."
    }
}

// MARK: - Evrensel Rotasyon Motoru

enum RotationEngine {
    static let anchor: Date = {
        var c = DateComponents()
        c.year = 2026; c.month = 10; c.day = 10
        return Calendar.current.date(from: c) ?? Date()
    }()

    /// Herhangi bir saat süresine göre anlık slot numarasını hesaplar.
    static func slotIndex(
        for date: Date, intervalHours: Int, calendar: Calendar = .current
    ) -> Int {
        let safeInterval = max(intervalHours, 1)
        let hours = calendar.dateComponents([.hour], from: anchor, to: date).hour ?? 0
        return max(0, hours / safeInterval)
    }

    /// İlgili slot'un başlangıç zamanını verir.
    static func startDate(
        ofSlot slot: Int, intervalHours: Int, calendar: Calendar = .current
    ) -> Date {
        let safeInterval = max(intervalHours, 1)
        return calendar.date(byAdding: .hour, value: slot * safeInterval, to: anchor) ?? anchor
    }

    static func rule(forSlot slot: Int) -> Rule? {
        let list = RuleRepository.bySequence
        guard !list.isEmpty else { return nil }
        return list[slot % list.count]
    }

    /// Zaman çizelgesine kaç giriş üretileceği (en az 12, en çok 60).
    static func timelineLength(for intervalHours: Int) -> Int {
        let safe = max(intervalHours, 1)
        let entriesForTwoDays = 48 / safe
        return min(max(entriesForTwoDays, 12), 60)
    }
}

// MARK: - Renk Genişletmesi

extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        self.init(
            .sRGB,
            red: Double((v >> 16) & 0xFF) / 255,
            green: Double((v >> 8) & 0xFF) / 255,
            blue: Double(v & 0xFF) / 255,
            opacity: 1
        )
    }
}
```

---

### `NotificationManager.swift` (sadece `Dustur` uygulaması)

```swift
import Foundation
import UserNotifications

enum NotificationManager {
    static let notificationIdentifier = "dustur.daily.reminder"

    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    static func checkAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    static func scheduleDailyNotification(at date: Date) {
        cancelNotifications()
        guard AppSettings.notificationsEnabled else { return }

        let cal = Calendar.current
        let hour = cal.component(.hour, from: date)
        let minute = cal.component(.minute, from: date)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "Günün Düsturu"
        content.sound = .default

        let slot = RotationEngine.slotIndex(for: Date(), intervalHours: AppSettings.intervalHours)
        if let rule = RotationEngine.rule(forSlot: slot) {
            let category = RuleRepository.category(id: rule.categoryId)?.name ?? "Düstur"
            content.subtitle = category
            content.body = rule.displayText(for: AppSettings.gender)
        } else {
            content.body = "Bugünün yeni kuralını görmek için dokun."
        }

        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }
}
```

---

### `SettingsSheet.swift` (sadece `Dustur` uygulaması)

```swift
import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedGender: AppGender = AppSettings.gender
    @State private var selectedHours: Int = AppSettings.intervalHours
    @State private var notificationsEnabled: Bool = AppSettings.notificationsEnabled
    @State private var notificationTime: Date = AppSettings.notificationTime
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // Cinsiyet Tercihi
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
                    Text("Kadın seçildiğinde bakım, sağlık ve giyim kuralları kadınlara özel içeriklerle sunulur. Erkek seçildiğinde erkek odaklı kurallar gösterilir. Ortak kurallar herkes için aynıdır.")
                }

                // Widget Değişim Süresi (Alarm Saati Stili)
                Section {
                    HStack {
                        Text("Sözlerin Değişme Süresi")
                        Spacer()
                        Picker("Süre", selection: $selectedHours) {
                            ForEach(1...24, id: \.self) { h in
                                Text("\(h) saatte bir").tag(h)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .onChange(of: selectedHours) { _, newHours in
                        AppSettings.intervalHours = newHours
                    }
                } header: {
                    Text("Widget Hızı")
                } footer: {
                    Text(AppSettings.cycleNote(for: selectedHours))
                }

                // Günlük Bildirimler
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
                        DatePicker("Bildirim Saati", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .onChange(of: notificationTime) { _, newTime in
                                AppSettings.notificationTime = newTime
                                NotificationManager.scheduleDailyNotification(at: newTime)
                            }
                    }
                } header: {
                    Text("Hatırlatıcılar")
                } footer: {
                    Text("Her gün belirlediğin saatte günün öne çıkan hayat kuralı bildirim olarak iletilir.")
                }

                // Uygulama Bilgisi
                Section {
                    HStack {
                        Text("Sürüm")
                        Spacer()
                        Text("2.1.0").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Toplam Kural")
                        Spacer()
                        Text("1000 Kural · 10 Kategori").foregroundStyle(.secondary)
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
                Text("Günlük kural bildirimlerini alabilmek için sistem ayarlarından bildirim izni vermelisin.")
            }
        }
    }
}
```

---

### `AddWidgetSheet.swift` (sadece `Dustur` uygulaması)

Kullanıcının widget şeklini seçtiği ve değişim süresini **tıpkı bir alarm saati / sayaç gibi tekerlekle (Wheel Picker)** 1 saat, 2 saat, 3 saat... 24 saat olarak manuel ayarlayabildiği ekran.

```swift
import SwiftUI
import WidgetKit

struct AddWidgetSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var shape: WidgetShape = .small
    @State private var selectedHours: Int = AppSettings.intervalHours
    @State private var showSteps = false

    private var sample: (rule: Rule, category: RuleCategory) {
        let slot = RotationEngine.slotIndex(for: Date(), intervalHours: selectedHours)
        let rule = RotationEngine.rule(forSlot: slot) ?? Rule.fallback
        let category = RuleRepository.category(id: rule.categoryId) ?? RuleCategory.fallback
        return (rule, category)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Şekil Seçimi ve Canlı Önizleme
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
                } header: {
                    Text("Şekil")
                } footer: {
                    Text(shape.note)
                }

                // Alarm Saati / Sayaç Stili Manuel Süre Seçici
                Section {
                    VStack(spacing: 8) {
                        HStack {
                            Spacer()
                            Picker("Saat", selection: $selectedHours) {
                                ForEach(1...24, id: \.self) { h in
                                    Text("\(h)").tag(h)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 90, height: 130)
                            .clipped()

                            Text("saatte bir")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.primary)
                            Spacer()
                        }

                        Text("Sözler her \(selectedHours) saatte bir otomatik değişir.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Sözlerin Değişme Süresi (Alarm / Sayaç)")
                } footer: {
                    Text(AppSettings.cycleNote(for: selectedHours))
                }

                // Kaydet Butonu
                Section {
                    Button {
                        AppSettings.intervalHours = selectedHours
                        showSteps = true
                    } label: {
                        Text("Kaydet ve nasıl ekleneceğini göster")
                            .frame(maxWidth: .infinity)
                    }
                } footer: {
                    Text("iOS, uygulamaların widget'ı kendiliğinden eklemesine izin vermez. Belirlediğin süre tüm \(AppInfo.name) widget'larına uygulanır.")
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

struct WidgetPreview: View {
    let shape: WidgetShape
    let rule: Rule
    let category: RuleCategory

    var body: some View {
        let size = shape.previewSize
        let isLock = shape == .lockRectangular

        ZStack {
            if isLock {
                Color(.secondarySystemFill)
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
        .frame(maxWidth: size.width)
        .aspectRatio(size.width / size.height, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: isLock ? 12 : 22, style: .continuous))
        .animation(.snappy, value: shape)
    }
}

struct AddWidgetSteps: View {
    let shape: WidgetShape
    let hours: Int
    let onDone: () -> Void

    private var steps: [String] {
        if shape == .lockRectangular {
            return [
                "Kilit ekranına uzun bas.",
                "Özelleştir'e dokun ve Kilit Ekranı'nı seç.",
                "Saatin altındaki alana dokun ve \(AppInfo.name) widget'ını seç.",
                "Dikdörtgen widget'ı ekle ve Bitti'ye bas."
            ]
        }
        return [
            "Ana ekranda boş bir yere uzun bas.",
            "Sol üstteki + düğmesine dokun.",
            "\(AppInfo.name) uygulamasını bul ve \(shape.title) boyutu seç.",
            "Widget Ekle'ye dokun ve Bitti'ye bas."
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Süre kaydedildi: Her \(hours) saatte bir")
                .font(.headline)

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
```

---

### `RuleWidget.swift` (sadece `DusturWidget` hedefi)

```swift
import WidgetKit
import SwiftUI

struct RuleEntry: TimelineEntry {
    let date: Date
    let rule: Rule
    let category: RuleCategory
    let gender: AppGender
}

struct RuleProvider: TimelineProvider {
    func placeholder(in context: Context) -> RuleEntry {
        let hours = AppSettings.intervalHours
        let slot = RotationEngine.slotIndex(for: Date(), intervalHours: hours)
        return makeEntry(slot: slot, date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (RuleEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RuleEntry>) -> Void) {
        let now = Date()
        let hours = AppSettings.intervalHours
        let first = RotationEngine.slotIndex(for: now, intervalHours: hours)
        let count = RotationEngine.timelineLength(for: hours)

        // Her giriş seçilen saat aralığında (1 saat, 2 saat, 5 saat...) gösterilir
        let entries: [RuleEntry] = (0..<count).map { offset in
            let slot = first + offset
            let date = offset == 0
                ? now
                : RotationEngine.startDate(ofSlot: slot, intervalHours: hours)
            return makeEntry(slot: slot, date: date)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func makeEntry(slot: Int, date: Date) -> RuleEntry {
        let rule = RotationEngine.rule(forSlot: slot) ?? Rule.fallback
        let category = RuleRepository.category(id: rule.categoryId) ?? RuleCategory.fallback
        return RuleEntry(date: date, rule: rule, category: category, gender: AppSettings.gender)
    }
}

struct RuleWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: RuleEntry

    var body: some View {
        RuleCardContent(
            rule: entry.rule,
            category: entry.category,
            family: family,
            gender: entry.gender
        )
        .containerBackground(for: .widget) {
            if family == .accessoryRectangular {
                Color.clear
            } else {
                RuleCardBackground(category: entry.category)
            }
        }
    }
}

@main
struct RuleWidget: Widget {
    let kind = "RuleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RuleProvider()) { entry in
            RuleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Günün Düsturu")
        .description("Seçtiğin sürede bir yeni kural gösterir.")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge, .accessoryRectangular
        ])
    }
}
```

---

### `RuleCardViews.swift` (iki hedef de: `Dustur` ve `DusturWidget`)

```swift
import SwiftUI
import WidgetKit

struct RuleCardContent: View {
    let rule: Rule
    let category: RuleCategory
    let family: WidgetFamily
    var gender: AppGender = AppSettings.gender

    var body: some View {
        let text = rule.displayText(for: gender)

        switch family {
        case .accessoryRectangular:
            // Kilit ekranı
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name.uppercased())
                    .font(.caption2.weight(.bold))
                    .widgetAccentable()
                Text(text)
                    .font(.caption)
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        default:
            // Ana ekran (kare, yatay, büyük)
            VStack(alignment: .leading, spacing: 8) {
                Label(category.name, systemImage: category.symbol)
                    .font(.caption.weight(.semibold))
                    .opacity(0.85)
                Text(text)
                    .font(Self.bodyFont(for: family))
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private static func bodyFont(for family: WidgetFamily) -> Font {
        switch family {
        case .systemSmall: return .footnote.weight(.medium)
        case .systemLarge: return .title3.weight(.medium)
        default:           return .callout.weight(.medium)
        }
    }
}

struct RuleCardBackground: View {
    let category: RuleCategory

    var body: some View {
        let base = Color(hex: category.colorHex)
        LinearGradient(
            colors: [base, base.opacity(0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
```

---

### `HomeView.swift` (sadece `Dustur` uygulaması)

```swift
import SwiftUI

struct HomeView: View {
    @State private var showAddWidget = false
    @State private var showSettings = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AddWidgetButton { showAddWidget = true }

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(RuleRepository.categories) { category in
                            NavigationLink(value: category) {
                                CategoryTile(category: category)
                            }
                            .buttonStyle(.plain)
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
                            .font(.body.weight(.medium))
                    }
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

struct AddWidgetButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.badge.plus")
                    .font(.title3.weight(.semibold))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Widget Ekle")
                        .font(.headline)
                    Text("Şekli ve değişim süresini seç")
                        .font(.caption)
                        .opacity(0.8)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .opacity(0.7)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                Color(hex: "#1F2A37").gradient,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CategoryTile: View {
    let category: RuleCategory

    var body: some View {
        let color = Color(hex: category.colorHex)
        let count = RuleRepository.rules(in: category.id).count

        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(color.gradient)

            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: category.symbol)
                    .font(.title2.weight(.semibold))
                Spacer(minLength: 8)
                Text(category.name)
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.leading)
                Text("\(count) kural")
                    .font(.caption)
                    .opacity(0.8)
            }
            .foregroundStyle(.white)
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
```

---

### `RuleListView.swift` (sadece `Dustur` uygulaması)

```swift
import SwiftUI

struct RuleListView: View {
    let category: RuleCategory
    private let rules: [Rule]

    init(category: RuleCategory) {
        self.category = category
        self.rules = RuleRepository.rules(in: category.id)
    }

    var body: some View {
        List {
            ForEach(Array(rules.enumerated()), id: \.element.id) { index, rule in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.footnote.monospacedDigit().weight(.semibold))
                        .foregroundStyle(Color(hex: category.colorHex))
                        .frame(width: 28, alignment: .trailing)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.displayText(for: AppSettings.gender))
                            .font(.body)

                        if rule.verify {
                            Text("Genel bilgi, güncel kaynakla doğrula")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

---

### `DusturApp.swift` (sadece `Dustur` uygulaması)

```swift
import SwiftUI

@main
struct DusturApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
```

---

## 6. İçeriği Düzenlemek

- **Bir kuralın genel metnini değiştirmek:** `rules.json` içinde `text` alanını düzenle. `id` ve `seq` değişmesin.
- **Cinsiyet varyantı eklemek / düzenlemek:** Kural objesine `"variants": { "male": "...", "female": "..." }` ekle veya güncelle. Kadın seçildiğinde `female`, erkek seçildiğinde `male`, genel/nötr seçildiğinde `text` metni gösterilir.
- **Sıralamayı (`seq`) yeniden karıştırmak için:**

```python
import json, random
doc = json.load(open("rules.json", encoding="utf-8"))
cats = [c["id"] for c in sorted(doc["categories"], key=lambda c: c["order"])]
rng = random.Random(42)
orders = {}
for ci, cid in enumerate(cats):
    ids = [r["id"] for r in doc["rules"] if r["categoryId"] == cid]
    rng.shuffle(ids)
    orders[ci] = ids
by_id = {r["id"]: r for r in doc["rules"]}
for k in range(1000):
    cycle, pos = divmod(k, 10)
    by_id[orders[(pos + cycle) % 10][cycle]]["seq"] = k + 1
json.dump(doc, open("rules.json", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
```

---

## 7. Bilinen Sınırlar

1. **Widget otomatik eklenemez:** iOS bunu yalnızca kullanıcıya bırakır. "Widget Ekle" ekranı seçimi kaydeder ve adımları gösterir, widget'ı kendisi koymaz.
2. **App Group gereklidir:** Yapılandırılmazsa widget uygulamanın kaydettiği değişim süresini ve cinsiyet tercihini göremez.
3. **Zamanlama:** iOS, widget'ı tam saniyesinde değil kendi pil bütçesine göre günceller. Slot sınırlarında birkaç dakikalık gecikme normaldir.
4. **Kural doğruluğu:** 1000 kuralın taslağı derlenmiştir. `verify: true` olan 151 kural (hukuk, sağlık, acil durum) için resmi kaynaktan doğrulama yapılması önerilir.

---

## 8. Sonraki Adımlar

1. Projeyi kurup App Group'u yapılandır, cihazda çalıştır.
2. "Widget Ekle" ekranında alarm saati çarkıyla 1 saat, 2 saat vb. süre seçip önizlemeyi dene.
3. Ayarlar ekranındaki cinsiyet seçimini test et ve ana ekran widget'ına yansıdığını gözlemle.
