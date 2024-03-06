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
        let sut = makeFeedLoader()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutForSaving = makeFeedLoader()
        let sutForLoading = makeFeedLoader()
        let feed = uniqueImageFeed().models
        
        save(feed, with: sutForSaving)
        
        expect(sutForLoading, toLoad: feed)
    }
    
    func test_load_overridesItemsSavedOnASeparateInstance() {
        let sutForFirstSave = makeFeedLoader()
        let sutForLatestSave = makeFeedLoader()
        let sutForLoading = makeFeedLoader()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        
        save(firstFeed, with: sutForFirstSave)
        save(latestFeed, with: sutForLatestSave)
        
        expect(sutForLoading, toLoad: latestFeed)
    }
    
    // MARK: - LocalFeedImageDataLoader Tests
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueFeedImage()
        let dataToSave = anyData()
        
        save([image], with: feedLoader)
        save(dataToSave, for: image.url, with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
    }
    
    // MARK: - Helpers
    
    private func makeFeedLoader(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = storeURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, expectedFeed, file: file, line: line)
            case let .failure(error):
                XCTFail("Expected to load feed successfully, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageDataLoader {
        let storeURL = storeURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func save(_ feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for saving completion")
        
        sut.save(feed) { savingResult in
            if case let .failure(savingError) = savingResult {
                XCTFail("Expected to save feed successfully", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func storeURL() -> URL {
        cachesDirectory().appendingPathExtension("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func save(_ data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save image data successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(loadedData):
                XCTAssertEqual(loadedData, expectedData, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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
