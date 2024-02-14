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

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {

    @NSManaged var timestamp: Date?
    @NSManaged var feed: NSOrderedSet?
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
    
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
