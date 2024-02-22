import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: ImageLoader) -> FeedViewController {
        let presenter = FeedViewPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: presenter)
        let feedController = FeedViewController(refreshController: refreshController)
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
        return feedController
    }
}

final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let loader: ImageLoader
    
    init(controller: FeedViewController, imageLoader: ImageLoader) {
        self.controller = controller
        self.loader = imageLoader
    }
    
    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map {
            FeedImageCellController(viewModel: FeedImageViewModel(model: $0, imageLoader: loader, transfromationBlock: UIImage.init))
        }
    }
}

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}
