import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    
    convenience init(client: HTTPClient, url: URL) {
        self.init(
            client: client,
            url: url,
            mapper: FeedItemsMapper.map)
    }
}
