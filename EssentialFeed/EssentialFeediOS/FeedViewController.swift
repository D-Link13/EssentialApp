import UIKit
import EssentialFeed

public protocol ImageLoader {
    func loadImageData(from url: URL)
    func cancelImageDataLoad(from url: URL)
}

final public class FeedViewController: UITableViewController {
    
    private var feedLoader: FeedLoader?
    private var imageLoader: ImageLoader?
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    private var tableModel = [FeedImage]()
    
    public convenience init(loader: FeedLoader, imageLoader: ImageLoader) {
        self.init()
        self.feedLoader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        onViewIsAppearing = { controller in
            controller.load()
            controller.onViewIsAppearing = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    @objc
    private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load() { [weak self] result in
            switch result {
            case let .success(feed):
                self?.tableModel = feed
                self?.tableView.reloadData()
            case .failure:
                break
            }
            self?.refreshControl?.endRefreshing()
        }
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
        
        imageLoader?.loadImageData(from: cellModel.url)
            
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        imageLoader?.cancelImageDataLoad(from: cellModel.url)
    }
}
