import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    private let transfromationBlock: (Data) -> Image?
    
    init(view: View, transfromationBlock: @escaping (Data) -> Image?) {
        self.view = view
        self.transfromationBlock = transfromationBlock
    }
    
    func didStartLodingImageData(for model: FeedImage) {
        
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        
        guard let image = transfromationBlock(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: image,
            isLoading: false,
            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}

