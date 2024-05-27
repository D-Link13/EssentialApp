import UIKit
import EssentialFeed
import EssentialFeediOS

final class CommentsViewAdapter: ResourceView {
    
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { CellController(id: $0, dataSource: ImageCommentCellController(model: $0)) })
    }
}
