import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject {
    
    private let feedLoader: FeedLoader
    public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    @objc
    func refresh() {
        view.beginRefreshing()
        feedLoader.load() { [weak self] result in
            if case let .success(feed) = result {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
