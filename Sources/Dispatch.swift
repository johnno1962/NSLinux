//
//  Dispatch.swift
//  NSLinux
//
//  Created by John Holdsworth on 11/06/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//
//  $Id: //depot/NSLinux/Sources/Dispatch.swift#9 $
//
//  Repo: https://github.com/johnno1962/NSLinux
//

// Hastily put together libdispatch substitutes

#if os(Linux)
import Glibc

public typealias dispatch_queue_t = Int
public typealias dispatch_time_t = Int64 // is UInt64 in Foundation/Dispatch
public typealias dispatch_block_t = () -> ()
public typealias dispatch_queue_attr_t = Int
 
public let DISPATCH_QUEUE_CONCURRENT = 0, DISPATCH_QUEUE_PRIORITY_HIGH = 0, DISPATCH_QUEUE_PRIORITY_LOW = 0, DISPATCH_QUEUE_PRIORITY_BACKGROUND = 0

public func dispatch_get_global_queue( type: Int, _ flags: UInt ) -> dispatch_queue_t {
    return type
}

public func dispatch_queue_create( name: UnsafePointer<Int8>, _ type: dispatch_queue_attr_t? ) -> dispatch_queue_t {
    return type ?? 0
}

public func dispatch_sync( queue: dispatch_queue_t, _ block: dispatch_block_t ) {
    block()
}

private class pthreadBlock {

    let block: dispatch_block_t

    init( block: dispatch_block_t ) {
        self.block = block
    }
}

private func pthreadRunner( arg: UnsafeMutablePointer<Void> ) -> UnsafeMutablePointer<Void> {
    let unmanaged = Unmanaged<pthreadBlock>.fromOpaque( COpaquePointer( arg ) )
    unmanaged.takeUnretainedValue().block()
    unmanaged.release()
    return arg
}

public func dispatch_async( queue: dispatch_queue_t, _ block: dispatch_block_t ) {
    let holder = Unmanaged.passRetained( pthreadBlock( block: block ) )
    let pointer = UnsafeMutablePointer<Void>( holder.toOpaque() )
    #if os(Linux)
    var pthread: pthread_t = 0
    #else
    var pthread: pthread_t = nil
    #endif
    if pthread_create( &pthread, nil, pthreadRunner, pointer ) == 0 {
        pthread_detach( pthread )
    }
    else {
        print( "pthread_create() error" )
    }
}

public let DISPATCH_TIME_NOW: dispatch_time_t = 0, NSEC_PER_SEC = 1_000_000_000

public func dispatch_time( now: dispatch_time_t, _ nsec: Int64 ) -> dispatch_time_t {
    return nsec
}

public func dispatch_after( delay: dispatch_time_t, _ queue: dispatch_queue_t, _ block: dispatch_block_t ) {
    dispatch_async( queue, {
        sleep( UInt32(Int(delay)/NSEC_PER_SEC) )
        block()
    } )
}

#endif
