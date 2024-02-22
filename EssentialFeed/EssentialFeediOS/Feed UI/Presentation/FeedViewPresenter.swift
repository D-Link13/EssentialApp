import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedViewPresenter {
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func loadFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load() { [weak self] result in
            if case let .success(feed) = result {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
    
}
