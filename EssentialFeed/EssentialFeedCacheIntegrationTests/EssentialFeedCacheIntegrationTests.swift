import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, [], "Expected empty feed")
            case let .failure(error):
                XCTFail("Expected to load feed successfully, got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutForSaving = makeSUT()
        let sutForLoading = makeSUT()
        let feed = uniqueImageFeed().models
        
        let savingExp = expectation(description: "Wait for saving completion")
        sutForSaving.save(feed) { savingError in
            XCTAssertNil(savingError, "Expected to save feed successfully")
            savingExp.fulfill()
        }
        
        wait(for: [savingExp], timeout: 1.0)
        
        let loadingExp = expectation(description: "Wait for loading completion")
        sutForLoading.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, feed)
            case let .failure(error):
                XCTFail("Expected to load feed successfully, got \(error) instead")
            }
            loadingExp.fulfill()
        }
        
        wait(for: [loadingExp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = storeURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func storeURL() -> URL {
        cachesDirectory().appendingPathExtension("\(type(of: self)).store")
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
        return try? FileManager.default.removeItem(at: storeURL())
    }
}
