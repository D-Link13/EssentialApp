import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validate()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotdeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validate()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimastamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expectedFeed = uniqueImageFeed()
        
        sut.validate()
        store.completeRetrieval(with: expectedFeed.local, timestamp: lessThanSevenDaysOldTimastamp)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let sevenDaysOldTimastamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expectedFeed = uniqueImageFeed()
        
        sut.validate()
        store.completeRetrieval(with: expectedFeed.local, timestamp: sevenDaysOldTimastamp)
        
        XCTAssertEqual(store.messages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesCacheOnMoreThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimastamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expectedFeed = uniqueImageFeed()
        
        sut.validate()
        store.completeRetrieval(with: expectedFeed.local, timestamp: moreThanSevenDaysOldTimastamp)
        
        XCTAssertEqual(store.messages, [.retrieve, .deleteCachedFeed])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
}
