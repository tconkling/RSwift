//
// RSwift

import Foundation

/** A stream of typed events */
public class Signal<T>: Reactor<T, Void> {
    public typealias Listener = (T) -> Void

    public override init() {
    }

    @discardableResult
    public func connect(_ listener: @escaping Listener) -> Connection {
        return addConnection(NotifierImpl<T>(listener))
    }

    public func emit(_ event: T) {
        notify(event, nil)
    }

    private class NotifierImpl<T>: Notifier {
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
        return addConnection(NotifierImpl(listener))
    }

    public func emit() {
        notify(nil, nil)
    }

    private class NotifierImpl: Notifier {
        public let listener: UnitSignal.Listener

        public init(_ listener: @escaping UnitSignal.Listener) {
            self.listener = listener
        }

        public func notify(_ a1: Any?, _ a2: Any?) {
            listener()
        }
    }
}
