import XCTest
import EssentialFeed

class FeedStore {
    var deleteCachedFeedCallCount = 0
    var insertCachedFeedCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
    
    func complete(with error: Error, at index: Int = 0) {
        
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        
        store.complete(with: anyNSError())
        
        XCTAssertEqual(store.insertCachedFeedCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func uniqueFeedItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
}
