import SwiftUI
import UIKit

/// Özel geri butonu kullanılan veya gezinme çubuğu gizlenen sayfalarda
/// kenardan kaydırarak geri dönmeyi (interactive pop gesture) güvenli şekilde aktifleştirir.
public struct InteractivePopGestureModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(InteractivePopHelper())
    }
}

private struct InteractivePopHelper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HelperVC {
        HelperVC()
    }

    func updateUIViewController(_ uiViewController: HelperVC, context: Context) {}

    final class HelperVC: UIViewController, UIGestureRecognizerDelegate {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            navigationController?.interactivePopGestureRecognizer?.delegate = self
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let nav = navigationController else { return false }
            return nav.viewControllers.count > 1
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
    }
}

public extension View {
    /// Ekranın sol kenarından sağa kaydırarak geri dönme jestini etkinleştirir.
    func enableInteractivePopGesture() -> some View {
        modifier(InteractivePopGestureModifier())
    }
}
