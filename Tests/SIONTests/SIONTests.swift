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
    @Test func radixOverflow() {
        // fits Int64: .Int on 64-bit platforms (Double on 32-bit)
        #expect(SION(string:"0x7fffffffffffffff").number == Double(Int64.max))
        // beyond Int64: error instead of trapping
        #expect(SION(string:"0xffffffffffffffff").error != nil)
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

@Suite struct SIONMsgPackTests {
    func roundTrips(_ sion:SION) -> Bool {
        return SION(msgPack: sion.msgPack) == sion
    }
    @Test func scalars() {
        #expect(roundTrips(SION.Nil))
        #expect(roundTrips(.Bool(true)))
        #expect(roundTrips(.Bool(false)))
        #expect(roundTrips(.Double(42.195)))
        #expect(roundTrips(.Double(-0.5)))
        #expect(roundTrips(.Double(.infinity)))
    }
    @Test func integerWidths() {
        // hit every encoding: fixint, int8/16/32/64 boundaries on both sides
        // (Int64 literals + exactly: so this also compiles on 32-bit platforms)
        for i64:Int64 in [0, 1, -1, -32, -33, 127, 128, 255, 256, -128, -129,
                          32767, 32768, -32768, -32769, 0x7fff_ffff, 0x8000_0000,
                          -0x8000_0000, -0x8000_0001, Int64(Int.max), Int64(Int.min)] {
            guard let i = Int(exactly:i64) else { continue }    // skip out-of-width on 32-bit
            #expect(roundTrips(.Int(i)), "int \(i)")
        }
    }
    @Test func stringLengths() {
        // fixstr/str8/str16/str32 boundaries; str16/str32 payload was off by 1/3 bytes
        for n in [0, 1, 31, 32, 255, 256, 300, 65535, 65536, 70000] {
            #expect(roundTrips(.String(String(repeating:"a", count:n))), "string length \(n)")
        }
        #expect(roundTrips(.String("漢字、カタカナ、ひらがなの入ったstring😇")))
        #expect(roundTrips(.String(String(repeating:"😇", count:100))))    // 400 utf8 bytes -> str16
    }
    @Test func dataLengths() {
        // bin8/bin16/bin32 boundaries; bin16 read one byte past the payload (crash)
        for n in [0, 1, 255, 256, 300, 65535, 65536, 70000] {
            #expect(roundTrips(.Data(Data(repeating:0x55, count:n))), "data length \(n)")
        }
    }
    @Test func dates() {
        // timestamp64 for [0, 2^34); timestamp96 for pre-1970 (used to trap) and far future
        for t in [0.0, 1.5, 42.195, 1e9, -1.5, -0.25, -1e9, 34359738368.0] {
            #expect(roundTrips(.Date(Date(timeIntervalSince1970:t))), "date \(t)")
        }
    }
    @Test func dateFormatSelection() {
        // in-range dates keep the timestamp64 wire format; out-of-range use timestamp96
        #expect(SION.Date(Date(timeIntervalSince1970:0)).msgPack.first == 0xd7)
        #expect(SION.Date(Date(timeIntervalSince1970:-1.5)).msgPack.first == 0xc7)
        #expect(SION.Date(Date(timeIntervalSince1970:34359738368.0)).msgPack.first == 0xc7)
    }
    @Test func collections() {
        #expect(roundTrips(.Array([])))
        #expect(roundTrips(.Dictionary([:])))
        #expect(roundTrips(["nested":[1, [2, [3, "🕳"]]], "empty":[]]))
        #expect(roundTrips(.Array((0..<20).map{ .Int($0) })))                       // array16
        var big = [SION.Key:SION.Value]()
        for i in 0..<20 { big[.Int(i)] = .String("v\(i)") }
        #expect(roundTrips(.Dictionary(big)))                                       // map16
        #expect(roundTrips([1: "one", true: "yes", "k": nil] as SION))              // mixed keys
    }
    @Test func timestampParsing() {
        // timestamp32: [0xd6, -1, sec(u32 BE)]
        #expect(SION(msgPack:Data([0xd6, 0xff, 0, 0, 0, 42])) == .Date(Date(timeIntervalSince1970:42)))
        // timestamp96: [0xc7, 12, -1, nsec(u32 BE), sec(i64 BE)] — sec=-2 nsec=5e8 -> -1.5
        var ts96 = Data([0xc7, 12, 0xff])
        var nsec = UInt32(500_000_000).bigEndian
        var sec  = Int64(-2).bigEndian
        withUnsafeBytes(of:&nsec) { ts96.append(contentsOf:$0) }
        withUnsafeBytes(of:&sec)  { ts96.append(contentsOf:$0) }
        #expect(SION(msgPack:ts96) == .Date(Date(timeIntervalSince1970: -1.5)))
        // and the serializer emits exactly that for a pre-1970 date
        #expect(SION.Date(Date(timeIntervalSince1970: -1.5)).msgPack == ts96)
    }
    @Test func extPassthrough() {
        // non-timestamp ext chunks survive parse -> serialize unchanged (header included)
        for ext:[UInt8] in [
            [0xd4, 0x05, 0x2a],                     // fixext1
            [0xd5, 0x05, 0x2a, 0x2b],               // fixext2
            [0xc7, 2, 0x05, 0xAA, 0xBB],            // ext8
            [0xc8, 0, 2, 0x05, 0xAA, 0xBB],         // ext16
            [0xc9, 0, 0, 0, 2, 0x05, 0xAA, 0xBB],   // ext32
        ] {
            let data = Data(ext)
            let parsed = SION(msgPack:data)
            #expect(parsed == .Ext(data), "parse \(ext)")
            #expect(parsed.msgPack == data, "reserialize \(ext)")
        }
    }
    @Test func foreignEncodings() {
        // encodings our serializer never emits but the parser must accept
        #expect(SION(msgPack:Data([0xcc, 0xff])) == .Int(255))                  // uint8
        #expect(SION(msgPack:Data([0xcd, 0x01, 0x00])) == .Int(256))            // uint16
        #expect(SION(msgPack:Data([0xce, 0, 1, 0, 0])) == .Int(0x10000))        // uint32
        #expect(SION(msgPack:Data([0xcf, 0,0,0,0,0,0,0,42])) == .Int(42))       // uint64 in range
        #expect(SION(msgPack:Data([0xca, 0x3f, 0x80, 0, 0])) == .Double(1.0))   // float32
        #expect(SION(msgPack:Data([0xa0])) == .String(""))                      // empty fixstr
    }
    @Test func uint64OverflowIsError() {
        // > Int.max: error instead of silently wrapping negative
        #expect(SION(msgPack:Data([0xcf, 0xff, 0, 0, 0, 0, 0, 0, 0])).error != nil)
    }
    @Test func malformedInputsDoNotCrash() {
        let bads:[[UInt8]] = [
            [],                     // empty
            [0xd9],                 // str8 missing length
            [0xd9, 5, 0x61],        // str8 truncated payload
            [0xda, 0x01],           // str16 missing length byte
            [0xc4],                 // bin8 missing length
            [0xc5, 0xff, 0xff],     // bin16 truncated payload
            [0xcc],                 // uint8 missing value
            [0xcb, 0, 0],           // float64 truncated
            [0xdc, 0x00],           // array16 missing length byte
            [0xde, 0x00],           // map16 missing length byte
            [0x91],                 // fixarray missing element
            [0x81, 0xc1, 0x01],     // fixmap with invalid key
            [0xc7],                 // ext8 missing length
            [0xd4, 0x05],           // fixext1 truncated
            [0xa1, 0xff],           // fixstr with invalid utf8
            [0xc1],                 // never-used type byte
        ]
        for bad in bads {
            #expect(SION(msgPack:Data(bad)).error != nil, "input \(bad)")
        }
    }
    @Test func sliceInput() {
        // Data slices with non-zero start indices parse correctly
        let whole = Data([0x00, 0x00, 0x2a])
        #expect(SION(msgPack:whole[2...]) == .Int(42))
    }
}

@Suite struct SIONCodecTests {
    struct Person : Codable, Equatable {
        let name:String
        let age:Int
        let height:Double
        let birthday:Date
        let avatar:Data
        let tags:[String]
        let scores:[String:Int]
        let nickname:String?
    }
    let dan = Person(
        name:      "dankogai",
        age:       42,
        height:    172.5,
        birthday:  Date(timeIntervalSince1970: -0x1.4p27), // exact binary fraction
        avatar:    Data([0xde, 0xad, 0xbe, 0xef]),
        tags:      ["swift", "perl"],
        scores:    ["math":100, "history":50],
        nickname:  nil
    )
    @Test func roundTrip() throws {
        let sion = try SIONEncoder().encode(dan)
        #expect(try SIONDecoder().decode(Person.self, from:sion) == dan)
    }
    @Test func nativeRepresentation() throws {
        // Date and Data encode as native SION types, not doubles / base64 strings
        let sion = try SIONEncoder().encode(dan)
        #expect(sion["birthday"].date == dan.birthday)
        #expect(sion["avatar"].data == dan.avatar)
        #expect(sion["name"].string == "dankogai")
        #expect(sion["age"].int == 42)
        // nil Optional is omitted, as JSONEncoder does
        #expect(sion["nickname"].error?.type == .keyNonexistent)
    }
    @Test func roundTripViaString() throws {
        // through the textual representation, not just the tree
        let text = try SIONEncoder().encode(toString:dan, space:2)
        #expect(try SIONDecoder().decode(Person.self, from:text) == dan)
        let data = text.data(using:.utf8)!
        #expect(try SIONDecoder().decode(Person.self, from:data) == dan)
    }
    @Test func scalarsAndCollections() throws {
        #expect(try SIONDecoder().decode(Int.self,    from:SIONEncoder().encode(42)) == 42)
        #expect(try SIONDecoder().decode(String.self, from:SIONEncoder().encode("s")) == "s")
        #expect(try SIONDecoder().decode(Bool.self,   from:SIONEncoder().encode(true)) == true)
        #expect(try SIONDecoder().decode(Double.self, from:SIONEncoder().encode(42.195)) == 42.195)
        #expect(try SIONDecoder().decode([Int].self,  from:SIONEncoder().encode([1,2,3])) == [1,2,3])
        #expect(try SIONDecoder().decode([String:[Int]].self,
                from:SIONEncoder().encode(["a":[1], "b":[]])) == ["a":[1], "b":[]])
        #expect(try SIONDecoder().decode([Int?].self,
                from:SIONEncoder().encode([1, nil, 3])) == [1, nil, 3])
    }
    @Test func nonFiniteDoubles() throws {
        // JSONEncoder throws on these; SION supports them natively
        #expect(try SIONDecoder().decode(Double.self, from:SIONEncoder().encode(Double.infinity)) == .infinity)
        #expect(try SIONDecoder().decode(Double.self, from:SIONEncoder().encode(-Double.infinity)) == -.infinity)
        #expect(try SIONDecoder().decode(Double.self, from:SIONEncoder().encode(Double.nan)).isNaN)
    }
    @Test func intKeyedDictionary() throws {
        // Int-keyed dictionaries use native .Int keys, not stringified ones
        let sion = try SIONEncoder().encode([1:"one", 2:"two"])
        #expect(sion[SION.Int(1)].string == "one")
        #expect(try SIONDecoder().decode([Int:String].self, from:sion) == [1:"one", 2:"two"])
    }
    @Test func sionPassthrough() throws {
        // a SION field embeds as-is and comes back intact
        struct Doc : Codable, Equatable { let id:Int; let body:SION }
        let doc = Doc(id:1, body:["x":[1, true, nil], "d":.Date(0.0)])
        let sion = try SIONEncoder().encode(doc)
        #expect(sion["body"] == doc.body)
        #expect(try SIONDecoder().decode(Doc.self, from:sion) == doc)
    }
    @Test func enumsAndNesting() throws {
        enum Suit : String, Codable { case spades, hearts }
        struct Card : Codable, Equatable {
            let suit:String  // keep it simple for Equatable
            let rank:Int
        }
        struct Hand : Codable, Equatable { let cards:[Card]; let sorted:Bool }
        let hand = Hand(cards:[Card(suit:"spades", rank:1), Card(suit:"hearts", rank:13)], sorted:false)
        #expect(try SIONDecoder().decode(Hand.self, from:SIONEncoder().encode(hand)) == hand)
        #expect(try SIONDecoder().decode(Suit.self, from:SIONEncoder().encode(Suit.spades)) == .spades)
    }
    @Test func decodeFromHandwrittenSION() throws {
        struct Server : Codable, Equatable { let host:String; let port:Int; let tls:Bool }
        let text = """
            [
                "host" : "github.com", // comments welcome
                "port" : 443,
                "tls"  : true,
            ]
            """
        #expect(try SIONDecoder().decode(Server.self, from:text) == Server(host:"github.com", port:443, tls:true))
    }
    @Test func decodingErrors() {
        #expect(throws:DecodingError.self) {
            try SIONDecoder().decode(Int.self, from:SION.String("not a number"))
        }
        #expect(throws:DecodingError.self) {  // missing key
            try SIONDecoder().decode([String:Int].self, from:SION(string:"[1,2]"))
        }
        #expect(throws:DecodingError.self) {  // parse error propagates
            try SIONDecoder().decode(Int.self, from:"not valid sion")
        }
        #expect(throws:DecodingError.self) {  // Int overflow
            try SIONDecoder().decode(Int8.self, from:SION.Int(1000))
        }
    }
    @Test func encodingErrors() {
        #expect(throws:EncodingError.self) {  // UInt64 beyond Int.max
            try SIONEncoder().encode(["big":UInt64.max])
        }
    }
    @Test func jsonInterop() throws {
        // dates-as-numbers and data-as-base64 from JSON-sourced trees still decode
        struct Stamp : Codable, Equatable { let at:Date; let raw:Data }
        let sion = SION(json:#"{"at": 0.5, "raw": "3q2+7w=="}"#)
        let stamp = try SIONDecoder().decode(Stamp.self, from:sion)
        #expect(stamp.at == Date(timeIntervalSince1970:0.5))
        #expect(stamp.raw == Data([0xde, 0xad, 0xbe, 0xef]))
    }
}
#endif // canImport(Testing)
