import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    
    public var refreshController: FeedRefreshViewController?
    private var imageLoader: ImageLoader?
    private var onViewIsAppearing: (() -> Void)?
    private var tableModel = [FeedImage]() {
        didSet { tableView.reloadData() }
    }
    private var cellControllers = [IndexPath: FeedImageCellController]()
    
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
    
    private func createCellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let cellModel = tableModel[indexPath.row]
        let cellController = FeedImageCellController(model: cellModel, imageLoader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController {
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        createCellController(forRowAt: indexPath).view()
    }

}

// MARK: - UITableViewDelegate

extension FeedViewController {
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
}

// MARK: - UITableViewDataSourcePrefetching

extension FeedViewController: UITableViewDataSourcePrefetching {
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            createCellController(forRowAt: indexPath).prefetch()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
}
