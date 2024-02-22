import UIKit

public final class FeedRefreshViewController: NSObject {
    
    private let presenter: FeedViewPresenter
    public lazy var view = loadView()
    
    init(presenter: FeedViewPresenter) {
        self.presenter = presenter
    }
    
    @objc
    func refresh() {
        presenter.loadFeed()
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

extension FeedRefreshViewController: FeedLoadingView {
    
    func display(_ viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
    }
}
