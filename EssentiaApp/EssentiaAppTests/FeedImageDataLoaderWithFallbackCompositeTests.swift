import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return Task()
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let primaryLoader = ImageDataLoaderSpy()
        let fallbackLoader = ImageDataLoaderSpy()
        
        _ = FeedImageDataLoaderWithFallbackComposite(
            primary: primaryLoader,
            fallback: fallbackLoader)
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    private class ImageDataLoaderSpy: FeedImageDataLoader {
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
    }
    
}
