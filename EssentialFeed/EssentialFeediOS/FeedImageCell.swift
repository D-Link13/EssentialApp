import UIKit

final public class FeedImageCell: UITableViewCell {
    
    public let locationContainer = UIView()
    public let descriptionLabel = UILabel()
    public let locationLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    
    public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(feedImageRetryButtonAction), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc
    private func feedImageRetryButtonAction() {
        onRetry?()
    }
}
