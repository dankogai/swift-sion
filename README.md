# swift-sion

Swift Interchangeable Object Notation

[![Swift 4.1](https://img.shields.io/badge/swift-4.1-brightgreen.svg)](https://swift.org)
[![MIT LiCENSE](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![build status](https://secure.travis-ci.org/dankogai/swift-sion.png)](http://travis-ci.org/dankogai/swift-sion)

## Synopsis

```swift
import SION
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
```

## Description

This module is both an introduction and a reference implementation of `SION`, a data serialization format that is like [JSON] but more capable.

* As JSON is originated from a {ECMA,Java}Script literal, SION is originated from a Swift literal.
* It can serialize anything JSON can. Plus
  * support `Data`
  * support `Date`
  * non-`String` keys in `Dictionary`
  * `Int` and `Double` distinctively, not `Number`.  Therefore you can exchange 64-bit integers losslessly.
  * // comment support!
* Roughly equvalent to [MsgPack] in terms of capability.
  * [MsgPack] is a binary serialization while `SION` is a text serialization.

[JSON]: https://json.org
[MsgPack]: https://msgpack.org

| Type | SION | MsgPack | JSON | Property List | Comment |
|--------|---------------|-------|---|---|---|
| `Nil`           | ✔︎ | ✔︎ | ✔︎ | ❌ | plist: .binary only |
| `Bool`          | ✔︎ | ✔︎ | ✔︎ | ✔︎ |
| `Int`           | ✔︎ | ✔︎ | ❌ | ✔︎ | 64bit |
| `Double`        | ✔︎ | ✔︎ | ✔︎ | ✔︎ | JSON's Number |
| `String`        | ✔︎ | ✔︎ | ✔︎ | ✔︎ | utf-8 encoded |
| `Data`          | ✔︎ | ✔︎ | ❌ | ✔︎ | binary blob |
| `Date`          | ✔︎ | ✔︎ | ❌ | ✔︎ | .timeIntervalSince1970 in `Double` |
| `[Self]`        | ✔︎ | ✔︎ | ✔︎ | ✔︎ | aka Array |
| `[String:Self]` | ✔︎ | ✔︎ | ✔︎ | ✔︎ | aka Object, Map…|
| `[Self:Self]`   | ✔︎ | ✔︎ | ❌ | ❌ |non-`String` keys|

* As you see `SION` is upper-compatible with JSON and Property List.  As a matter of fact, `SION` can {,de}serialize JSON and Property List.
* **TODO**: MsgPack {,de}serializer.

### Initialization

You can build SION directly as a literal…

```swift
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
sion["date"] = .Date(0.0)
```

#### limitation

Note that the RHS of the expression below is not exactly `nil` or `true` or `-42`.  They are `SION.Nil` and `SION.Bool(-42)` and `SION.Int(-42)` respectively.  That is why `.Data` and `.Date` are added later.  Swift gets confused when you say

```swift
var sion:SION = [
    "string": "漢字、カタカナ、ひらがなの入ったstring😇",
    "data": .Data("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"),
]
```

Because it cannot tell they type of the content in. `""`.  In which case you can explicitly say

```swift
var sion:SION = [
    "string": .String("漢字、カタカナ、ひらがなの入ったstring😇"),
    "data": .Data("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"),
]

or add `"data"` later.

…or String…

```swift
let sionStr = """
[
    "array": [
        nil,
        true,
        1,      // Int
        1.0,    // Double
        "one",
        [1],
        ["one" : 1.0]
    ],
    "bool": true,
    "data": .Data("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"),
    "date": .Date(0x0p+0),
    "dictionary": [
        "array" : [],
        "bool" : false,
        "double" : 0x0p+0,
        "int" : 0,
        "nil" : nil,
        "object" : [:],
        "string" : ""
    ],
    "double": 0x1.518f5c28f5c29p+5, // double in hex
    "int": -42,                     // int in hex
    "nil": nil,
    "string": "漢字、カタカナ、ひらがなの入ったstring😇",
    "url": "https://github.com/dankogai/"
]
"""
SION(string:sionStr)
```

…or a [JSON] string or JSON-emitting URL…

```swift
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
SION(jsonUrlString:"https://api.github.com")
```

…or [Property List]…

[Property List]: https://en.wikipedia.org/wiki/Property_list

```swift
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
SION(propertyList:plistXML.data(using:.utf8)!, format:.xml)
```

### Conversion

once you have the SION object, converting to other formats is simple.

to SION string, all you need is stringify it.  .description or "\(json)" would be enough.

```swift
sion.description
"\(sion)"				// SION is CustomStringConvertible
```

If you need `JSON`, simply call `.json`.

```swift
sion.json
```

### limitation

Since JSON does not support `Date` and `Data`, `.json` converts `Date` to `Number` and `Date` to Base64-encoded `String` respectively.  `.json` also coverts all non-`String` keys to `String`.  Do not expect JSON to round trip.  It is less expressive than SION.

You can also get [YAML] via `.yaml`.

[YAML]: http://yaml.org

```swift
sion.yaml
```

And `.propertyList` for Property List.

```swift
// pick() removes Nil
String(data:try! sion.pick{ !$0.isNil }.propertyList(format: .xml), encoding:.utf8)!
```

### Manipulation

a blank SION Array is as simple as:

```swift
var sion = SION([])
```

and you can assign elements like an ordinary array

```swift
sion[0] = nil
sion[1] = true
sion[2] = 1
```

note RHS literals are NOT `nil`, `true` and `1` but `.Null`, `.Bool(true)` and `.Number(1)`.  Therefore this does NOT work

```swift
let one = "one"
sion[3] = one // error: cannot assign value of type 'String' to type 'SION'
```

In which case you do this instead.

```swift
sion[3].string = one
```

They are all getters and setters.

```swift
sion[1].bool       = true
sion[2].int        = 1
sion[3].double     = 1.0
sion[4].string     = "one"
sion[5].array      = [1]
sion[6].dictionary = ["one":1]
```

As a getter they are optional which returns `nil` when the type mismaches.

```swift
sion[1].bool    // Optional(true)
sion[1].int     // nil
```

Therefore, you can mutate like so:

```swift
sion[2].int! += 1               // now 2
sion[3].double! *= 0.5          // now 0.5
sion[4].string!.removeLast()    // now "on"
sion[5].array!.append(2)        // now [1, 2]
sion[6].dictionary!["two"] = 2  // now ["one":1,"two":2]
```

When you assign values to SION array with an out-of-bound index, it is automatically streched with unassigned elements set to `null`, just like an ECMAScript `Array`

```swift
sion[10] = false	// sion[6...9] are null
```

As you may have guessed by now, a blank SION dictionary is:

```
sion = SION([:])
```

And manipulate intuitively like so.

```swift
sion["nil"]         = nil
sion["bool"]        = false
sion["int"]         = 0
sion["double"]      = 0.0
sion["string"]      = ""
sion["array"]       = []
sion["dictionary"]  = [:]
```

#### deep traversal

`SION` is a recursive data type.  For recursive data types, you need a recursive method that traverses the data deep down.  For that purpuse, `SION` offers `.pick` and `.walk`.

`.pick` is a "`.deepFilter`" that filters recursively.  You've already seen it above.  It takes a filter function of type `(SION)->Bool`.  That function is applied to all leaf values of the tree and leaves that do not meet the predicate are pruned.

```swift
// because property list does not accept null
let sion4plist = sion.pick{ !$0.isNil }
```

`.walk` is a `deepMap` that transforms recursively.  This one is a little harder because you have to consider what to do on node and leaves separately.  To make your life easier three different versions of `.walk` are provided.  The first one just takes a leaf node.

```swift
// square all ints and leave anything else 
SION([0,[1,[2,3,[4,5,6]]], true]).walk {
    guard let n = $0.int else { return $0 }
    return SION(n * n)
}
```

The second forms just takes a node.  Instead of explaining it, let me show you how `.pick` is implemented by extending `SION` with `.select` that does exactly the same as `.pick`.

```swift
extension SION {
    func select(picker:(SION)->Bool)->SION {
        return self.walk{ node, pairs, depth in
            switch node.type {
            case .array:
                return .Array(pairs.map{ $0.1 }.filter({ picker($0) }) )
            case .dictionary:
                var o = [Key:Value]()
                pairs.filter{ picker($0.1) }.forEach{ o[$0.0.key!] = $0.1 }
                return .Dictionary(o)
            default:
                return .Error(.notIterable(node.type))
            }
        }
    }
}
```

And the last form takes both.  Unlike the previous ones this one can return other than `SION `.  Here is how `.yaml` is implemented.

```swift
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
```

### Protocol Conformance


* `SION` is `Equatable` so you can check if two JSONs are the same.

```swift
SION(string:foo) == SION(jsonUrlString:"https://example.com/whereever")
```

* `SION` is `Hashable` so you can use it as a dictionary key.

* `SION` is `ExpressibleBy*Literal`.  That's why you can initialize w/ `variable:JSON` construct show above.

* `SION` is `CustomStringConvertible` whose `.description` is always a valid SION.

* `SION` is `Codable`.

* `SION` is `Sequence`.  But when you iterate, be careful with the key.

```swift
let sa:SION = [nil, true, 1, "one", [1], ["one":1]]
// wrong!
for v in ja {
	//
}
```

```swift
// right!
for (i, v) in sa {
	// i is NOT an Integer but SION
	// To access its value, say i.int!
}
```

```swift
let sd:SION = [
    "null":nil, "bool":false, "number":0, "string":"",
    "array":[], "object":[:]
]
for (k, v) in sd {
	// k is NOT an Integer but SION.
	// To access its value, say k.string!
}

```

That is because swift demands to return same `Element` type.  If you feel this counterintuitive, you can simply use `.array` or `.dictionary`:

```swift
for v in sa.array! {
	// ...
}
```

```swift
for (k, v) in dictionary! {
	// ...
}

```

### Error handling

Once `init`ed, `SION` never fails.  That is, it never becomes `nil`.  Instead of being failable or throwing exceptions, `SION` has a special value `.Error(.ErrorType)` which propagates across the method invocations.  The following code examines the error should it happen.

```swift
if let e = sion.error {
	debugPrint(e.type)
	if let nsError = e.nsError {
		// do anything with nsError
	}
}
```

## Usage

### build

```sh
$ git clone https://github.com/dankogai/swift-sion.git
$ cd swift-sion # the following assumes your $PWD is here
$ swift build
```

### REPL

Simply

```sh
$ scripts/run-repl.sh
```

or

```sh
$ swift build && swift -I.build/debug -L.build/debug -lJSON

```

and in your repl,

```sh
  1> import SION
  2> let json:SION = ["swift":["safe","fast","expressive"]]
sion: SION.SION = Object {
  Object = 1 key/value pair {
    [0] = {
      key = "swift"
      value = Array {
        Array = 3 values {
          [0] = String {
            String = "safe"
          }
          [1] = String {
            String = "fast"
          }
          [2] = String {
            String = "expressive"
          }
        }
      }
    }
  }
}
```

### Xcode

Xcode project is deliberately excluded from the repository because it should be generated via `swift package generate-xcodeproj` . For convenience, you can

```sh
$ scripts/prep-xcode
```

And the Workspace opens up for you with Playground on top.  The playground is written as a manual.

### iOS and Swift Playground

Unfortunately Swift Package Manager does not support iOS.  To make matters worse Swift Playgrounds does not support modules.  But don't worry.  This module is so compact all you need is copy [SION.swift].

[SION.swift]: Sources/SION/SION.swift

In case of Swift Playgrounds just copy it under `Sources` folder.  If you are too lazy just run:


```sh
$ scripts/ios-prep.sh
```

and `iOS/JSON.playground` is all set.  You do not have to `import JSON` therein.

### From Your SwiftPM-Managed Projects

Add the following to the `dependencies` section:

```swift
.package(
  url: "https://github.com/dankogai/swift-sion.git", from: "0.0.0"
)
```

and the following to the `.target` argument:

```swift
.target(
  name: "YourSwiftyPackage",
  dependencies: ["SION"])
```

Now all you have to do is:

```swift
import SION
```

in your code.  Enjoy!

## Prerequisite

Swift 4.1 or better, OS X or Linux to build.

