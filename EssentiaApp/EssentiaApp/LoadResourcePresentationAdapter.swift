import EssentialFeed
import EssentialFeediOS
import Combine

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    
    private let loader: () -> AnyPublisher<Resource, Error>
    var presenter: LoadResourcePresenter<Resource, View>?
    var cancellable: Cancellable?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
                },
                receiveValue: { [weak self] resource in
                    self?.presenter?.didFinishLoading(with: resource)
                }
            )
    }
}

extension LoadResourcePresentationAdapter: FeedViewControllerDelegate {
    
    func didRequestFeedRefresh() {
        loadResource()
    }
}
