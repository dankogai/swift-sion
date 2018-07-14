//: [Previous](@previous)

import SION
import Foundation

SION.parse(msgPack:Data([0x01]))
SION.parse(msgPack:Data([0xe0]))
SION.parse(msgPack:Data([0xc0])).msgPack == Data([0xc0])
var sion = SION([
    "array" : [
        nil,
        true,
        1,    // Int in decimal
        1.0,  // Double in decimal
        "one",
        [1],
        ["one" : 1.0]
    ],
    "bool" : true,
    "dictionary" : [
        "array" : [],
        "bool" : false,
        "double" : 0.0,
        "int" : 0,
        "nil" : nil,
        "object" : [:],
        "string" : ""
    ],
    "double" : 42.195,
    "int" : -42,
    "nil" : nil,
    "string" : "漢字、カタカナ、ひらがなの入ったstring😇",
    "url" : "https://github.com/dankogai/"
    ])
sion["ext"] = .Ext("1NTU")
sion["date"] = .Date(Date())
var msg = sion.msgPack
debugPrint(msg.map{String(format:"%02x",$0)})
//debugPrint(msg.count)
debugPrint(SION(msgPack: msg))
//Date(timeIntervalSince1970:0x1.6d276636baf32p+30)

//: [Next](@next)
