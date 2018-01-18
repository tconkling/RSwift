//
// RSwift

import Foundation

import Foundation

internal func synchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try body()
}

internal func synchronized(_ lock: AnyObject, _ body: () throws -> Void) rethrows {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    try body()
}
