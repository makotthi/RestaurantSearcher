import UIKit

extension UIView {
    // フェードインの処理
    func fadeIn(duration: TimeInterval = 0.2, completed: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false

        UIView.animate(withDuration: duration,
            animations: {
                self.alpha = 1
            }) { _ in
                completed?()
        }
    }
}
