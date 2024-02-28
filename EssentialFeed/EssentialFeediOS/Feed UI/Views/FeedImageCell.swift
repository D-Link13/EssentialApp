import UIKit

final public class FeedImageCell: UITableViewCell {
    
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func feedImageRetryButtonAction() {
        onRetry?()
    }
}
