import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestsFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        sut.replaceRefreshControllerWithFakeForiOS17Support()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expect no loading requests before view is loaded")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates another load")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected no new loading requests after load was called once view has been loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.replaceRefreshControllerWithFakeForiOS17Support()
        
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator before view is loaded")
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading()
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator after loading completion")
        
        sut.simulateAppearance()
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once view is appearing not for the first time")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expect loading indicator once user initiated another load")
        
        loader.completeFeedLoading()
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expect no loading indicator after loading completion")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let (sut, loader) = makeSUT()
        let image1 = makeFeedImage(description: "a description", location: "a location")
        let image2 = makeFeedImage(description: "another description")
        let image3 = makeFeedImage(location: "another location")
        let image4 = makeFeedImage()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.numberOfRenderedItems(), 0)
        
        loader.completeFeedLoading(with: [image1])
        XCTAssertEqual(sut.numberOfRenderedItems(), 1)
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image1, image2, image3, image4])
        XCTAssertEqual(sut.numberOfRenderedItems(), 4)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeFeedImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    class LoaderSpy: FeedLoader {
        private(set) var completions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            completions[index](.success(feed))
        }
    }
}

private extension FeedViewController {
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        refreshControl?.isRefreshing == true
    }
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
        }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func numberOfRenderedItems() -> Int {
        tableView.numberOfRows(inSection: numberOfRenderedSections())
    }
    
    func numberOfRenderedSections() -> Int { 0 }
 }

private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        self.allTargets.forEach { target in
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
