//: [Previous](@previous)
import Foundation
//: ### Conversion
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
//: once you have the `SION` object, converting to other formats is simple.
//:
//: to JSON string, all you need is stringify it.  `.description` or `"\(json)"`
//: would be enough.

sion.description
"\(sion)"

//: if you need JSON, simply call `.json`

sion.json

//: You can also get [YAML] via `.yaml`.

sion.yaml

//: And `.propertyList` for Property List.

// pick() removes Nil

String(data:try! sion.pick{ !$0.isNil }.propertyList(format: .xml), encoding:.utf8)!

//: [Next](@next)
