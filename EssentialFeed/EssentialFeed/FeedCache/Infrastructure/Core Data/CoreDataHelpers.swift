import CoreData

extension NSPersistentContainer {
    
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStore(Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStore($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

