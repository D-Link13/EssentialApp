import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
@testable import EssentiaApp
import Combine

final class ImageCommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, imageCommentsTitle)
    }
    
    func test_loadCommentsActions_requestsCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expect no loading requests before view is loaded")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates another load")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected no new loading requests after load was called once view has been loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once view is loaded")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator after loading completes successfully")
        
        sut.simulateAppearance()
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once view is appearing not for the first time")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expect loading indicator once user initiated another load")
        
        loader.completeCommentsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expect no loading indicator after loading completes successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expect loading indicator once user initiated another load")
        
        loader.completeCommentsLoadingWithError(at: 2)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expect no loading indicator after loading completes with error")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let (sut, loader) = makeSUT()
        let comment0 = makeComment()
        let comment1 = makeComment(message: "another message", username: "another username")
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [ImageComment]())
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let (sut, loader) = makeSUT()
        let comment0 = makeComment()
        let comment1 = makeComment(message: "another message", username: "another username")
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [ImageComment]())
        
        loader.completeCommentsLoading(with: [comment0, comment1], at: 0)
        assertThat(sut, isRendering: [comment0, comment1])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [ImageComment]())
    }
    
    func test_loadCommentsCompletion_doesNotAlterCurrentRendingStateOnError() {
        let (sut, loader) = makeSUT()
        let comment = makeComment()
        
        sut.simulateAppearance()
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment])
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeComment(message: String = "a message", createdAt: Date = Date(), username: String = "a username") -> ImageComment {
        ImageComment(id: UUID(), message: message, createdAt: createdAt, username: username)
    }
    
    private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
        
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedComments() == comments.count else {
            return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedComments()) instead.", file: file, line: line)
        }
        
        let viewModel = ImageCommentsPresenter.map(comments)
        
        viewModel.comments.enumerated().forEach { index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
        }
    }
    
    var imageCommentsTitle: String {
        ImageCommentsPresenter.title
    }
    
    private class LoaderSpy {
        
        private(set) var requests = [PassthroughSubject<[ImageComment], Error>]()
        
        var loadCommentsCallCount: Int {
            requests.count
        }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
        }
        
        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "any error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
