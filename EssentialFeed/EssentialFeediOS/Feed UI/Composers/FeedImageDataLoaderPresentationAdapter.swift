import EssentialFeed

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
    
    private let model: FeedImage
    private let loader: FeedImageDataLoader
    var presenter: FeedImagePresenter<View, Image>?
    private var task: FeedImageDataLoaderTask?
    
    init(model: FeedImage, loader: FeedImageDataLoader) {
        self.model = model
        self.loader = loader
    }
}

extension FeedImageDataLoaderPresentationAdapter: FeedImageCellControllerDelegate {
    
    func didRequestImage() {
        presenter?.didStartLodingImageData(for: model)
        
        let model = self.model
        task = loader.loadImageData(from: model.url, completion: { [weak self] result in
            switch result {
            case let .success(imageData):
                self?.presenter?.didFinishLoadingImageData(with: imageData, for: model)
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        })
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
