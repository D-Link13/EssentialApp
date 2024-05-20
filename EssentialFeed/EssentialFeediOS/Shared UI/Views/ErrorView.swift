import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var button: UIButton!

    public var message: String? {
        get { return isVisible ? button.titleLabel?.text : nil }
        set { setMessageAnimated(newValue) }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        button.setTitle(nil, for: .normal)
        alpha = 0
        adjustButtonTitleLabel()
    }

    private var isVisible: Bool {
        return alpha > 0
    }
    
    private func adjustButtonTitleLabel() {
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
    }

    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }

    private func showAnimated(_ message: String) {
        button.setTitle(message, for: .normal)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @IBAction private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.button.setTitle(nil, for: .normal) }
            })
    }
}
