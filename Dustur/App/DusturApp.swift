import SwiftUI

@main
struct DusturApp: App {
    init() {
        // iOS Ayarlarında "Bildirimler" menüsünün anında belirmesi için kayıt isteği
        NotificationManager.registerWithSystem()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
