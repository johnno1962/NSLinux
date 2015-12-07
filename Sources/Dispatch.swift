//
//  Dispatch.swift
//  NSLinux
//
//  Created by John Holdsworth on 11/06/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//
//  $Id: //depot/NSLinux/Sources/Dispatch.swift#3 $
//
//  Repo: https://github.com/johnno1962/NSLinux
//

// Hastily put together libdispatch substitutes

#if os(Linux)
import Glibc

public let DISPATCH_QUEUE_CONCURRENT = 0, DISPATCH_QUEUE_PRIORITY_HIGH = 0

public func dispatch_get_global_queue( type: Int, _ flags: Int ) -> Int {
    return type
}

public func dispatch_queue_create( name: String, _ type: Int ) -> Int {
    return type
}

public func dispatch_async( queue: Int, _ block: () -> () ) {
    block()
}
#endif
