//: [Previous](@previous)

import SION
import Foundation

var sion:SION = [
    0:0,
    1:.Data("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"),
    2:.String("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"),
    3:.Date(Date()),
    4:.Double(0.0)
]
//sion.dictionary![2] = "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"
debugPrint(sion)
print(SION.parse(sion.description))

var s = SION([:])

//let re = try! NSRegularExpression(pattern:"([+-]?)(0(:?x[0-9a-fA-F]+|o[0-7]+|b[01]+)|[0-9]+)")
//let s = "+01234, -56789, 0xdeadbeef, 0o777, 0b010101"
//re.enumerateMatches(in: s, range:NSRange(0..<s.count)) { cr, _, _ in
//    let whole   = s[Range(cr!.range, in:s)!]
//    let sign    = s[Range(cr!.range(at:1), in:s)!]
//    let matched = s[Range(cr!.range(at:2), in:s)!]
//    print(sign, matched)
//    var int = 0
//    if matched.hasPrefix("0"){
//        let offset = matched.index(matched.startIndex, offsetBy:2)
//        switch matched[matched.index(after:matched.startIndex)] {
//        case "x": int = Int(matched[offset...], radix:16)!
//        case "o": int = Int(matched[offset...], radix:8)!
//        case "b": int = Int(matched[offset...], radix:2)!
//        default: int = Int(matched)!
//        }
//    } else {
//        int = Int(matched)!
//    }
//    if sign == "-" { int *= -1 }
//    print(int)
//    //print(a, b, c)
//}


//import SION
//
//let sion:SION = [
//    "nil":      nil,
//    "bool":     true,
//    "int":      -42,
//    "double":   42.195,
//    "string":   "漢字、カタカナ、ひらがなと\"引用符\"の入ったstring😇",
//    "array":    [nil, true, 1, "one", [1], ["one":1]],
//    "dictionary":   [
//        "nil":nil, "bool":false, "number":0, "string":"" ,"array":[], "object":[:]
//    ],
//    "url":"https://github.com/dankogai/",
//    false:true,
//    0:1
//]
////print(sion.description)
//SION.parse(sion.description)
//let t = SION.tokenize(sion.description)
//t.map{ print($0) }

//
//print(sion)
//print(sion.toJSON(space:2))
//print(SION(json:sion.json))
////print(sion.nsObject)
//
//do {
//    let data = try sion.propertyList(format: .xml)
//    print(String(data:data, encoding:.utf8)!)
//} catch {
//    print(error)
//}
//SION(jsonUrlString:"https://api.github.com")
//sion["foo"]
//
//import Foundation

//let plist = try PropertyListEncoder().encode(json)
//let data = try PropertyListSerialization.data(fromPropertyList:plist, format:.xml, options:0)
//do {
//    var data = try JSONEncoder().encode(json)
//    // let data = try PropertyListSerialization.data(fromPropertyList:json.jsonObject, format:.xml, options:0)
//    print(String(data:data, encoding:.utf8)!)
//} catch {
//    print(error)
//}

//var j = JSON([0,1,[3, 4],["five":5]]).walk {
//    if let n = $0.number { return .Number(n + 1) }
//    else { return $0 }
//}
//j


//for (k, v) in json["object"] {
//    print(k.key!, v)
//}
//for (k, v) in json["array"] {
//    print(k.index!, v)
//}
//for (k, v) in json["bool"] {
//    print(v)
//}
//JSON(["distance":42.195]) == JSON(string: "{\"distance\":42.195}")

//print(json.toString(space:2))
//print(json.prettyPrinted)


//: [Next](@next)
