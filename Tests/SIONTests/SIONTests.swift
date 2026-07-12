import XCTest
@testable import SION

import Foundation

final class SIONTests: XCTestCase {
    let sion0:SION = [
        "nil":      nil,
        "bool":     true,
        "int":      -42,
        "double":   42.195,
        "string":   "漢字、カタカナ、ひらがなの入ったstring😇",
        "array":    [nil, true, 1, 1.0, "one", [1], ["one":1.0]],
        "dictionary":   [
            "nil":nil, "bool":false, "int":0, "double":0.0, "string":"","array":[], "object":[:]
        ],
        "url":"https://github.com/dankogai/"
    ]
    let sion1 = SION(string:"""
        [
          "array" : [
            nil,
            true,
            1,
            0x1p+0,
            "one",
            [
              1
            ],
            [
              "one" : 0x1p+0
            ]
          ],
          "bool" : true,
          "data" : .Data("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"),
          "date" : .Date(0x0p+0),
          "dictionary" : [
            "array" : [],
            "bool" : false,
            "double" : 0x0p+0,
            "int" : 0,
            "nil" : nil,
            "object" : [:],
            "string" : ""
          ],
          "double" : 0x1.518f5c28f5c29p+5,
          "ext" : .Ext("1NTU"),
          "int" : -42,
          "nil" : nil,
          "string" : "漢字、カタカナ、ひらがなの入ったstring😇",
          "url" : "https://github.com/dankogai/"
        ]
        """)

    func testBasic() {
        let str0 = sion0.description
        XCTAssertEqual(SION(string:str0), sion0)
        var sion2 = sion0
        sion2["data"] = .Data("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
        var str1 = sion2.description
        XCTAssertEqual(SION(string:str1), sion2)
        sion2["date"] = .Date(0.0)
        str1 = sion2.description
        XCTAssertEqual(SION(string:str1), sion2)
        sion2["ext"] = .Ext("1NTU")
        str1 = sion2.description
        XCTAssertEqual(SION(string:str1), sion2)
        XCTAssertEqual(sion1, sion2)
    }
    func testCodable() {
        let data1 = try! JSONEncoder().encode(sion0)
        let sion2 = try! JSONDecoder().decode(SION.self, from:data1)
        // we need another test string because JSONEncoder converts 0.0 and 1.0 to 0 and 1 :(
        let str2 = """
            [
              "array" : [
                nil,
                true,
                1,
                1,
                "one",
                [
                  1
                ],
                [
                  "one" : 1
                ]
              ],
              "bool" : true,
              "dictionary" : [
                "array" : [],
                "bool" : false,
                "double" : 0,
                "int" : 0,
                "nil" : nil,
                "object" : [:],
                "string" : ""
              ],
              "double" : 0x1.518f5c28f5c29p+5,
              "int" : -42,
              "nil" : nil,
              "string" : "漢字、カタカナ、ひらがなの入ったstring😇",
              "url" : "https://github.com/dankogai/"
            ]
            """
        XCTAssertEqual(sion2, SION(string:str2))
        struct Point:Hashable, Codable { let (x, y):(Int, Int) }
        let data2 = try! JSONEncoder().encode(Point(x:3, y:4))
        let sion3:SION = ["x":3, "y":4]
        XCTAssertEqual(try! JSONDecoder().decode(SION.self, from:data2), sion3)
    }
    func testMsgPack() {
        XCTAssertEqual(SION(msgPack: sion0.msgPack), sion0)
        XCTAssertEqual(SION(msgPack: sion1.msgPack), sion1)
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
