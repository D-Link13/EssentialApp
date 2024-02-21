import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    
    public var refreshController: FeedRefreshViewController?
    private var imageLoader: ImageLoader?
    private var onViewIsAppearing: (() -> Void)?
    private var tableModel = [FeedImage]() {
        didSet { tableView.reloadData() }
    }
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    
    public convenience init(feedLoader: FeedLoader, imageLoader: ImageLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }
        
        onViewIsAppearing = { [weak self] in
            self?.refreshController?.refresh()
            self?.onViewIsAppearing = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?()
    }
    
    private func startTask(forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { _ in }
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController {
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = cellModel.location == nil
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadFeed = { [weak self, weak cell] in
            guard let self else { return }
            
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.url) { [weak cell] result in
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

}

// MARK: - UITableViewDelegate

extension FeedViewController {
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
}

// MARK: - UITableViewDataSourcePrefetching

extension FeedViewController: UITableViewDataSourcePrefetching {
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(startTask)
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
}
