import SION
import Foundation

var sion:SION = [
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
print(try sion.jsonObject() )
sion["data"] = .Data("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
sion["date"] = .Date(0.0)
debugPrint(sion)
print(sion.yaml)
print("SION.parse(sion.debugDescription) == sion //", SION.parse(sion.debugDescription) == sion)
let plistdata = try! sion.pick{ !$0.isNil }.propertyList(format: .xml)
print(String(data:plistdata, encoding:.utf8)!)
var sionString = """
[
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
    "double" : 0x1.518f5c28f5c29p+5, // Double in hexadecimal
    "int" : -0x2a, // Int in hexadecimal
    "nil" : nil,
    "string" : "漢字、カタカナ、ひらがなの入ったstring😇",
    "url" : "https://github.com/dankogai/",
    nil   : "Unlike JSON and Property Lists,",
    true  : "Yes, SION",
    1     : "does accept",
    1.0   : "non-String keys.",
    []    : "like",
    [:]   : "Map of ECMAScript."
]
"""
debugPrint(SION(string:sionString))
