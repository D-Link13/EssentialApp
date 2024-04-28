import EssentialFeed
import EssentialFeediOS
import Foundation
import Combine

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
    
    private let model: FeedImage
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    var presenter: FeedImagePresenter<View, Image>?
    private var cancellable: Cancellable?
    
    init(model: FeedImage, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.loader = loader
    }
}

extension FeedImageDataLoaderPresentationAdapter: FeedImageCellControllerDelegate {
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        cancellable = loader(model.url).sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                }
            }, receiveValue: { [weak self] imageData in
                self?.presenter?.didFinishLoadingImageData(with: imageData, for: model)
            }
        )
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
