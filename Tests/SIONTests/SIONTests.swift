import XCTest
@testable import SION

import Foundation

final class SIONTests: XCTestCase {
//    let SION0:SION = [
//        "null":     nil,
//        "bool":     true,
//        "int":      -42,
//        "double":   42.1953125,
//        "String":   "漢字、カタカナ、ひらがなと\"引用符\"の入ったstring😇",
//        "array":    [nil, true, 1, "one", [1], ["one":1]],
//        "object":   [
//            "null":nil, "bool":false, "number":0, "string":"" ,"array":[], "object":[:]
//        ],
//        "url":"https://github.com/dankogai/"
//    ]
//    func testBasic() {
//        let str = SION0.description
//        XCTAssertEqual(SION(string:str), SION0)
//    }
//    func testCodable() {
//        let data1 = try! SIONEncoder().encode(SION0)
//        let SION1 = try! SIONDecoder().decode(SION.self, from:data1)
//        XCTAssertEqual(SION1, SION0)
//        
//        struct Point:Hashable, Codable { let (x, y):(Int, Int) }
//        let data2 = try! SIONEncoder().encode(Point(x:3, y:4))
//        let SION2:SION = ["x":3, "y":4]
//        XCTAssertEqual(try! SIONDecoder().decode(SION.self, from:data2), SION2)
//    }
//    static var allTests = [
//        ("testBasic",   testBasic),
//        ("testCodable", testCodable),
//    ]
}
