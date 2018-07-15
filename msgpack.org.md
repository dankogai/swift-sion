# SION supports MessagePack natively

## Synopsis

```swift
import SION
import Foundation
let data    = Data([    // ["compact":true,"schema":0]
    0x82,0xa7,0x63,0x6f,0x6d,0x70,0x61,0x63,
    0x74,0xc3,0xa6,0x73,0x63,0x68,0x65,0x6d,
    0x61,0x00
])
let sion    = SION(msgPack: data)  // deselialize
let msgPack = sion.msgPack         // serialize
data == msgPack                    // true
```

for details of the module, visit:

* https://github.com/dankogai/swift-sion

for details of the SION serialization format, visit:

* https://dankogai.github.io/SION