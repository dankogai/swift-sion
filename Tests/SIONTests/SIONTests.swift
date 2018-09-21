import XCTest
@testable import SION

import Foundation

final class SIONTests: XCTestCase {
    let sion0:SION = [
        "null":     nil,
        "bool":     true,
        "int":      -42,
        "double":   42.1953125,
        "String":   "漢字、カタカナ、ひらがなと\"引用符\"の入ったstring😇",
        "array":    [nil, true, 1, "one", [1], ["one":1]],
        "dictionary":   [
            "null":nil, "bool":false, "number":0, "string":"" ,"array":[], "object":[:]
        ],
        "url":"https://github.com/dankogai/"
    ]
    func testBasic() {
        let str0 = sion0.description
        XCTAssertEqual(SION(string:str0), sion0)
        var sion1 = sion0
        sion1["data"] = .Data("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
        var str1 = sion1.description
        XCTAssertEqual(SION(string:str1), sion1)
        sion1["date"] = .Date(0.0)
        str1 = sion1.description
        XCTAssertEqual(SION(string:str1), sion1)
        sion1["ext"] = .Ext("1NTU")
        str1 = sion1.description
        XCTAssertEqual(SION(string:str1), sion1)
    }
    func testCodable() {
        let data1 = try! JSONEncoder().encode(sion0)
        let sion1 = try! JSONDecoder().decode(SION.self, from:data1)
        XCTAssertEqual(sion1, sion0)
        struct Point:Hashable, Codable { let (x, y):(Int, Int) }
        let data2 = try! JSONEncoder().encode(Point(x:3, y:4))
        let sion2:SION = ["x":3, "y":4]
        XCTAssertEqual(try! JSONDecoder().decode(SION.self, from:data2), sion2)
    }
    func testMsgPack() {
        let data = sion0.msgPack
        XCTAssertEqual(SION(msgPack: data), sion0)
    }
    func testHash() {
        XCTAssertEqual(SION(["zero":0,"one":1]).hashValue, SION(["one":1,"zero":0]).hashValue)
    }
    static var allTests = [
        ("testBasic",   testBasic),
        ("testCodable", testCodable),
        ("testMsgPack", testMsgPack),
        ("testHash",    testHash)
    ]
}
