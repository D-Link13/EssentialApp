import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url)
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTask() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertNotNil(session.requestedURL)
    }
    
    private class URLSessionSpy: URLSession {
        var requestedURL: URL?
        
        override func dataTask(with url: URL) -> URLSessionDataTask {
            requestedURL = url
            return FakeURLSessionDataTask()
        }
        
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}

}
