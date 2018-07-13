//
//  SION.swift
//  SION
//
//  Created by Dan Kogai on 7/15/14.
//  Copyright (c) 2018 Dan Kogai. All rights reserved.
//

import Foundation

public indirect enum SION:Equatable {
    public enum SIONError : Equatable {
        case notASIONType
        case notIterable(SION.ContentType)
        case notSubscriptable(SION.ContentType)
        case indexOutOfRange(SION.Index)
        case keyNonexistent(SION.Key)
        case nsError(NSError)
        case error(Swift.String)
    }
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
    public var hashValue: Int {
        switch self {
        case .Error(let m):         fatalError("\(m)")
        case .Nil:                  return NSNull().hashValue
        case .Bool(let v):          return v.hashValue
        case .Int(let v):           return v.hashValue
        case .Double(let v):        return v.hashValue
        case .Date(let v):          return v.hashValue
        case .String(let v):        return v.hashValue
        case .Data(let v):          return v.hashValue
        case .Ext(let v):           return v.hashValue
        case .Array(let v):         return "\(v)".hashValue // will be fixed in Swift 4.2
        case .Dictionary(let v):    return "\(v)".hashValue // will be fixed in Swift 4.2
        }
    }
}
extension SION : CustomStringConvertible, CustomDebugStringConvertible {
    public func toString(depth d:Int, separator s:String, terminator t:String, sortedKey:Bool=false)->String {
        let i = Swift.String(repeating:s, count:d)
        let g = s == "" ? "" : " "
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
                    .map{ i + s + $0 }.joined(separator:","+t) + t
                + i + "]" + (d == 0 ? t : "")
        case .Dictionary(let o):
            guard !o.isEmpty else { return "[:]" }
            let a = sortedKey ? o.map{ $0 }.sorted{ $0.0.description < $1.0.description } : o.map{ $0 }
            return "[" + t
                + a.map {
                    $0.toString(depth:d+1, separator:s, terminator:t, sortedKey:sortedKey)
                    + g + ":" + g
                    + $1.toString(depth:d+1, separator:s, terminator:t, sortedKey:sortedKey)
                    }.map{ i + s + $0 }.joined(separator:"," + t) + t
                + i + "]" + (d == 0 ? t : "")
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
extension Data:ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value:StringLiteralType) {
        self.init(base64Encoded:value, options:[.ignoreUnknownCharacters])!
    }
}
extension Date:ExpressibleByFloatLiteral {
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
    public init(arrayLiteral value:SION...)     { self = .Array(value)  }
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
        // Be careful! SIONSerialization renders bool as NSNumber use .objcType to tell the difference
        case let a as NSNumber:
            switch Swift.String(cString:a.objCType) {
            case "c", "C":  self = .Bool(a as! Bool)
            case "s","S","l","L","q","Q":   self = .Int(a as! Int)
            default:        self = .Double(a as! Double)
            }
        case nil:               self = .Nil
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
            a.forEach{ o[.String($0.0)] = SION(nsObject:$0.1) }
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
            return NSDictionary(objects: v, forKeys: k)
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
    public init(jsonUrlString:String) {
        if let url = URL(string: jsonUrlString) {
            self = SION(jsonURL:url)
        } else {
            self = SION.Nil
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
        return try JSONSerialization.jsonObject(with:self.json.data(using: .utf8)!, options:[.allowFragments])
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
    public enum ContentType {
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
    public var isNil:Bool           { return type == .null }
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
    public subscript(_ idx:Index)->SION {
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
    public subscript(_ key:Key)->SION {
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
                fatalError("\"\(self)\" is not an object")
            }
        }
    }
}
extension SION : Sequence {
    public typealias Element = (key:SION,value:SION)  // for Sequence conformance
    public typealias Iterator = AnyIterator<Element>
    public func makeIterator() -> AnyIterator<SION.Element> {
        switch self {
        case .Array(let a):
            var i = -1
            return AnyIterator {
                i += 1
                return a.count <= i ? nil : (SION.Int(i), a[i])
            }
        case .Dictionary(let o):
            var kv = o.map{ $0 }
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
    public func walk(depth:Int=0, visit:(SION)->SION)->SION {
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
    public func walk(depth:Int=0, collect:(SION, [Element], Int)->SION)->SION {
        return self.walk(depth:depth, collect:collect, visit:{ $0 })
    }
    public func pick(picker:(SION)->Bool)->SION {
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
    /// parse string to SION
    public static func parse(string:Swift.String)->SION {
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
        let s_date    = ".Date\\(" + s_double + "\\)"
        let s_string  = "\"(.*?)(?<!\\\\)\""
        let s_base64  = "(?:[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/]+[=]{0,3})?"
        let s_dataext = ".(?:Data|Ext)\\(\"" + s_base64 + "\"\\)"
        let s_comment = "//.*?(?:\n|\r|\r\n)"
        let s_all = [ "\\[", "\\]", ":", ",",
                      s_null, s_bool, s_date, s_double, s_int, s_dataext, s_string, s_comment
            ].joined(separator:"|")
        let reAll    = try! NSRegularExpression(pattern: s_all, options: [.dotMatchesLineSeparators])
        let reDouble = try! NSRegularExpression(pattern:"\\A\(s_double)\\z")
        let reInt    = try! NSRegularExpression(pattern:"\\A\(s_int)\\z")
        func tokenize(_ string:Swift.String)->[Swift.String] {
            var tokens = [Swift.String]()
            reAll.enumerateMatches(in: string, range:NSRange(0..<string.count)) { cr, _, _ in
                let token = Swift.String(string[Range(cr!.range, in:string)!])
                if token.hasPrefix("//") { return } // ignore comment
                tokens.append( token )
            }
            return tokens
        }
        func toBool(_ s:String)->SION? {
            return s == "true" ? .Bool(true) : s == "false" ? .Bool(false) : nil
        }
        func toDouble(_ s:String)->SION? {
            guard let cr = reDouble.firstMatch(in: s, range: NSRange(0..<s.count)) else { return nil }
            let sign      = s[Range(cr.range(at:1), in:s)!]
            let magnitude = s[Range(cr.range(at:2), in:s)!]
            // debugPrint(sign, magnitude)
            let double    = (sign == "-" ? -1.0 : +1.0) * Swift.Double(magnitude)!
            return .Double(double)
        }
        func toInt(_ s:String)->SION? {
            guard let cr = reInt.firstMatch(in: s, range: NSRange(0..<s.count)) else { return nil }
            var int = 0
            let sign      = s[Range(cr.range(at:1), in:s)!]
            let magnitude = s[Range(cr.range(at:2), in:s)!]
            if magnitude.hasPrefix("0") && 2 < magnitude.count {
                let offset = magnitude.index(magnitude.startIndex, offsetBy:2)
                switch magnitude[magnitude.index(after:magnitude.startIndex)] {
                case "x": int = Swift.Int(magnitude[offset...], radix:16)!
                case "o": int = Swift.Int(magnitude[offset...], radix:8)!
                case "b": int = Swift.Int(magnitude[offset...], radix:2)!
                default: int = Swift.Int(magnitude)!
                }
            } else {
                int = Swift.Int(magnitude)!
            }
            return .Int(sign == "-" ? -int : +int)
        }
        func toDate(_ s:String)->SION? {
            //                 0123456
            guard s.hasPrefix(".Date(") else { return nil }
            guard s.hasSuffix(")")      else { return nil }
            var ss = s
            ss.removeFirst(6)
            ss.removeLast(1)
            if let d = Swift.Double(ss) {
                let date = Foundation.Date(timeIntervalSince1970: d)
                return SION.Date(date)
            }
            return nil
        }
        func toString(_ s:String)->SION? {
            if s.first != "\"" { return nil }
            if s.last  != "\"" { return nil }
            return SION(json:Swift.String(s))
        }
        func toDataExt(_ s:String)->SION? {
            //                             012345 6                          01234 5
            let isExt:Bool? = s.hasPrefix(".Data(\"") ? false : s.hasPrefix(".Ext(\"") ? true : nil
            if isExt == nil { return nil }
            guard s.hasSuffix("\")") else { return nil }
            var ss = s
            ss.removeFirst(isExt! ? 6 : 7)
            ss.removeLast(2)
            // print(ss)
            if let data = Foundation.Data(base64Encoded:ss, options:[.ignoreUnknownCharacters]) {
                return isExt! ? SION.Ext(data) : SION.Data(data)
            }
            return nil
        }
        func toElement(_ s:Swift.String)->SION {
            return s == "nil" ? .Nil
                : toBool(s) ?? toInt(s) ?? toDate(s) ?? toDouble(s) ?? toDataExt(s) ?? toString(s) ?? .Error(.notASIONType)
        }
        func toCollection(_ tokens:[Swift.String])->SION {
            let isDictionary = 2 < tokens.count && tokens[2] == ":" || tokens[1] == ":"
            var elems = [SION]()
            var i = 1, d = 0
            while i < tokens.count {
                if tokens[i] == "[" {
                    var subtokens = ["["]
                    d = 1; i += 1
                    while i < tokens.count {
                        if tokens[i] == "["         { d += 1 }
                        else if tokens[i] == "]"    { d -= 1 }
                        subtokens.append(tokens[i])
                        if d == 0 { break }
                        i += 1
                    }
                    elems.append(toCollection(subtokens))
                    continue
                }
                if !Set([":", ",", "[", "]"]).contains(tokens[i]) {
                    elems.append(toElement(tokens[i]))
                }
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
        return tokens.isEmpty ? .Error(.notASIONType)
            :  tokens.count == 1 ? toElement(tokens[0])
            :  tokens[0] == "["  ? toCollection(tokens)
            : .Error(.notASIONType)
    }
    /// initialize from string
    public init(string:String) {
        self = SION.parse(string:string)
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
    typealias CK = Swift.String
    private static let codableTypes:[Codable.Type] = [
        [CK:Value].self, [Value].self,
        Swift.String.self,
        Swift.Bool.self,
        Swift.UInt.self, Swift.Int.self,
        Swift.Double.self, Swift.Float.self,
        Foundation.Data.self, Foundation.Date.self,
        UInt64.self, UInt32.self, UInt16.self, UInt8.self,
        Int64.self,  Int32.self,  Int16.self,  Int8.self,
    ]
    public init(from decoder: Decoder) throws {
        if let c = try? decoder.singleValueContainer(), !c.decodeNil() {
            for type in SION.codableTypes {
                switch type {
                case let t as Swift.Bool.Type:  if let v = try? c.decode(t) { self = .Bool(v); return }
                case let t as Int.Type:         if let v = try? c.decode(t) { self = .Int(v); return }
                case let t as Int8.Type:        if let v = try? c.decode(t) { self = .Int(Swift.Int(v)); return }
                case let t as Int32.Type:       if let v = try? c.decode(t) { self = .Int(Swift.Int(v)); return }
                case let t as Int64.Type:       if let v = try? c.decode(t) { self = .Int(Swift.Int(v)); return }
                case let t as UInt.Type:        if let v = try? c.decode(t) { self = .Int(Swift.Int(v)); return }
                case let t as UInt8.Type:       if let v = try? c.decode(t) { self = .Int(Swift.Int(v)); return }
                case let t as UInt16.Type:      if let v = try? c.decode(t) { self = .Int(Swift.Int(v)); return }
                case let t as UInt32.Type:      if let v = try? c.decode(t) { self = .Int(Swift.Int(v)); return }
                case let t as UInt64.Type:      if let v = try? c.decode(t) { self = .Int(Swift.Int(v)); return }
                case let t as Float.Type:       if let v = try? c.decode(t) { self = .Double(Swift.Double(v)); return }
                case let t as Double.Type:      if let v = try? c.decode(t) { self = .Double(v); return }
                case let t as Swift.String.Type:if let v = try? c.decode(t) { self = .String(v); return }
                case let t as Foundation.Date.Type: if let v = try? c.decode(t) { self = .Date(v); return }
                case let t as Foundation.Data.Type: if let v = try? c.decode(t) { self = .Data(v); return }
                case let t as [Value].Type:     if let v = try? c.decode(t) { self = .Array(v); return }
                case let t as [CK:Value].Type:  if let v = try? c.decode(t) {
                    var o = [Key:Value]()
                    v.forEach{ o[SION($0.0)] = $0.1 }
                    self = .Dictionary(o)
                    return
                }
                default: break
                }
            }
        }
        self = SION.Nil
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
        case .Dictionary(let v):
            // try sc.encode(v)
            // currently Encodable accepts string keys or int keys :-(
            var o = [Swift.String:Value]()
            v.forEach{ o[$0.0.stringValue] = $0.1 }
            try sc.encode(o)
        default:
            break
        }
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
    public static func parse(msgPack d:Data)->SION {
        let err = SION.Error(.notASIONType)
        guard 0 < d.count else { return err }
        if d.count == 1 {
            switch d[0] {
            case 0x00...0x7f : return .Int(Swift.Int(d[0]))
            case 0xc0: return .Nil
            case 0xc2: return .Bool(false)
            case 0xc3: return .Bool(true)
            case 0xe0...0xff : return .Int(Swift.Int(Swift.Int8(bitPattern:d[0])))
            default:
                 return .Error(.notASIONType)
            }
        }
        switch d[0] {
        case 0xcc: return d.count != 2 ? err
            : .Int(Swift.Int(d[1]))
        case 0xca: return d.count != 5 ? err
            : .Double(Swift.Double(Float32(bitPattern:
                UInt32(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4]), to:UInt32.self)))))
        case 0xcb: return d.count != 9 ? err
            : .Double(Swift.Double(bitPattern:
                UInt64(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8]), to:UInt64.self))))
        case 0xcd: return d.count != 3 ? err
            : .Int(Swift.Int(UInt16(bigEndian:unsafeBitCast((d[1],d[2]), to:UInt16.self))))
        case 0xce: return d.count != 5 ? err
                : .Int(Swift.Int(UInt32(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4]), to:UInt32.self))))
        case 0xcf: return d.count != 9 ? err
            : .Int(Swift.Int(bitPattern:UInt(bigEndian:unsafeBitCast(
                (d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8]), to:UInt.self))))
        case 0xd0: return d.count != 2 ? err
            : .Int(Swift.Int(Int8(bitPattern:d[1])))
        case 0xd1: return d.count != 3 ? err
            : .Int(Swift.Int(Int16(bigEndian:unsafeBitCast((d[1],d[2]), to:Int16.self))))
        case 0xd2: return d.count != 5 ? err
            : .Int(Swift.Int(Int32(bigEndian:unsafeBitCast((d[1],d[2],d[3],d[4]), to:Int32.self))))
        case 0xd3: return d.count != 9 ? err
            : .Int(Swift.Int(bitPattern:UInt(bigEndian:unsafeBitCast(
                (d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8]), to:UInt.self))))
        default:
            return err
        }
    }
    public init(msgPack data:Data) {
        self = SION.parse(msgPack:data)
    }
    public var msgPack:Foundation.Data {
        typealias C = UInt8
        switch self {
        case .Nil:              return Foundation.Data([0xc0])
        case .Bool(let v):      return Foundation.Data([v ? 0xc3 : 0xc2])
        case .Int(let v):
            switch v {
            case -32...0x7f:
                return Foundation.Data([UInt8(bitPattern:Int8(v))])
            case -0x80...0x7f :
                return Foundation.Data([0xd0, UInt8(bitPattern:Int8(v))])
            case -0x8000...0x7fff:
                let (u0,u1) = unsafeBitCast(Int16(bigEndian: Int16(v)), to:(C,C).self)
                return Foundation.Data([0xd1, u0,u1])
            case -0x8000_0000...0x7fff_ffff:
                let (u0,u1,u2,u3) = unsafeBitCast(Int32(bigEndian: Int32(v)), to:(C,C,C,C).self)
                return Foundation.Data([0xd2, u0,u1,u2,u3])
            default:
                let (u0,u1,u2,u3,u4,u5,u6,u7) = unsafeBitCast(Swift.Int(bigEndian: v), to:(C,C,C,C,C,C,C,C).self)
                return Foundation.Data([0xd3, u0,u1,u2,u3,u4,u5,u6,u7])
            }
        case .Double(let v):
            let u64 = UInt64(bigEndian: UInt64(v.bitPattern))
            let (u0,u1,u2,u3,u4,u5,u6,u7) = unsafeBitCast(u64, to:(C,C,C,C,C,C,C,C).self)
            return Foundation.Data([0xcb, u0,u1,u2,u3,u4,u5,u6,u7])
//        case .Double(let v):    return v.description
//        case .Date(let v):      return v.timeIntervalSince1970.description
//        case .String(let v):    return v.debugDescription
//        case .Data(let v):      return "\"" + v.base64EncodedString() + "\""
//        case .Ext(let v):       return "\"" + v.base64EncodedString() + "\""
        default:
            return Foundation.Data()
        }
    }
}
