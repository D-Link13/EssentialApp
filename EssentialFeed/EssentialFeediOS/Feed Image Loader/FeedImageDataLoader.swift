import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol ImageLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
