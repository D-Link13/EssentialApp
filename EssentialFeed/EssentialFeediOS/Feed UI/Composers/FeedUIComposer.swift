import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        
        let feedController = makeWith(
            delegate: presentationAdapter,
            title: FeedViewPresenter.title)
        
        presentationAdapter.presenter = FeedViewPresenter(
            feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader),
            loadingView: WeakRefVirtualProxy(feedController))
        return feedController
    }
    
    private static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let storyboard = UIStoryboard(name: "Feed", bundle: Bundle(for: FeedViewController.self))
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.delegate = delegate
        controller.title = FeedViewPresenter.title
        return controller
    }
}

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

final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { feedImage in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: feedImage, loader: loader)
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                transfromationBlock: UIImage.init)
            return view
        }
    }
}

final class FeedLoaderPresentationAdapter {
    
    private let feedLoader: FeedLoader
    var presenter: FeedViewPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

extension FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    func didRequestFeedRefresh() {
        loadFeed()
    }
}

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        object?.display(viewModel)
    }
    
}
