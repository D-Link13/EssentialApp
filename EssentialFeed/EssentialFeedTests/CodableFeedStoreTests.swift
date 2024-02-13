import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyCacheOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieveTwice_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        insert((feed.local, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed.local, timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        insert((feed.local, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(feed.local, timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieveTwice_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected feed to be inserted successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected feed to be inserted successfully")
        
        expect(sut, toRetrieve: .found(latestFeed, latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNotNil(insertionError, "Expected feed to be inserted with a failure")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = delete(from: sut)
        XCTAssertNil(deletionError, "Expected feed to be deleted successfully")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_erasesPreviouslyCachedValues() {
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = delete(from: sut)
        XCTAssertNil(deletionError, "Expected feed to be deleted successfully")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversFailureOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = delete(from: sut)
        XCTAssertNotNil(deletionError, "Expected feed to be deleted with a failure")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperations = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperations.append(op3)
            op3.fulfill()
        }
        
        wait(for: [op1, op2, op3], timeout: 5.0)
        XCTAssertEqual(completedOperations, [op1, op2, op3])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(receivedFeed, receivedTimestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for completion")
        
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    private func delete(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for completion")
        
        var deletionError: Error?
        sut.deleteCachedFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    private var testSpecificStoreURL: URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func setupEmptyStoreState() -> ()? {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() -> ()? {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() -> ()? {
        return try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }

}
