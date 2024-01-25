import Foundation

public final class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Error) -> Void) {
        client.get(from: url) { error, response in
            if error != nil {
                completion(.connectivity)
            } else {
                completion(.invalidData)
            }
        }
    }
}
