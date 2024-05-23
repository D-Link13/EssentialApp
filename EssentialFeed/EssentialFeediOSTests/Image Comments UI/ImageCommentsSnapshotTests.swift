import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ImageCommentsSnapshotTests: XCTestCase {
    
    func test_listWithContent() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), name: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), name: "IMAGE_COMMENTS_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func comments() -> [CellController] {
        commentControllers().map { CellController(dataSource: $0) }
    }
    
    private func commentControllers() -> [ImageCommentCellController] {
        [
            ImageCommentViewModel(
                message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                date: "1000 years ago",
                username: "a long long long username"),
            ImageCommentViewModel(
                message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                date: "10 days ago",
                username: "a username"),
            ImageCommentViewModel(
                message: "nice",
                date: "1 second ago",
                username: "a .")
        ].map { ImageCommentCellController(model: $0) }
    }
}
