import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

class FeedImageCellController: FeedImageView {
    typealias Image = UIImage
    
    private let delegate: FeedImageCellControllerDelegate
    var cell: FeedImageCell?
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func prefetch() {
        delegate.didRequestImage()
    }
    
    func cancel() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    func display(_ viewModel: FeedImageViewModel<Image>) {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.setImageAnimated(viewModel.image)
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.onRetry = delegate.didRequestImage
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
    }
    
    private func releaseCellForReuse() {
        cell?.onReuse = nil
        cell = nil
    }
}
