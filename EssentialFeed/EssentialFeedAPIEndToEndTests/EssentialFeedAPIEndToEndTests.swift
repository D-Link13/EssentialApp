import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(feedImages)?:
            XCTAssertEqual(feedImages[0], expectedFeedImage(at: 0))
            XCTAssertEqual(feedImages[1], expectedFeedImage(at: 1))
            XCTAssertEqual(feedImages[2], expectedFeedImage(at: 2))
            XCTAssertEqual(feedImages[3], expectedFeedImage(at: 3))
            XCTAssertEqual(feedImages[4], expectedFeedImage(at: 4))
            XCTAssertEqual(feedImages[5], expectedFeedImage(at: 5))
            XCTAssertEqual(feedImages[6], expectedFeedImage(at: 6))
            XCTAssertEqual(feedImages[7], expectedFeedImage(at: 7))
        case let .failure(error)?:
            XCTFail("Expected success, got \(error) instead.")
        default:
            XCTFail("Expected success, got no result instead.")
        }
    }
    
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
        switch getFeedImageDataResult() {
        case let .success(data)?:
            XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
            
        case let .failure(error)?:
            XCTFail("Expected successful image data result, got \(error) instead")
            
        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader.Result? {
        let testServerURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5c52cdd0b8a045df091d2fff/1548930512083/feed-case-study-test-api-feed.json")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let sut = RemoteFeedLoader(client: client, url: testServerURL)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: FeedLoader.Result?
        sut.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }
    
    private func getFeedImageDataResult(file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader.Result? {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed/73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: FeedImageDataLoader.Result?
        _ = loader.loadImageData(from: testServerURL) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func expectedFeedImage(at index: Int) -> FeedImage {
        return FeedImage(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: imageURL(at: index))
    }
    
    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }

}
