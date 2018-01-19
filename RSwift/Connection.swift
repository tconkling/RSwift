//
// RSwift

import Foundation

/** A connection to a reactive value. Dispose the connection to stop getting events. */
public protocol Connection: Disposable {
    /** Causes the Connection to be a one-shot deal that will close itself after the first emission */
    @discardableResult
    func once() -> Connection

    /**
    Changes the priority of the connection to the specified value.
    Connections are notified from highest priority to lowest priority. The default
    priority is 0.
    */
    @discardableResult
    func atPrio(_ priority: Int) -> Connection
}
