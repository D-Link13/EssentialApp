import Foundation

public final class FeedImageDataMapper {
    
    private enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> Data {
        let isValidResponse = response.isOK && !data.isEmpty
        guard isValidResponse else { throw Error.invalidData }
        return data
    }
}

