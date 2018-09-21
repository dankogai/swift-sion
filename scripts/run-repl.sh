#!/bin/bash
bd=".build/release"
swift build -c release -Xswiftc -enable-testing \
    && swift -I${bd} -L${bd} -lSION
