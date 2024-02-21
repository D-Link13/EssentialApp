import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
    
    typealias Observer<T> = (T) -> Void
    
    private let model: FeedImage
    private let imageLoader: ImageLoader
    private var task: FeedImageDataLoaderTask?
    private let transfromationBlock: (Data) -> Image?
    
    init(model: FeedImage, imageLoader: ImageLoader, transfromationBlock: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.transfromationBlock = transfromationBlock
    }
    
    var hasLocation: Bool { model.location != nil }
    var location: String? { model.location }
    var description: String? { model.description }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: ImageLoader.Result) {
        if let image = (try? result.get()).flatMap(transfromationBlock) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
    
}
