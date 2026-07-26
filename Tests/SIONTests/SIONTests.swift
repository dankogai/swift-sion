#if canImport(Testing)
import Testing
import Foundation
@testable import SION

@Suite struct SIONBasicTests {
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

    @Test func basic() {
        let str0 = sion0.description
        #expect(SION(string:str0) == sion0)
        var sion2 = sion0
        sion2["data"] = .Data("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
        var str1 = sion2.description
        #expect(SION(string:str1) == sion2)
        sion2["date"] = .Date(0.0)
        str1 = sion2.description
        #expect(SION(string:str1) == sion2)
        sion2["ext"] = .Ext("1NTU")
        str1 = sion2.description
        #expect(SION(string:str1) == sion2)
        #expect(sion1 == sion2)
    }
    @Test func codable() throws {
        let data1 = try JSONEncoder().encode(sion0)
        let sion2 = try JSONDecoder().decode(SION.self, from:data1)
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
        #expect(sion2 == SION(string:str2))
        struct Point:Hashable, Codable { let (x, y):(Int, Int) }
        let data2 = try JSONEncoder().encode(Point(x:3, y:4))
        let sion3:SION = ["x":3, "y":4]
        #expect(try JSONDecoder().decode(SION.self, from:data2) == sion3)
    }
    @Test func msgPack() {
        #expect(SION(msgPack: sion0.msgPack) == sion0)
        #expect(SION(msgPack: sion1.msgPack) == sion1)
    }
    @Test func hash() {
        #expect(SION(["zero":0,"one":1]).hashValue == SION(["one":1,"zero":0]).hashValue)
    }
}

@Suite struct SIONParserStringTests {
    @Test func escapedQuote() {
        #expect(SION(string:#""a\"b""#) == .String("a\"b"))
    }
    @Test func trailingBackslash() {
        #expect(SION(string:#""a\\""#) == .String("a\\"))
    }
    @Test func simpleEscapes() {
        #expect(SION(string:#""a\tb\nc\rd\"e\\f\/g\bh\fi""#)
            == .String("a\tb\nc\rd\"e\\f/g\u{08}h\u{0C}i"))
    }
    @Test func nulEscape() {
        #expect(SION(string:#""\0""#) == .String("\0"))
    }
    @Test func unicodeEscape() {
        #expect(SION(string:#""é""#) == .String("é"))
    }
    @Test func surrogatePair() {
        #expect(SION(string:#""😇""#) == .String("😇"))
    }
    @Test func swiftBracedEscape() {
        // SION's serializer is String.debugDescription, which emits \u{...}
        #expect(SION(string:#""\u{1F607}""#) == .String("😇"))
    }
    @Test func rawNewlineInString() {
        #expect(SION(string:"\"a\nb\"") == .String("a\nb"))
    }
    @Test func loneHighSurrogateIsError() {
        #expect(SION(string:#""\uD83D""#).error != nil)
    }
    @Test func badEscapeIsError() {
        #expect(SION(string:#""\q""#).error != nil)
    }
    @Test func emptyString() {
        #expect(SION(string:"\"\"") == .String(""))
    }
    @Test func nonBMPTokensDoNotTruncateScan() {
        // NSRegularExpression-era bug: emoji before later tokens dropped them
        #expect(SION(string:"[\"😇😇😇\", 42]") == .Array([.String("😇😇😇"), .Int(42)]))
    }
}

@Suite struct SIONParserNumberTests {
    @Test func integers() {
        #expect(SION(string:"42")  == .Int(42))
        #expect(SION(string:"-42") == .Int(-42))
        #expect(SION(string:"+1")  == .Int(1))
        #expect(SION(string:"0")   == .Int(0))
        #expect(SION(string:"-0")  == .Int(0))
    }
    @Test func radixIntegers() {
        #expect(SION(string:"0xdeadbeef") == .Int(0xdeadbeef))
        #expect(SION(string:"0o755")      == .Int(0o755))
        #expect(SION(string:"0b1010")     == .Int(0b1010))
        #expect(SION(string:"-0xff")      == .Int(-0xff))
        #expect(SION(string:"+0x10")      == .Int(0x10))
        #expect(SION(string:"-0b11")      == .Int(-0b11))
    }
    @Test func doubles() {
        #expect(SION(string:"42.195")  == .Double(42.195))
        #expect(SION(string:"1e3")     == .Double(1e3))
        #expect(SION(string:"1.5e-3")  == .Double(1.5e-3))
        #expect(SION(string:"0.0")     == .Double(0.0))
    }
    @Test func hexDoubles() {
        #expect(SION(string:"0x1.5p+5")  == .Double(42.0))
        #expect(SION(string:"-0x1p+0")   == .Double(-1.0))
        #expect(SION(string:"0x1.518f5c28f5c29p+5") == .Double(42.195))
    }
    @Test func infinities() {
        #expect(SION(string:"inf")       == .Double(.infinity))
        #expect(SION(string:"Infinity")  == .Double(.infinity))
        #expect(SION(string:"-inf")      == .Double(-.infinity))
    }
    @Test func nan() {
        #expect(SION(string:"NaN").double?.isNaN == true)
        #expect(SION(string:"nan").double?.isNaN == true)
    }
    @Test func overflowFallsBackToDouble() {
        // does not fit in Int; parsed as Double instead of trapping
        #expect(SION(string:"99999999999999999999999999") == .Double(1e26))
    }
}

@Suite struct SIONParserTokenTests {
    @Test func comments() {
        #expect(SION(string:"[1, // comment\n 2]") == .Array([.Int(1), .Int(2)]))
        #expect(SION(string:"[1, 2] // done") == .Array([.Int(1), .Int(2)]))
    }
    @Test func commentContentsDoNotLeakTokens() {
        // "nil" inside a comment must not become an element
        #expect(SION(string:"[1, // nil is skipped\n 2]") == .Array([.Int(1), .Int(2)]))
    }
    @Test func dates() {
        #expect(SION(string:".Date(0x0p+0)") == .Date(Date(timeIntervalSince1970:0)))
        #expect(SION(string:".Date(-0x1p+0)") == .Date(Date(timeIntervalSince1970: -1)))
    }
    @Test func dataAndExt() {
        let b64 = "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"
        #expect(SION(string:".Data(\"\(b64)\")") == .Data(Data(base64Encoded:b64)!))
        #expect(SION(string:#".Ext("1NTU")"#) == .Ext(Data(base64Encoded:"1NTU")!))
        #expect(SION(string:#".Data("")"#) == .Data(Data()))
    }
    @Test func scalars() {
        #expect(SION(string:"nil")   == SION.Nil)
        #expect(SION(string:"true")  == .Bool(true))
        #expect(SION(string:"false") == .Bool(false))
    }
    @Test func collections() {
        #expect(SION(string:"[]")  == .Array([]))
        #expect(SION(string:"[:]") == .Dictionary([:]))
        #expect(SION(string:"[\"a\":[1,[2,3]],\"b\":[:]]")
            == .Dictionary([.String("a"): .Array([.Int(1), .Array([.Int(2), .Int(3)])]),
                            .String("b"): .Dictionary([:])]))
    }
    @Test func nonStringKeys() {
        #expect(SION(string:"[1:\"one\"]")    == .Dictionary([.Int(1):     .String("one")]))
        #expect(SION(string:"[true:\"yes\"]") == .Dictionary([.Bool(true): .String("yes")]))
        #expect(SION(string:"[nil:\"null\"]") == .Dictionary([SION.Nil:    .String("null")]))
    }
    @Test func invalidInputs() {
        #expect(SION(string:"").error != nil)
        #expect(SION(string:"hello").error != nil)
        #expect(SION(string:"// only a comment").error != nil)
        #expect(SION(string:":").error != nil)
        #expect(SION(string:"1 2").error != nil)     // fragments are not a collection
    }
}

@Suite struct SIONAccessorTests {
    @Test func typedAccessors() {
        #expect(SION.Bool(true).bool == true)
        #expect(SION.Int(42).int == 42)
        #expect(SION.Double(42.195).double == 42.195)
        #expect(SION.String("swift").string == "swift")
        #expect(SION.Int(42).string == nil)
        #expect(SION.String("swift").int == nil)
        #expect(SION.Int(2).number == 2.0)
        #expect(SION.Double(0.5).number == 0.5)
        #expect(SION.Nil.isNil)
    }
    @Test func subscripts() {
        var sion:SION = ["a":[10, 20], "n":nil]
        #expect(sion["a"][1] == .Int(20))
        sion["a"][0] = .Int(1)
        #expect(sion["a"][0] == .Int(1))
        sion["a"][3] = .Int(3)                       // gap-fills with nil
        #expect(sion["a"] == .Array([.Int(1), .Int(20), .Nil, .Int(3)]))
        sion["b"] = .Bool(true)
        #expect(sion["b"] == .Bool(true))
    }
    @Test func subscriptErrors() {
        let sion:SION = ["a":[10, 20]]
        #expect(sion["a"][2].error?.type  == .indexOutOfRange)
        #expect(sion["nothere"].error?.type == .keyNonexistent)
        #expect(sion["a"][0][0].error?.type == .notSubscriptable)
        // errors propagate through further subscripting
        #expect(sion["nothere"]["deeper"][0].error != nil)
    }
    @Test func sequence() {
        let arr:SION = [10, 20, 30]
        #expect(arr.count == 3)
        #expect(arr.map{ $0.value.int! } == [10, 20, 30])
        let dict:SION = ["a":1, "b":2]
        #expect(dict.count == 2)
        #expect(Set(dict.map{ $0.key.string! }) == ["a", "b"])
        #expect(SION.Int(1).count == 0)
    }
    @Test func pick() {
        let sion:SION = ["a":1, "b":nil, "c":[1, nil, 2]]
        let picked = sion.pick{ !$0.isNil }
        #expect(picked["b"].error != nil)
        #expect(picked["c"] == .Array([.Int(1), .Int(2)]))
    }
}
#endif // canImport(Testing)
