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
public class Signal<T>: Reactor<T, Void> {
    public typealias Listener = (T) -> Void

    public override init() {
    }

    @discardableResult
    public func connect(_ listener: @escaping Listener) -> Connection {
        return addConnection(SignalNotifier<T>(listener))
    }

    public func emit(_ event: T) {
        notify(event, nil)
    }

    private class SignalNotifier<T>: Notifier {
        public let listener: Signal<T>.Listener

        public init(_ listener: @escaping Signal<T>.Listener) {
            self.listener = listener
        }

        public func notify(_ a1: Any?, _ a2: Any?) {
            listener(a1 as! T)
        }
    }
}

/** A signal without any data  */
public class UnitSignal: Reactor<Void, Void> {
    public typealias Listener = () -> Void

    public override init() {
    }

    @discardableResult
    public func connect(_ listener: @escaping Listener) -> Connection {
        return addConnection(UnitSignalNotifier(listener))
    }

    public func emit() {
        notify(nil, nil)
    }

    private class UnitSignalNotifier: Notifier {
        public let listener: UnitSignal.Listener

        public init(_ listener: @escaping UnitSignal.Listener) {
            self.listener = listener
        }

        public func notify(_ a1: Any?, _ a2: Any?) {
            listener()
        }
    }
}
