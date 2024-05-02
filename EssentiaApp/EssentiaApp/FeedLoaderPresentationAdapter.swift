import EssentialFeed
import EssentialFeediOS
import Combine

final class FeedLoaderPresentationAdapter {
    
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    var presenter: FeedPresenter?
    var cancellable: Cancellable?
    
    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        presenter?.didStartLoadingFeed()
        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        self?.presenter?.didFinishLoadingFeed(with: error)
                    }
                },
                receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoadingFeed(with: feed)
                }
            )
    }
}

extension FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    func didRequestFeedRefresh() {
        loadFeed()
    }
}
