import UIKit
import EssentialFeed

public class FeedImageCellController {
    
    private let model: FeedImage
    private let imageLoader: ImageLoader
    private var task: FeedImageDataLoaderTask?
    
    public init(model: FeedImage, imageLoader: ImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = model.location == nil
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadFeed = { [weak self, weak cell] in
            guard let self else { return }
            
            self.task = imageLoader.loadImageData(from: model.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageContainer.stopShimmering()
                cell?.feedImageRetryButton.isHidden = (image != nil)
            }
        }
        cell.onRetry = loadFeed
        loadFeed()
            
        return cell
    }
    
    func prefetch() {
        self.task = imageLoader.loadImageData(from: model.url) { _ in }
    }
    
    deinit {
        task?.cancel()
    }
}
