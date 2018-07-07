import SION
import Foundation


let sion0:SION = [
    "null":     nil,
    "bool":     true,
    "int":      -42,
    "double":   42.1953125,
    "String":   "漢字、カタカナ、ひらがなと\"引用符\"の入ったstring😇",
    "array":    [nil, true, 1, "one", [1], ["one":1]],
    "object":   [
        "null":nil, "bool":false, "number":0, "string":"" ,"array":[], "object":[:]
    ],
    false: false,
    0: 0,
    []:[],
    [:]:[:],
    "url":"https://github.com/dankogai/",
    "keys that contain space":"remains unquoted",
    "keys that contain\nnewlines":"is quoted",
    "values that contain newlines":"is\nquoted",
]

print(sion0.toString(space: 2))
//var data = try JSONEncoder().encode(sion0)
//let json1 = try JSONDecoder().decode(SION.self, from:data)
//print(json1)
//print(sion0 == json1)
//
//struct Point:Hashable, Codable { let (x, y):(Int, Int) }
//
//data = try JSONEncoder().encode(Point(x:3, y:4))
//print( try JSONDecoder().decode(SION.self, from:data) )
//
extension SION {
    var yaml:String {
        return self.walk(depth:0, collect:{ node, pairs, depth in
            let indent = Swift.String(repeating:"  ", count:depth)
            var result = ""
            switch node.type {
            case .array:
                guard !pairs.isEmpty else { return "[]"}
                result = pairs.map{ "- " + $0.1}.map{indent + $0}.joined(separator: "\n")
            case .dictionary:
                guard !pairs.isEmpty else { return "{}"}
                result = pairs.sorted{ $0.0.description < $1.0.description }.map{
                    let k = $0.0.string ?? $0.0.description
                    let q = k.rangeOfCharacter(from: .newlines) != nil
                    return (q ? k.debugDescription : k) + ": "  + $0.1
                }.map{indent + $0}.joined(separator: "\n")
            default:
                break   // never reaches here
            }
            return "\n" + result
        },visit:{
            if $0.isNull { return  "~" }
            if let s = $0.string {
                return s.rangeOfCharacter(from: .newlines) == nil ? s : s.debugDescription
            }
            return $0.description
        })
    }
}

print(sion0.yaml)
