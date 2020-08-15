//: [Previous](@previous)

import SION
import Foundation

SION.parse(msgPack:Data([0x01]))
SION.parse(msgPack:Data([0xe0]))
SION.parse(msgPack:Data([0xc0])).msgPack == Data([0xc0])
var sion = SION([:])
sion["ext"] = .Ext("1NTU")
sion["date"] = .Date(Date())
var msg = sion.msgPack
debugPrint(msg.map{String(format:"%02x",$0)})
//debugPrint(msg.count)
debugPrint(SION(msgPack: msg))

//SION(msgPack:Data([0xc1]))
//Date(timeIntervalSince1970:0x1.6d276636baf32p+30)

SION.parse(string:"1").number
//: [Next](@next)
