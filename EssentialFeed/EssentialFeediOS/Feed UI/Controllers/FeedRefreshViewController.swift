import UIKit

public final class FeedRefreshViewController: NSObject {
    
    private let viewModel: FeedViewModel
    public lazy var view = binded(UIRefreshControl())
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc
    func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { [weak self] vm in
            vm.isLoading ? self?.view.beginRefreshing() : self?.view.endRefreshing()
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
