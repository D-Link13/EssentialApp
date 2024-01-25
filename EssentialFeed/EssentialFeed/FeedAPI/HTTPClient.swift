import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}
