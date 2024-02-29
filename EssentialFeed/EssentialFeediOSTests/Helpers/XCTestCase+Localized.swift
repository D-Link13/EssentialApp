import XCTest

extension XCTestCase {
    
    func localized(_ key: String, forBundle bundle: Bundle, inTable table: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key)", file: file, line: line)
        }
        return value
    }
}
