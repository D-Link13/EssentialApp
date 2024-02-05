import XCTest

class FeedStore {
    var deleteCacheFeedCallCount = 0
}

class LocalFeedLoader {}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader()
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
}
