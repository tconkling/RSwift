//
// RSwift

import Foundation

/** A connection to a Signal. Dispose the connection to stop getting events. */
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

/** A stream of typed events */
public class Signal<T>: Reactor<T> {
    public typealias Listener = (T) -> Void

    public override init() {
    }

    @discardableResult
    public func connect(_ listener: @escaping Listener) -> Connection {
        return addConnection(listener)
    }

    public func emit(_ event: T) {
        notify(event)
    }
}

/** Convenience class for Signal<Void> */
public class UnitSignal: Signal<Void> {
    public func emit() {
        emit(())
    }
}
