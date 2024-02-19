import XCTest
import UIKit
import EssentialFeed

class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        onViewIsAppearing = { controller in
            controller.load()
            controller.onViewIsAppearing = nil
        }
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    @objc
    private func load() {
        refreshControl?.beginRefreshing()
        loader?.load() { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewAppearance_loadsFeedOnce() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.refreshControl?.endRefreshing()
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 2)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewAppearance_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_viewAppearance_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    func test_pullToRefresh_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        sut.refreshControl?.simulatePullToRefresh()
        
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private(set) var completions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int = 0) {
            completions[index](.success([]))
        }
    }
}

private extension FeedViewController {
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControllerWithFakeForiOS17Support()
        }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func replaceRefreshControllerWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach{ target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fake
    }
}

private class FakeRefreshControl: UIRefreshControl {
    
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
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
