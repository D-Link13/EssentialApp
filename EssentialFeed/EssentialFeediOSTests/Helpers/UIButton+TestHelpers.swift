import UIKit

extension UIButton {
    
    func simulateTap() {
        self.allTargets.forEach { target in
            self.actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
