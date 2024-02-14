import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}
    
    public func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(_ completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
}
