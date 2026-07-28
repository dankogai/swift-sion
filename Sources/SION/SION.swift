//
//  SION.swift
//  SION
//
//  Created by Dan Kogai on 7/15/14.
//  Copyright (c) 2018-2026 Dan Kogai. All rights reserved.
//

import Foundation

public indirect enum SION:Equatable {
    public typealias Key    = SION
    public typealias Value  = SION
    public typealias Index  = Int
    case Error(SIONError)
    case Nil
    case Bool(Bool)
    case Int(Int)
    case Double(Double)
    case Date(Date)
    case String(String)
    case Data(Data)
    case Ext(Data)
    case Array([Value])
    case Dictionary([Key:Value])
}
extension SION : Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .Error(let m):     fatalError("\(m)")
        case .Nil:              NSNull().hash(into:&hasher)
        case .Bool(let v):      v.hash(into:&hasher)
        case .Int(let v):       v.hash(into:&hasher)
        case .Double(let v):    v.hash(into:&hasher)
        case .Date(let v):      v.hash(into:&hasher)
        case .String(let v):    v.hash(into:&hasher)
        case .Data(let v):      v.hash(into:&hasher)
        case .Ext(let v):       v.hash(into:&hasher)
        case .Array(let a):     for e in a {
            e.hash(into:&hasher)
            }
        case .Dictionary(let d):for k in d.keys.sorted(by:{$0.hashValue < $1.hashValue}) {
            k.hash(into:&hasher)
            d[k]!.hash(into:&hasher)
            }
        }
    }
}
extension SION : CustomStringConvertible, CustomDebugStringConvertible {
    public func toString(
        depth d:Int, separator s:String, terminator t:String, sortedKey:Bool=false
    )->String {
        let indent = Swift.String(repeating:s, count:d)
        let gap = s == "" ? "" : " "
        let tail = d == 0 ? t : ""
        switch self {
        case .Error(let m):     return ".Error(\"\(m)\")"
        case .Nil:              return "nil"
        case .Bool(let v):      return v.description
        case .Int(let v):       return v.description
        case .Double(let v):    return Swift.String(format:"%a", v)
        case .Date(let v):      return ".Date(" + Swift.String(format:"%a", v.timeIntervalSince1970) + ")"
        case .String(let v):    return v.debugDescription
        case .Data(let v):      return ".Data(\"" + v.base64EncodedString() + "\")"
        case .Ext(let v):       return ".Ext(\"" + v.base64EncodedString() + "\")"
        case .Array(let a):
            guard !a.isEmpty else { return "[]" }
            return "[" + t
                + a.map{ $0.toString(depth:d+1, separator:s, terminator:t, sortedKey:sortedKey) }
                    .map{ indent + s + $0 }.joined(separator:"," + t) + t
                + indent + "]" + tail
        case .Dictionary(let o):
            guard !o.isEmpty else { return "[:]" }
            let a = sortedKey ? o.map{ $0 }.sorted{ $0.0.description < $1.0.description }
                : o.map{ $0 }
            let kvs = a.map {
                $0.toString(depth:d+1, separator:s, terminator:t, sortedKey:sortedKey)
                + gap + ":" + gap
                + $1.toString(depth:d+1, separator:s, terminator:t, sortedKey:sortedKey)
                }.map{ indent + s + $0 }
            return "[" + t
                + kvs.joined(separator:"," + t) + t + indent
                + "]" + tail
        }
    }
    public func toString(space:Int=0)->String {
        return space == 0
            ? toString(depth:0, separator:"", terminator:"")
            : toString(depth:0, separator:Swift.String(repeating:" ", count:space), terminator:"\n", sortedKey:true)
    }
    public var description:String {
        return self.toString()
    }
    public var debugDescription:String {
        return self.toString(space:2)
    }
    public func toJSON(depth d:Int, separator s:String, terminator t:String, sortedKey:Bool=false)->String {
        let i = Swift.String(repeating:s, count:d)
        let g = s == "" ? "" : " "
        switch self {
        case .Error(let m):     return ".Error(\"\(m)\")"
        case .Nil:              return "null"
        case .Bool(let v):      return v.description
        case .Int(let v):       return v.description
        case .Double(let v):    return v.description
        case .Date(let v):      return v.timeIntervalSince1970.description
        case .String(let v):    return v.debugDescription
        case .Data(let v):      return "\"" + v.base64EncodedString() + "\""
        case .Ext(let v):       return "\"" + v.base64EncodedString() + "\""
        case .Array(let a):
            guard !a.isEmpty else { return "[]" }
            return "[" + t
                + a.map{ $0.toJSON(depth:d+1, separator:s, terminator:t, sortedKey:sortedKey) }
                    .map{ i + s + $0 }.joined(separator:","+t) + t
                + i + "]" + (d == 0 ? t : "")
        case .Dictionary(let o):
            guard !o.isEmpty else { return "{}" }
            let a = sortedKey ? o.map{ $0 }.sorted{ $0.0.description < $1.0.description } : o.map{ $0 }
            let e = d == 0 ? t : ""
            return "{" + t
                + a.map {
                    let k = $0.string ?? $0.toJSON(depth:d+1, separator:s, terminator:t, sortedKey:sortedKey)
                    return k.debugDescription
                        + g + ":" + g
                        + $1.toJSON(depth:d+1, separator:s, terminator:t, sortedKey:sortedKey)
                    }.map{ i + s + $0 }.joined(separator:"," + t) + t
                + i + "}" + e
        }
    }
    public func toJSON(space:Int=0)->String {
        return space == 0
            ? toJSON(depth:0, separator:"", terminator:"")
            : toJSON(depth:0, separator:Swift.String(repeating:" ", count:space), terminator:"\n", sortedKey:true)
    }
    public var json:String {
        return self.toJSON()
    }
}
extension Foundation.Data:Swift.ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value:StringLiteralType) {
        self.init(base64Encoded:value, options:[.ignoreUnknownCharacters])!
    }
}
extension Foundation.Date:Swift.ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    public init(floatLiteral value:FloatLiteralType) {
        self.init(timeIntervalSince1970: value)
    }
}
// Inits
extension SION :
    ExpressibleByNilLiteral, ExpressibleByBooleanLiteral,
    ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral,
    ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    public init()                               { self = .Nil }
    public init(nilLiteral: ())                 { self = .Nil }
    public typealias BooleanLiteralType = Bool
    public init(_ value:Bool)                   { self = .Bool(value) }
    public init(booleanLiteral value: Bool)     { self = .Bool(value) }
    public typealias FloatLiteralType = Double
    public init(_ value:Double)                 { self = .Double(value) }
    public init(floatLiteral value:Double)      { self = .Double(value) }
    public typealias IntegerLiteralType = Int
    public init(_ value:Int)                    { self = .Int(value) }
    public init(integerLiteral value: Int)      { self = .Int(value) }
    public typealias StringLiteralType = String
    public init(_ value:String)                 { self = .String(value) }
    public init(stringLiteral value:String)     { self = .String(value) }
    public typealias ArrayLiteralElement = Value
    public init(_ value:[Value])                { self = .Array(value)  }
    public init(arrayLiteral value:Self...)     { self = .Array(value)  }
    public init(_ value:[Key:Value])            { self = .Dictionary(value) }
    public init(dictionaryLiteral value:(Key,Value)...) {
        var o = [Key:Value]()
        value.forEach { o[$0.0] = $0.1 }
        self = .Dictionary(o)
    }
}
extension SION {
    /// NSObject -> SION
    public init(nsObject:Any?) {
        switch nsObject {
        case is NSNull:   self = .Nil
        // Be careful! SIONSerialization renders bool as NSNumber use .objcType to tell the difference
        case let a as NSNumber:
            switch Swift.String(cString:a.objCType) {
            case "c", "C":  self = .Bool(a as! Bool)
            case "s","S","l","L","q","Q":   self = .Int(a as! Int)
            default:        self = .Double(a as! Double)
            }
        case let a as String:   self = .String(a)
        case let a as Date:     self = .Date(a)
        case let a as Data:     self = .Data(a)
        case let a as [Any?]:   self = .Array(a.map{ SION(nsObject:$0) })
        case let a as [Key:Any?]:
            var o = [Key:Value]()
            a.forEach{ o[$0.0] = SION(nsObject:$0.1) }
            self = .Dictionary(o)
        case let a as [Swift.String:Any?]:
            var o = [Key:Value]()
            a.forEach{ o[.String($0.0)] = $0.1 == nil ? SION() : SION(nsObject:$0.1) }
            self = .Dictionary(o)
        default:
            self = .Error(.notASIONType)
        }
    }
    /// SION -> NSObject
    public var nsObject:Any {
        switch self {
        case .Nil:              return NSNull()
        case .Bool(let v):      return v
        case .Int(let v):       return v
        case .Double(let v):    return v
        case .Date(let v):      return v
        case .String(let v):    return v
        case .Data(let v):      return v
        case .Ext(let v):       return v
        case .Array(let a):     return a.map{ $0.nsObject }
        case .Dictionary(let o):
            let k = o.keys.map   { $0.nsObject as! NSCopying }
            let v = o.values.map { $0.nsObject }
            #if canImport(Darwin)
            return NSDictionary(objects: v, forKeys: k)
            #else
            return NSDictionary(objects: v, forKeys: k as! [NSObject]) // as! need in Linux
            #endif
        default:
            fatalError()
        }
    }
    public init(jsonData:Data) {
        do {
            let jo = try JSONSerialization.jsonObject(with:jsonData, options:[.allowFragments])
            self.init(nsObject:jo)
        } catch {
            self = .Error(.nsError(error as NSError))
        }
    }
    public init(json:String) {
        self.init(jsonData:json.data(using:.utf8)!)
    }
    public init(jsonString:String) {
        self.init(jsonData:jsonString.data(using:.utf8)!)
    }
    public init(jsonUrlString:String) {
        if let url = URL(string: jsonUrlString) {
            self = SION(jsonURL:url)
        } else {
            self = .Nil
        }
    }
    public init(jsonURL:URL) {
        do {
            let str = try Swift.String(contentsOf: jsonURL)
            self = SION(json:str)
        } catch {
            self = .Error(.nsError(error as NSError))
        }
    }
    public func jsonObject() throws -> Any {
#if swift(<6.0)
        let options:JSONSerialization.ReadingOptions = [.allowFragments]
#else
        let options:JSONSerialization.ReadingOptions = [.allowFragments,.json5Allowed]
#endif
        return try JSONSerialization.jsonObject(with:self.json.data(using: .utf8)!, options:options)
    }
    public init(propertyList data:Data, format:PropertyListSerialization.PropertyListFormat = .binary) {
        var fmt = format
        do {
            let nsObject = try PropertyListSerialization.propertyList(from:data, format:&fmt)
            self.init(nsObject:nsObject)
        } catch {
            self = .Error(.error("\(error)"))
        }
    }
    public func propertyList(format:PropertyListSerialization.PropertyListFormat = .binary) throws -> Data {
        return try PropertyListSerialization.data(fromPropertyList: self.nsObject, format: format, options:0)
    }
}
extension SION {
    public enum ContentType { // nil is not a valid case identifier so null
        case error, null, bool, int, double, date, string, data, ext, array, dictionary
    }
    public var type:ContentType {
        switch self {
        case .Error(_):         return .error
        case .Nil:              return .null
        case .Bool(_):          return .bool
        case .Int(_):           return .int
        case .Double(_):        return .double
        case .Date(_):          return .date
        case .Ext(_):           return .ext
        case .String(_):        return .string
        case .Data(_):          return .data
        case .Array(_):         return .array
        case .Dictionary(_):    return .dictionary
        }
    }
    public var isNil:Bool           { return self == .Nil }
    public var error:SIONError?     { switch self { case .Error(let v): return v default: return nil } }
    public var bool:Bool? {
        get { switch self { case .Bool(let v):  return v default: return nil } }
        set { self = .Bool(newValue!) }
    }
    public var int:Int? {
        get { switch self { case .Int(let v):return v default: return nil } }
        set { self = .Int(newValue!) }
    }
    public var double:Double? {
        get { switch self { case .Double(let v):return v default: return nil } }
        set { self = .Double(newValue!) }
    }
    /// read only
    public var number:Double? {
       get {
         switch self {
           case .Double(let v):
             return v
           case .Int(let v):
             return Swift.Double(v)
           default:
             return nil
           }
       }
    }
    public var date:Date? {
        get { switch self { case .Date(let v):return v default: return nil } }
        set { self = .Date(newValue!) }
    }
    public var string:String? {
        get { switch self { case .String(let v):return v default: return nil } }
        set { self = .String(newValue!) }
    }
    public var data:Data? {
        get { switch self { case .Data(let v):return v default: return nil } }
        set { self = .Data(newValue!) }
    }
    public var ext:Data? {
        get { switch self { case .Ext(let v):return v default: return nil } }
        set { self = .Ext(newValue!) }
    }
    public var array:[Value]? {
        get { switch self { case .Array(let v): return v default: return nil } }
        set { self = .Array(newValue!) }
    }
    public var dictionary:[Key:Value]?  {
        get { switch self { case .Dictionary(let v):return v default: return nil } }
        set { self = .Dictionary(newValue!) }
    }
    public var isIterable:Bool {
        return type == .array || type == .dictionary
    }
}
extension SION {
    public subscript(_ idx:Index)->Self {
        get {
            switch self {
            case .Error(_):
                return self
            case .Array(let a):
                guard idx < a.count else { return .Error(.indexOutOfRange(idx)) }
                return a[idx]
            default:
                return .Error(.notSubscriptable(self.type))
            }
        }
        set {
            switch self {
            case .Array(var a):
                if idx < a.count {
                    a[idx] = newValue
                } else {
                    for _ in a.count ..< idx {
                        a.append(.Nil)
                    }
                    a.append(newValue)
                }
                self = .Array(a)
            default:
                fatalError("\"\(self)\" is not an array")
            }
        }
    }
    public subscript(_ key:Key)->Self {
        get {
            switch self {
            case .Error(_):
                return self
            case .Dictionary(let o):
                return o[key] ?? .Error(.keyNonexistent(key))
            default:
                return .Error(.notSubscriptable(self.type))
            }
        }
        set {
            switch self {
            case .Dictionary(var o):
                o[key] = newValue
                self = .Dictionary(o)
            default:
                fatalError("\"\(self)\" is not a dictionary")
            }
        }
    }
}
extension SION : Sequence {
    public typealias Element = (key:Self,value:Self)  // for Sequence conformance
    public typealias Iterator = AnyIterator<Element>
    public var count:Int {
        switch self {
        case .Array(let v):
            return v.count
        case .Dictionary(let v):
            return v.count
        default:
            return 0
        }
    }
    public func makeIterator() -> AnyIterator<Self.Element> {
        switch self {
        case .Array(let a):
            var i = -1
            return AnyIterator {
                i += 1
                return a.count <= i ? nil : (.Int(i), a[i])
            }
        case .Dictionary(let d):
            let kv = d.map{ $0 }
            var i = -1
            return AnyIterator {
                i += 1
                return kv.count <= i ? nil : (kv[i].0, kv[i].1)
            }
        default:
            return AnyIterator { nil }
        }
    }
    public func walk<R>(depth:Int=0, collect:(SION, [(Key, R)], Int)->R, visit:(SION)->R)->R {
        return collect(self, self.map {
            let value = $0.1.isIterable ? $0.1.walk(depth:depth+1, collect:collect, visit:visit)
            : visit($0.1)
            return ($0.0, value)
        }, depth)
    }
    public func walk(depth:Int=0, visit:(Self)->Self)->Self {
        return self.walk(depth:depth, collect:{ node,pairs,depth in
            switch node.type {
            case .array:
                return .Array(pairs.map{ $0.1 })
            case .dictionary:
                var o = [Key:Value]()
                pairs.forEach{ o[$0.0] = $0.1 }
                return .Dictionary(o)
            default:
                return .Error(.notIterable(node.type))
            }
        }, visit:visit)
    }
    public func walk(depth:Int=0, collect:(Self, [Element], Int)->Self)->Self {
        return self.walk(depth:depth, collect:collect, visit:{ $0 })
    }
    public func pick(picker:(SION)->Bool)->Self {
        return self.walk{ node, pairs, depth in
            switch node.type {
            case .array:
                return .Array(pairs.map{ $0.1 }.filter({ picker($0) }) )
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
extension SION {
    /// tokenizer regex — compiled once per process rather than on every parse call
    private static let reToken:Regex<AnyRegexOutput> = {
        let s_null = "nil"
        let s_bool = "true|false"
        let s_double = """
            ([+-]?)(
                0x[0-9a-fA-F]+(?:\\.[0-9a-fA-F]+)?(?:[pP][+-]?[0-9]+)
            |   (?:[1-9][0-9]*)(?:\\.[0-9]+)?(?:[eE][+-]?[0-9]+)?
            |   0(?:\\.0+|(?:\\.0+)?(?:[eE][+-]?[0-9]+))
            |   (?:[Nn]a[Nn]|[Ii]nf(?:inity)?)
            )
        """.components(separatedBy: .whitespacesAndNewlines).joined()
        let s_int = "([+-]?)(0x[0-9a-fA-F]+|0o[0-7]+|0b[01]+|[1-9][0-9]*|0)"
        let s_date    = "\\.Date\\(" + s_double + "\\)"
        // NB: no lookbehind — unsupported by the Swift 5.7 regex engine
        let s_string  = "\"((?:[^\"\\\\]|\\\\.)*)\""
        let s_base64  = "((?:[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/]+[=]{0,3})?)"
        let s_dataext = "\\.(Data|Ext)\\(\"" + s_base64 + "\"\\)"
        let s_comment = "//[^\n\r]*"    // greedy: consume the comment so its words never tokenize
        let s_all = [ "\\[", "\\]", ":", ",",
                      s_null, s_bool, s_date, s_double, s_int, s_dataext, s_string, s_comment
            ].joined(separator:"|")
        return try! Regex(s_all).dotMatchesNewlines()
    }()
    /// parse string to SION
    public static func parse(string:Swift.String)->Self {
        // A token is either a structural marker or an already-parsed leaf value.
        // Capturing the value during tokenization lets us parse in a single regex
        // pass instead of re-matching every scalar to recover its primitive value.
        enum Token { case open, close, colon, comma, value(SION) }
        func toInt(sign:Substring, magnitude:Substring)->Self {
            // decode via Int64 so radix literals beyond Int32.max parse on 32-bit platforms
            var parsed:Int64? = nil
            if magnitude.hasPrefix("0") && 2 < magnitude.count {
                let offset = magnitude.index(magnitude.startIndex, offsetBy:2)
                switch magnitude[magnitude.index(after:magnitude.startIndex)] {
                case "x": parsed = Int64(magnitude[offset...], radix:16)
                case "o": parsed = Int64(magnitude[offset...], radix:8)
                case "b": parsed = Int64(magnitude[offset...], radix:2)
                default:  parsed = Int64(magnitude)
                }
            } else {
                parsed = Int64(magnitude)
            }
            guard var int64 = parsed else { return .Error(.notASIONType) } // beyond Int64
            if sign == "-" { int64 = -int64 }
            guard let int = Swift.Int(exactly:int64) else { return .Double(Swift.Double(int64)) }
            return .Int(int)
        }
        func toNumber(sign:Substring, magnitude:Substring)->Self {
            // integer-valued literals (e.g. "1", "42") stay Int; the rest are Double
            if let int = Swift.Int(magnitude) {
                return .Int(sign == "-" ? -int : +int)
            }
            let double = Swift.Double(magnitude)!
            return .Double(sign == "-" ? -double : +double)
        }
        // decode a quoted string body: JSON escapes plus \0 and \u{...},
        // which SION's own serializer (String.debugDescription) emits
        func unquote(_ body:Substring)->Swift.String? {
            var out = Swift.String()
            out.reserveCapacity(body.count)
            var i = body.startIndex
            func hex4()->UInt32? {  // exactly 4 hex digits
                var v:UInt32 = 0
                for _ in 0..<4 {
                    guard i < body.endIndex, let d = body[i].hexDigitValue else { return nil }
                    v = v << 4 | UInt32(d)
                    i = body.index(after:i)
                }
                return v
            }
            func hexBraced()->UInt32? { // "{" 1...8 hex digits "}"
                i = body.index(after:i) // skip "{"
                var v:UInt32 = 0, n = 0
                while i < body.endIndex, let d = body[i].hexDigitValue {
                    n += 1
                    if 8 < n { return nil }
                    v = v << 4 | UInt32(d)
                    i = body.index(after:i)
                }
                guard 0 < n, i < body.endIndex, body[i] == "}" else { return nil }
                i = body.index(after:i)
                return v
            }
            while i < body.endIndex {
                let c = body[i]
                i = body.index(after:i)
                guard c == "\\" else { out.append(c); continue }
                guard i < body.endIndex else { return nil }
                let e = body[i]
                i = body.index(after:i)
                switch e {
                case "\"": out.append("\"")
                case "\\": out.append("\\")
                case "/":  out.append("/")
                case "0":  out.append("\0")
                case "b":  out.append("\u{08}")
                case "f":  out.append("\u{0C}")
                case "n":  out.append("\n")
                case "r":  out.append("\r")
                case "t":  out.append("\t")
                case "u":
                    var u:UInt32
                    if i < body.endIndex && body[i] == "{" {
                        guard let v = hexBraced() else { return nil }
                        u = v
                    } else {
                        guard let v = hex4() else { return nil }
                        u = v
                        if 0xD800...0xDBFF ~= u {   // high surrogate: pair with \uDC00...\uDFFF
                            guard i < body.endIndex, body[i] == "\\" else { return nil }
                            i = body.index(after:i)
                            guard i < body.endIndex, body[i] == "u" else { return nil }
                            i = body.index(after:i)
                            guard let lo = hex4(), 0xDC00...0xDFFF ~= lo else { return nil }
                            u = 0x10000 + ((u - 0xD800) << 10) + (lo - 0xDC00)
                        }
                    }
                    guard let scalar = Unicode.Scalar(u) else { return nil }
                    out.unicodeScalars.append(scalar)
                default: return nil
                }
            }
            return out
        }
        // Classify one non-structural match, reading its value straight from the
        // tokenizer's capture groups. Group layout of `s_all`:
        //   [1],[2] = date sign/magnitude    [3],[4] = double sign/magnitude
        //   [5],[6] = int sign/magnitude     [7] = Data|Ext   [8] = base64 body
        //   [9] = string body
        func toValue(_ whole:Substring, _ out:AnyRegexOutput)->Self {
            if whole == "nil"   { return .Nil }
            if whole == "true"  { return .Bool(true) }
            if whole == "false" { return .Bool(false) }
            if let magnitude = out[2].substring {   // .Date(...)
                let d = Swift.Double(magnitude)!
                return .Date(Foundation.Date(timeIntervalSince1970: out[1].substring == "-" ? -d : d))
            }
            if let magnitude = out[4].substring {
                return toNumber(sign: out[3].substring ?? "", magnitude: magnitude)
            }
            if let magnitude = out[6].substring {
                return toInt(sign: out[5].substring ?? "", magnitude: magnitude)
            }
            if let kind = out[7].substring {        // .Data(...) / .Ext(...)
                guard let data = Foundation.Data(base64Encoded:Swift.String(out[8].substring ?? ""),
                                                 options:[.ignoreUnknownCharacters]) else {
                    return .Error(.notASIONType)
                }
                return kind == "Ext" ? .Ext(data) : .Data(data)
            }
            if let body = out[9].substring {        // quoted string
                guard let s = unquote(body) else { return .Error(.notASIONType) }
                return .String(s)
            }
            return .Error(.notASIONType)
        }
        func tokenize(_ string:Swift.String)->[Token] {
            var tokens = [Token]()
            for match in string.matches(of:reToken) {
                let whole = string[match.range]
                switch whole {
                case "[": tokens.append(.open)
                case "]": tokens.append(.close)
                case ":": tokens.append(.colon)
                case ",": tokens.append(.comma)
                default:
                    if whole.hasPrefix("//") { continue } // ignore comment
                    tokens.append(.value(toValue(whole, match.output)))
                }
            }
            return tokens
        }
        func toCollection(_ tokens:[Token])->Self {
            let isDictionary:Bool = {
                if 2 < tokens.count, case .colon = tokens[2] { return true }
                if case .colon = tokens[1] { return true }
                return false
            }()
            var elems = [SION]()
            var i = 1, d = 0
            while i < tokens.count {
                if case .open = tokens[i] {
                    var subtokens:[Token] = [.open]
                    d = 1; i += 1
                    while i < tokens.count {
                        if case .open  = tokens[i] { d += 1 }
                        if case .close = tokens[i] { d -= 1 }
                        subtokens.append(tokens[i])
                        if d == 0 { break }
                        i += 1
                    }
                    elems.append(toCollection(subtokens))
                    continue
                }
                if case .value(let v) = tokens[i] { elems.append(v) }
                i += 1
            }
            if isDictionary {
                var dict = [Key:Value]()
                while !elems.isEmpty {
                    let v = elems.removeLast()
                    if elems.isEmpty { return .Error(.notASIONType) } // safety measure
                    let k = elems.removeLast()
                    dict[k] = v
                }
                return .Dictionary(dict)
            } else {
                return .Array(elems)
            }
        }
        let tokens = tokenize(string)
        if tokens.isEmpty { return .Error(.notASIONType) }
        if tokens.count == 1 {
            if case .value(let v) = tokens[0] { return v }
            return .Error(.notASIONType)
        }
        if case .open = tokens[0] { return toCollection(tokens) }
        return .Error(.notASIONType)
    }
    /// initialize from string
    public init(string:String) {
        self = .parse(string:string)
    }
}
extension SION : CodingKey {
    public init(stringValue s:String) {
        self = .String(s)
    }
    public init(intValue i:Int) {
        self = .Int(i)
    }
    public var stringValue: String {
        return self.string ?? self.description
    }
    public var intValue: Int? {
        return self.int
    }
}
extension SION : Codable {
    typealias SB    = Swift.Bool
    typealias SDbl  = Swift.Double
    typealias SInt  = Swift.Int
    typealias SStr  = Swift.String
    typealias FData = Foundation.Data
    typealias FDate = Foundation.Date
    private static let codableTypes:[Codable.Type] = [
        [SStr:Value].self, [Value].self, [Key:Value].self,
        SStr.self, SB.self, UInt.self, SInt.self,
        SDbl.self, Float.self, FData.self, FDate.self,
        UInt64.self, UInt32.self, UInt16.self, UInt8.self,
        Int64.self,  Int32.self,  Int16.self,  Int8.self,
    ]
    public init(from decoder: Decoder) throws {
        if let c = try? decoder.singleValueContainer(), !c.decodeNil() {
            for type in Self.codableTypes {
                switch type {
                case let t as Bool.Type:        if let v = try? c.decode(t) { self = .Bool(v); return }
                case let t as Int.Type:         if let v = try? c.decode(t) { self = .Int(v); return }
                case let t as Int8.Type:        if let v = try? c.decode(t) { self = .Int(SInt(v)); return }
                case let t as Int32.Type:       if let v = try? c.decode(t) { self = .Int(SInt(v)); return }
                case let t as Int64.Type:       if let v = try? c.decode(t) { self = .Int(SInt(v)); return }
                case let t as UInt.Type:        if let v = try? c.decode(t) { self = .Int(SInt(v)); return }
                case let t as UInt8.Type:       if let v = try? c.decode(t) { self = .Int(SInt(v)); return }
                case let t as UInt16.Type:      if let v = try? c.decode(t) { self = .Int(SInt(v)); return }
                case let t as UInt32.Type:      if let v = try? c.decode(t) { self = .Int(SInt(v)); return }
                case let t as UInt64.Type:      if let v = try? c.decode(t) { self = .Int(SInt(v)); return }
                case let t as Float.Type:       if let v = try? c.decode(t) { self = .Double(SDbl(v)); return }
                case let t as Double.Type:      if let v = try? c.decode(t) { self = .Double(v); return }
                case let t as String.Type:      if let v = try? c.decode(t) { self = .String(v); return }
                case let t as FDate.Type:       if let v = try? c.decode(t) { self = .Date(v); return }
                case let t as FData.Type:       if let v = try? c.decode(t) { self = .Data(v); return }
                case let t as [Value].Type:     if let v = try? c.decode(t) { self = .Array(v); return }
                case let t as [Key:Value].Type: if let v = try? c.decode(t) { self = .Dictionary(v); return }
                case let t as [SStr:Value].Type:if let v = try? c.decode(t) {
                    var o = [Key:Value]()
                    v.forEach{ o[SION($0.0)] = $0.1 }
                    self = .Dictionary(o)
                    return
                }
                default: break
                }
            }
        }
        self = .Nil
    }
    public func encode(to encoder: Encoder) throws {
        var sc = encoder.singleValueContainer()
        if self.isNil { try sc.encodeNil(); return }
        switch self {
        case .Bool(let v):      try sc.encode(v)
        case .Int(let v):       try sc.encode(v)
        case .Double(let v):    try sc.encode(v)
        case .String(let v):    try sc.encode(v)
        case .Data(let v):      try sc.encode(v)
        case .Date(let v):      try sc.encode(v)
        case .Ext(let v):       try sc.encode(v)
        case .Array(let v):     try sc.encode(v)
        case .Dictionary(let v):    // try sc.encode(v)
            // currently Encodable accepts string keys or int keys :-(
            var o = [Swift.String:Value]()
            v.forEach{ o[$0.0.stringValue] = $0.1 }
            try sc.encode(o)
        default:
            break
        }
    }
}
extension SION {
    public enum SIONError : Equatable {
        case notASIONType
        case notIterable(SION.ContentType)
        case notSubscriptable(SION.ContentType)
        case indexOutOfRange(SION.Index)
        case keyNonexistent(SION.Key)
        case nsError(NSError)
        case error(Swift.String)
    }
}
extension SION.SIONError : CustomStringConvertible {
    public enum ErrorType {
        case notASIONObject, notIterable, notSubscriptable, indexOutOfRange, keyNonexistent, nsError, error
    }
    public var type:ErrorType {
        switch self {
        case .notASIONType:         return .notASIONObject
        case .notIterable:          return .notIterable
        case .notSubscriptable(_):  return .notSubscriptable
        case .indexOutOfRange(_):   return .indexOutOfRange
        case .keyNonexistent(_):    return .keyNonexistent
        case .nsError(_):           return .nsError
        case .error(_):             return .error
        }
    }
    public var nsError:NSError? { switch self { case .nsError(let v) : return v default : return nil } }
    public var error:String?    { switch self { case .error(let v) : return v default : return nil } }
    public var description:String {
        switch self {
        case .notASIONType:             return "not a SION Type"
        case .notIterable(let t):       return "\(t) is not iterable"
        case .notSubscriptable(let t):  return "\(t) cannot be subscripted"
        case .indexOutOfRange(let i):   return "index \(i) is out of range"
        case .keyNonexistent(let k):    return "key \"\(k)\" does not exist"
        case .nsError(let e):           return "\(e)"
        case .error(let e):             return "\(e)"
        }
    }
}
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
extension SION {
    public static func parse(msgPack:Data)->Self {
        typealias I  = Swift.Int
        typealias S  = Swift.String
        typealias FD = Foundation.Data
        let err = Self.Error(.notASIONType)
        func inner(_ d:FD)->(SION, Int) {
            guard 0 < d.count else { return (err, 0) }
            switch d[0] {
            case 0x00...0x7f : return (.Int(Swift.Int(d[0])), 1)
            case 0xa0: return (.String(""), 1)
            case 0xc0: return (.Nil, 1)
            case 0xc2: return (.Bool(false), 1)
            case 0xc3: return (.Bool(true),  1)
            case 0xe0...0xff : return (.Int(I(Swift.Int8(bitPattern:d[0]))), 1)
            case 0xcc: return d.count < 2 ? (err, 0) :
                (.Int(Swift.Int(d[1])), 2)
            case 0xca: return d.count < 5 ? (err, 0) : (
                .Double(Swift.Double(Float32(bitPattern:
                    UInt32(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4]), to:UInt32.self))))), 5)
            case 0xcb: return d.count < 9 ? (err, 0) : (
                .Double(Swift.Double(bitPattern:
                    UInt64(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8]), to:UInt64.self)))), 9)
            case 0xcd: return d.count < 3 ? (err, 0) :
                    (.Int(I(UInt16(bigEndian:unsafeBitCast((d[1],d[2]), to:UInt16.self)))), 3)
            case 0xce:                      // uint32: may exceed Int.max on 32-bit platforms
                guard 5 <= d.count else { return (err, 0) }
                let u = UInt32(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4]), to:UInt32.self))
                guard let v = I(exactly:u) else { return (err, 0) }
                return (.Int(v), 5)
            case 0xcf:                      // uint64: error out instead of wrapping negative
                guard 9 <= d.count else { return (err, 0) }
                let u = UInt64(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8]), to:UInt64.self))
                guard u <= UInt64(Swift.Int.max) else { return (err, 0) }
                return (.Int(I(u)), 9)
            case 0xd0: return d.count < 2 ? (err, 0) :
                ( .Int(I(Int8(bitPattern:d[1]))), 2)
            case 0xd1: return d.count < 3 ? (err, 0) :
                ( .Int(I(Int16(bigEndian:unsafeBitCast((d[1],d[2]), to:Int16.self)))), 3)
            case 0xd2: return d.count < 5 ? (err, 0) :
                ( .Int(I(Int32(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4]), to:Int32.self)))), 5)
            case 0xd3:                      // int64: decode as Int64, not word-sized Int
                guard 9 <= d.count else { return (err, 0) }
                let v64 = Int64(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8]), to:Int64.self))
                guard let v = I(exactly:v64) else { return (err, 0) }
                return (.Int(v), 9)
            case 0b10100000...0b10111111:   // fixstr
                let len = I(d[0] & 0b11111)
                guard len+1 <= d.count, let s = S(data:d[1..<len+1], encoding:.utf8) else { return (err, 0) }
                return (.String(s), len+1)
            case 0xd9:                      // str8
                guard 1 < d.count else { return (err, 0) }
                let len = I(d[1])
                guard len+2 <= d.count, let s = S(data:d[2..<len+2], encoding:.utf8) else { return (err, 0) }
                return (.String(s), len+2)
            case 0xda:                      // str16
                guard 2 < d.count else { return (err, 0) }
                let len = I(UInt16(bigEndian:unsafeBitCast((d[1],d[2]), to:UInt16.self)))
                guard len+3 <= d.count, let s = S(data:d[3..<len+3], encoding:.utf8) else { return (err, 0) }
                return (.String(s), len+3)
            case 0xdb:                      // str32
                guard 4 < d.count else { return (err, 0) }
                guard let len = I(exactly:UInt32(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4]), to:UInt32.self))) else { return (err, 0) }
                guard len+5 <= d.count, let s = S(data:d[5..<len+5], encoding:.utf8) else { return (err, 0) }
                return (.String(s), len+5)
            case 0xc4:                      // bin8
                guard 1 < d.count else { return (err, 0) }
                let len = I(d[1])
                guard len+2 <= d.count else { return (err, 0) }
                return (.Data(d[2..<len+2]), len+2)
            case 0xc5:                      // bin16
                guard 2 < d.count else { return (err, 0) }
                let len = I(UInt16(bigEndian:unsafeBitCast((d[1],d[2]), to:UInt16.self)))
                guard len+3 <= d.count else { return (err, 0) }
                return (.Data(d[3..<len+3]), len+3)
            case 0xc6:                      // bin32
                guard 4 < d.count else { return (err, 0) }
                guard let len = I(exactly:UInt32(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4]), to:UInt32.self))) else { return (err, 0) }
                guard len+5 <= d.count else { return (err, 0) }
                return (.Data(d[5..<len+5]), len+5)
            case 0b10010000...0b10011111:   // fixarray
                let len = I(d[0] & 0b1111)
                var (a, o) = ([SION](), 1)
                for _ in 0..<len {
                    let (v, c) = inner(FD(d[o...]))
                    if v == err { return (err, 0) }
                    o += c
                    a.append(v)
                }
                return (.Array(a), o)
            case 0xdc:
                guard 2 < d.count else { return (err, 0) }
                let len = UInt16(bigEndian:unsafeBitCast((d[1],d[2]), to:UInt16.self))
                var (a, o) = ([SION](), 3)
                for _ in 0..<len {
                    let (v, c) = inner(FD(d[o...]))
                    if v == err { return (err, 0) }
                    o += c
                    a.append(v)
                }
                return (.Array(a), o)
            case 0xdd:
                guard 4 < d.count else { return (err, 0) }
                let len = UInt32(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4]), to:UInt32.self))
                var (a, o) = ([SION](), 5)
                for _ in 0..<len {
                    let (v, c) = inner(FD(d[o...]))
                    if v == err { return (err, 0) }
                    o += c
                    a.append(v)
                }
                return (.Array(a), o)
            case 0b10000000...0b10001111:   // fixmap
                let len = I(d[0] & 0b1111)
                var (m, o) = ([Key:Value](), 1)
                for _ in 0..<len {
                    let (k, ck) = inner(FD(d[o...]))
                    if k == err { return (err, 0) }
                    o += ck
                    let (v, cv) = inner(FD(d[o...]))
                    if v == err { return (err, 0) }
                    o += cv
                    m[k] = v
                }
                return (.Dictionary(m), o)
            case 0xde:
                guard 2 < d.count else { return (err, 0) }
                let len = UInt16(bigEndian:unsafeBitCast((d[1],d[2]), to:UInt16.self))
                var (m, o) = ([Key:Value](), 3)
                for _ in 0..<len {
                    let (k, ck) = inner(FD(d[o...]))
                    if k == err { return (err, 0) }
                    o += ck
                    let (v, cv) = inner(FD(d[o...]))
                    if v == err { return (err, 0) }
                    o += cv
                    m[k] = v
                }
                return (.Dictionary(m), o)
            case 0xdf:
                guard 4 < d.count else { return (err, 0) }
                let len = UInt32(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4]), to:UInt32.self))
                var (m, o) = ([Key:Value](), 5)
                for _ in 0..<len {
                    let (k, ck) = inner(FD(d[o...]))
                    if k == err { return (err, 0) }
                    o += ck
                    let (v, cv) = inner(FD(d[o...]))
                    if v == err { return (err, 0) }
                    o += cv
                    m[k] = v
                }
                return (.Dictionary(m), o)
            case 0xd4:                      // fixext1
                guard 3 <= d.count else { return (err, 0) }
                return (.Ext(d[0..<3]), 3)
            case 0xd5:                      // fixext2
                guard 4 <= d.count else { return (err, 0) }
                return (.Ext(d[0..<4]), 4)
            case 0xd6:                      // fixext4
                guard 6 <= d.count else { return (err, 0) }
                if d[1] == 0xff {   // timestamp32
                    let tv_sec =
                        UInt32(bigEndian: unsafeBitCast((d[2],d[3],d[4],d[5]), to: UInt32.self))
                    let time = Swift.Double(tv_sec)
                    return (.Date(Foundation.Date(timeIntervalSince1970: time)), 6)
                }
                return (.Ext(d[0..<6]), 6)
            case 0xd7:                      // fixext8
                guard 10 <= d.count else { return (err, 0) }
                if d[1] == 0xff {   // timestamp64
                    let data64 =
                        UInt64(bigEndian: unsafeBitCast((d[2],d[3],d[4],d[5],d[6],d[7],d[8],d[9]), to: UInt64.self))
                    let tv_nsec = data64 >> 34;
                    let tv_sec = data64 & 0x00000003ffffffff;
                    let time = Swift.Double(tv_sec) + Swift.Double(tv_nsec)/1e9
                    return (.Date(Foundation.Date(timeIntervalSince1970: time)), 10)
                }
                return (.Ext(d[0..<10]), 10)
            case 0xd8:                      // fixext16
                guard 18 <= d.count else { return (err, 0) }
                return (.Ext(d[0..<18]), 18)
            case 0xc7:                      // ext8: [0xc7, len, type, payload...]
                guard 2 < d.count else { return (err, 0) }
                let len = I(d[1])
                guard len+3 <= d.count else { return (err, 0) }
                if len == 12, d[2] == 0xff {    // timestamp96: nsec(u32) + sec(i64)
                    let tv_nsec = UInt32(bigEndian:unsafeBitCast((d[3],d[4],d[5],d[6]), to: UInt32.self))
                    let tv_sec =
                        Int64(bigEndian: unsafeBitCast((d[7],d[8],d[9],d[10],d[11],d[12],d[13],d[14]), to: Int64.self))
                    let time = Swift.Double(tv_sec) + Swift.Double(tv_nsec)/1e9
                    return (.Date(Foundation.Date(timeIntervalSince1970: time)), 15)
                }
                return (.Ext(d[0..<len+3]), len+3)
            case 0xc8:                      // ext16
                guard 3 < d.count else { return (err, 0) }
                let len = I(UInt16(bigEndian:unsafeBitCast((d[1],d[2]), to:UInt16.self)))
                guard len+4 <= d.count else { return (err, 0) }
                return (.Ext(d[0..<len+4]), len+4)
            case 0xc9:                      // ext32
                guard 5 < d.count else { return (err, 0) }
                guard let len = I(exactly:UInt32(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4]), to:UInt32.self))) else { return (err, 0) }
                guard len+6 <= d.count else { return (err, 0) }
                return (.Ext(d[0..<len+6]), len+6)
            default:
                return (err, 0)
            }
        }
        return inner(FD(msgPack)).0 // FD(_:) rebases indices in case a Data slice is passed
    }
    public init(msgPack data:Data) {
        self = .parse(msgPack:data)
    }
    public var msgPack:Foundation.Data {
        typealias C = UInt8
        typealias FD = Foundation.Data
        switch self {
        case .Nil:              return FD([0xc0])
        case .Bool(let v):      return FD([v ? 0xc3 : 0xc2])
        case .Int(let v):
            switch v {
            case -32...0x7f:
                return FD([UInt8(bitPattern:Int8(v))])
            case -0x80...0x7f :
                return FD([0xd0, UInt8(bitPattern:Int8(v))])
            case -0x8000...0x7fff:
                let (u0,u1) = unsafeBitCast(Int16(bigEndian: Int16(v)), to:(C,C).self)
                return FD([0xd1, u0,u1])
            case -0x8000_0000...0x7fff_ffff:
                let (u0,u1,u2,u3) = unsafeBitCast(Int32(bigEndian: Int32(v)), to:(C,C,C,C).self)
                return FD([0xd2, u0,u1,u2,u3])
            default:
                let (u0,u1,u2,u3,u4,u5,u6,u7) = unsafeBitCast(Int64(bigEndian: Int64(v)), to:(C,C,C,C,C,C,C,C).self)
                return FD([0xd3, u0,u1,u2,u3,u4,u5,u6,u7])
            }
        case .Double(let v):
            let u64 = UInt64(bigEndian: UInt64(v.bitPattern))
            let (u0,u1,u2,u3,u4,u5,u6,u7) = unsafeBitCast(u64, to:(C,C,C,C,C,C,C,C).self)
            return FD([0xcb, u0,u1,u2,u3,u4,u5,u6,u7])
        case .String(let v):
            let d = v.data(using:.utf8)!
            switch d.count {
            case 0...0b11111 :  // fixstr
                return FD([UInt8(0b10100000 | d.count)]) + d
            case 0x20...0xff :
                return FD([0xd9, UInt8(d.count)]) + d
            case 0x80...0xffff:
                let (u1,u2) = unsafeBitCast(UInt16(bigEndian:UInt16(d.count)), to:(C,C).self)
                return FD([0xda,u1,u2]) + d
            case 0x10000...:    // no 0xffff_ffff upper bound: it overflows Int on 32-bit platforms
                guard let len = UInt32(exactly:d.count) else { fatalError("String too large!") }
                let (u1,u2,u3,u4) = unsafeBitCast(UInt32(bigEndian:len), to:(C,C,C,C).self)
                return FD([0xdb,u1,u2,u3,u4]) + d
            default:
                fatalError("String too large!")
            }
        case .Data(let d):
            switch d.count {
            case 0...0xff :
                return FD([0xc4, UInt8(d.count)]) + d
            case 0x80...0xffff:
                let (u1,u2) = unsafeBitCast(UInt16(bigEndian:UInt16(d.count)), to:(C,C).self)
                return FD([0xc5,u1,u2]) + d
            case 0x10000...:
                guard let len = UInt32(exactly:d.count) else { fatalError("Data too large!") }
                let (u1,u2,u3,u4) = unsafeBitCast(UInt32(bigEndian:len), to:(C,C,C,C).self)
                return FD([0xc6,u1,u2,u3,u4]) + d
            default:
                fatalError("Data too large!")
            }
        case .Array(let a):
            switch a.count {
            case 0...0xf:
                var d = FD([UInt8(0b10010000 | a.count)])
                a.forEach{ d += $0.msgPack }
                return d
            case 0x10...0xffff:
                let (u1,u2) = unsafeBitCast(UInt16(bigEndian:UInt16(a.count)), to:(C,C).self)
                var d = FD([0xdc,u1,u2])
                a.forEach{ d += $0.msgPack }
                return d
            case 0x10000...:
                guard let len = UInt32(exactly:a.count) else { fatalError("Array too large!") }
                let (u1,u2,u3,u4) = unsafeBitCast(UInt32(bigEndian:len), to:(C,C,C,C).self)
                var d = FD([0xdd,u1,u2,u3,u4])
                a.forEach{ d += $0.msgPack }
                return d
            default:
                fatalError("Array too large!")
            }
        case .Dictionary(let m):
            switch m.count {
            case 0...0xf:
                var d = FD([UInt8(0b10000000 | m.count)])
                m.forEach{ d += $0.0.msgPack + $0.1.msgPack }
                return d
            case 0x10...0xffff:
                let (u1,u2) = unsafeBitCast(UInt16(bigEndian:UInt16(m.count)), to:(C,C).self)
                var d = FD([0xde,u1,u2])
                m.forEach{ d += $0.0.msgPack + $0.1.msgPack }
                return d
            case 0x10000...:
                guard let len = UInt32(exactly:m.count) else { fatalError("Map too large!") }
                let (u1,u2,u3,u4) = unsafeBitCast(UInt32(bigEndian:len), to:(C,C,C,C).self)
                var d = FD([0xdf,u1,u2,u3,u4])
                m.forEach{ d += $0.0.msgPack + $0.1.msgPack }
                return d
            default:
                fatalError("Map too large!")
            }
        case .Date(let v):
            let time = v.timeIntervalSince1970
            let sec  = floor(time)
            let nsec = Swift.min(UInt32((time - sec) * 1e9), 999_999_999)
            if 0 <= sec && sec < 0x4_0000_0000 {    // fits timestamp64 (34-bit seconds)
                let data64  = UInt64(bigEndian:(UInt64(nsec) << 34) | UInt64(sec))
                let (u1,u2,u3,u4,u5,u6,u7,u8) = unsafeBitCast(data64, to:(C,C,C,C,C,C,C,C).self)
                return FD([0xd7, 0xff, u1,u2,u3,u4,u5,u6,u7,u8])
            } else {                                // timestamp96: nsec(u32) + sec(i64)
                let (n1,n2,n3,n4) = unsafeBitCast(UInt32(bigEndian:nsec), to:(C,C,C,C).self)
                let (s1,s2,s3,s4,s5,s6,s7,s8) = unsafeBitCast(Int64(bigEndian:Int64(sec)), to:(C,C,C,C,C,C,C,C).self)
                return FD([0xc7, 12, 0xff, n1,n2,n3,n4, s1,s2,s3,s4,s5,s6,s7,s8])
            }
        case .Ext(let v):
            return v    // return as is
        default:
            fatalError("Invalid msgPack")
        }
    }
}
