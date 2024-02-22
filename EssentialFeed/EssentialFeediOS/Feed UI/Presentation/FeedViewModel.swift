import Foundation
import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadFeedStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    func loadFeed() {
        onLoadFeedStateChange?(true)
        feedLoader.load() { [weak self] result in
            if case let .success(feed) = result {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadFeedStateChange?(false)
        }
    }
    
}
