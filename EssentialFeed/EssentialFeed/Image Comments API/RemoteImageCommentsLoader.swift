import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(client: HTTPClient, url: URL) {
        self.init(
            client: client,
            url: url,
            mapper: ImageCommentsMapper.map)
    }
}
