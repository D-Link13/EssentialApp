import XCTest
import EssentialFeed

final class ImageCommentsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 150, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOnInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)
        
        XCTAssertThrowsError(
            try ImageCommentsMapper.map(invalidJSON, HTTPURLResponse(statusCode: 200))
        )
    }

    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSON() throws {
        let emptyJSON = makeItemsJSON([])
        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(emptyJSON, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
        
        let item1 = makeImageComment(
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1645653600), "2022-02-23T22:00:00Z"),
            username: "a username")
        let item2 = makeImageComment(
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1392890400), "2014-02-20T10:00:00Z"),
            username: "another username")
        let json = makeItemsJSON([item1.json, item2.json])
        
        let samples = [200, 201, 250, 280, 299]
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [item1.model, item2.model])
        }
    }
    
    // MARK: - Helpers
    
    private func makeImageComment(message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let model = ImageComment(id: UUID(), message: message, createdAt: createdAt.date, username: username)
        let json: [String: Any] = [
            "id": model.id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
        return (model, json)
    }
}
