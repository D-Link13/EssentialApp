import UIKit

final public class FeedImageCell: UITableViewCell {
    
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    var onReuse: (() -> Void)?
    
    @IBAction private func feedImageRetryButtonAction() {
        onRetry?()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        onReuse?()
    }
    
    private func adjustButtonTitleLabel() {
        feedImageRetryButton.titleLabel?.font = .systemFont(ofSize: 60)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        adjustButtonTitleLabel()
    }
}
