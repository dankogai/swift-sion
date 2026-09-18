//: [Previous](@previous)
import Foundation
//: ### Initialization
//:
//: You can build SION directly as a literal…
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
sion["data"] = .Data("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
sion["date"] = .Date(0x0p+0)
sion["ext"]  = .Ext("1NTU")

//: …or String…

let sionStr = """
[   // unlike JSON comments are supported. // up to newline
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
"""
SION(string:sionStr) == sion

//: …or JSON String…

let jsonStr = """
{
    "array" : [
    null,
    true,
    1,
    1.0,
    "one",
    [
      1
    ],
    {
      "one" : 1.0
    }
    ],
    "bool" : true,
    "data" : "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7",
    "date" : 0.0,
    "dictionary" : {
        "array" : [],
        "bool" : false,
        "double" : 0.0,
        "int" : 0,
        "nil" : null,
        "object" : {},
        "string" : ""
    },
    "double" : 42.195,
    "int" : -42,
    "nil" : null,
    "string" : "漢字、カタカナ、ひらがなの入ったstring😇",
    "url" : "https://github.com/dankogai/"
}
"""
SION(json:jsonStr)

//: …or Property List…
let plistXML = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>array</key>
  <array>
    <true/>
    <integer>1</integer>
    <real>1</real>
    <string>one</string>
    <array>
      <integer>1</integer>
    </array>
    <dict>
      <key>one</key>
      <real>1</real>
    </dict>
  </array>
  <key>bool</key>
  <true/>
  <key>data</key>
  <data>
    R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7
  </data>
  <key>date</key>
  <date>1970-01-01T00:00:00Z</date>
  <key>dictionary</key>
  <dict>
    <key>array</key>
    <array/>
    <key>bool</key>
    <false/>
    <key>double</key>
    <real>0.0</real>
    <key>int</key>
    <integer>0</integer>
    <key>object</key>
    <dict/>
    <key>string</key>
    <string></string>
  </dict>
  <key>double</key>
  <real>42.195</real>
  <key>int</key>
  <integer>-42</integer>
  <key>string</key>
  <string>漢字、カタカナ、ひらがなの入ったstring😇</string>
  <key>url</key>
  <string>https://github.com/dankogai/</string>
</dict>
</plist>
"""
debugPrint(SION(propertyList:plistXML.data(using:.utf8)!, format:.xml))
//print(String(data:try! sion.pick{ !$0.isNull }.propertyList(format: .xml), encoding:.utf8)!)

//print(sion.toJSON(space:2))

//: …or a content of the URL…
//JSON(urlString:"https://api.github.com")
//
////: …or by decoding Codable data…
//import Foundation
//struct Point:Hashable, Codable { let (x, y):(Int, Int) }
//var data = try JSONEncoder().encode(Point(x:3, y:4))
//String(data:data, encoding:.utf8)
//do {
//  try JSONDecoder().decode(SION.self, from:data)
//} catch {
//  print(error)
//}
import Foundation
var msgData = Data(
    [0x82,0xa7,0x63,0x6f,0x6d,0x70,0x61,0x63,0x74,0xc3,0xa6,0x73,0x63,0x68,0x65,0x6d,0x61,0x00]
)
print(SION(msgPack:msgData))
//: [Next](@next)
