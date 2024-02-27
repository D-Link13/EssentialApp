import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject {
    
    @IBOutlet public var view: UIRefreshControl?
    
    var delegate: FeedRefreshViewControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
}

extension FeedRefreshViewController: FeedLoadingView {
    
    func display(_ viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view?.beginRefreshing() : view?.endRefreshing()
    }
}
