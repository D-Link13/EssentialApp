import EssentialFeed
import EssentialFeediOS
import Combine

final class FeedLoaderPresentationAdapter {
    
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    var cancellable: Cancellable?
    
    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        presenter?.didStartLoading()
        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
                },
                receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoading(with: feed)
                }
            )
    }
}

extension FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    func didRequestFeedRefresh() {
        loadFeed()
    }
}
