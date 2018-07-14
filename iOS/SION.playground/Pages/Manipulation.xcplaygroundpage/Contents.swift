//: [Previous](@previous)
//: ### Manipulation
//import SION

//: a blank JSON Array is as simple as:
var sion = SION([])
//: and you can assign elements like an ordinary array
sion[0] = nil
sion[1] = true
sion[2] = 1
sion[3] = 1.0
//: note RHS literals are NOT `nil`, `true` and `1` but `.Null`, `.Bool(true)`, `.Int(1)` and `.Double(1.0)`.
//: so this does NOT work
let one = "one"
//sion[4] = one // error: cannot assign value of type 'String' to type 'JSON'
//: in which case you can do the following:
sion[4].string = one
//: they are all getters and setters.
sion[1].bool       = true
sion[2].int        = 1
sion[3].double     = 1.0
sion[4].string     = "one"
sion[5].array      = [1]
sion[6].dictionary = ["one":1]
//: As a getter they are optional which returns `nil` when the type mismaches.
sion[1].bool    // Optional(true)
sion[1].int     // nil
//: Therefore, you can mutate like so:
sion[2].int! += 1               // now 2
sion[3].double! *= 0.5          // now 0.5
sion[4].string!.removeLast()    // now "on"
sion[5].array!.append(2)        // now [1, 2]
sion[6].dictionary!["two"] = 2  // now ["one":1,"two":2]
//: when you assign values to JSON array with an out-of-bound index, it is automatically streched with unassigned elements set to `null`, just like an ECMAScript `Array`
sion[10] = false
sion[9]
sion
//: As you may have guessed by now, a blank JSON object(dictionary) is:
sion = SION([:])
//: and manipulate intuitively
sion["nil"]        = nil
sion["bool"]        = false
sion["int"]         = 0
sion["double"]      = 0.0
sion["string"]      = ""
sion["array"]       = []
sion["dictionary"]  = [:]

//: #### deep traversal
//: `JSON` is a recursive data type.  For recursive data types, you need a recursive method that traverses the data deep down.  For that purpuse, `JSON` offers `.pick` and `.walk`.

//: `.pick` is a "`.deepFilter`" that filters recursively.  You've already seen it above.  It takes a filter function of type `(JSON)->Bool`.  That function is applied to all leaf values of the tree and leaves that do not meet the predicate are pruned.

// because property list does not accept nil
let sion4plist = sion.pick{ !$0.isNil }


//: `.walk` is a `deepMap` that transforms recursively.  This one is a little harder because you have to consider what to do on node and leaves separately.  To make your life easier three different forms of `.walk` are provided.  The first one just takes a leaf.

SION([0,[1,[2,3,[4,5,6]]], true]).walk {
    guard let n = $0.int else { return $0 }
    return SION(n * n)
}

//: The second forms just takes a node.  Instead of explaining it, let me show you how `.pick` is implemented by extending `JSON` with `.select` that does exactly the same as `.pick`.

extension SION {
    func select(picker:(SION)->Bool)->SION {
        return self.walk{ node, pairs, depth in
            switch node.type {
            case .array:
                return .Array(pairs.map{ $0.1 }.filter{ picker($0) } )
            case .dictionary:
                var o = [Key:Value]()
                pairs.filter{ picker($0.1) }.forEach{ o[$0.0] = $0.1 }
                return .Dictionary(o)
            default:
                return .Error(.notIterable(node.type))
            }
        }
    }
}

//: And the last form takes both.  Unlike the previous ones this one can return other than `JSON`.  Here is a quick and dirty `.yaml` that emits a YAML.

extension SION {
    public var yaml:String {
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
            if $0.isNil { return  "~" }
            if let s = $0.string {
                return s.rangeOfCharacter(from: .newlines) == nil ? s : s.debugDescription
            }
            return $0.description
        })
    }
}


//: and the second one just takes a node.
//:

//: [Next](@next)
