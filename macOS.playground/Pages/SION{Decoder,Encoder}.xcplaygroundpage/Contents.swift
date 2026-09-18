//: [Previous](@previous)
import Foundation
//: ### SION{Decoder,Encoder}
//:
//: `SIONEncoder` and `SIONDecoder` work like `JSONEncoder` and `JSONDecoder`:
//: they encode any `Encodable` type into SION and decode any `Decodable` type
//: back out of it.
struct Person : Codable, Equatable {
    let name:String
    let birthday:Date
    let avatar:Data
    let tags:[String]
}
let dan = Person(
    name:     "dankogai",
    birthday: Date(timeIntervalSince1970: 0x1p30),
    avatar:   Data([0xde, 0xad, 0xbe, 0xef]),
    tags:     ["swift", "perl"]
)
//: `SIONEncoder.encode` returns a `SION` tree…
let encoded = try SIONEncoder().encode(dan)
//: …where `Date` and `Data` are first-class citizens.
//: No `dateEncodingStrategy` or `dataEncodingStrategy` needed.
encoded["birthday"].date
encoded["avatar"].data
//: `encode(toString:space:)` gives you SION text.
let text = try SIONEncoder().encode(toString:dan, space:2)
//: `SIONDecoder.decode` accepts a `SION` tree, a `String`, or utf8 `Data`.
let decoded = try SIONDecoder().decode(Person.self, from:text)
decoded == dan
//: Hand-written SION works too — comments and trailing commas welcome.
struct Server : Codable { let host:String; let port:Int; let tls:Bool }
let server = try SIONDecoder().decode(Server.self, from:"""
    [
        "host" : "github.com", // where the code lives
        "port" : 443,
        "tls"  : true,
    ]
    """)
server.host
//: `SION` fields embed as-is, so you can mix typed and free-form data.
struct Doc : Codable { let id:Int; let body:SION }
let doc = Doc(id:1, body:["draft":true, "rev":[1, 2, 3]])
try SIONEncoder().encode(toString:doc)
//: `Int`-keyed dictionaries keep native `Int` keys — no stringification.
try SIONEncoder().encode(toString:[1:"one", 2:"two"])
//: And unlike `JSONEncoder`, non-finite doubles just work.
try SIONEncoder().encode(toString:[Double.infinity, -.infinity, .nan])
//: Trees that came from JSON still decode: `Date` accepts a number and
//: `Data` accepts a base64 string.
struct Stamp : Codable { let at:Date; let raw:Data }
try SIONDecoder().decode(Stamp.self, from:SION(json:#"{"at": 0.5, "raw": "3q2+7w=="}"#))
//: [Next](@next)
