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
    "url":"https://github.com/dankogai/",
    false:true,
    0:1,
    []:[],
    [:]:[:]
]
sion["data"] = .Data("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
sion["date"] = .Date(0.0)
debugPrint(sion)
print(sion.yaml)
print(SION.parse(sion.debugDescription) == sion)
