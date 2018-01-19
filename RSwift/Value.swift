//
// RSwift

import Foundation

public class ValueView<T>: Reactor<T, T> {
    /// Listener receives the old value and new value
    public typealias Listener = (T, T) -> Void

    /// The concrete value that we currently store
    public var value: T { fatalError("Subclasses must implement") }

    /**
     * Connects the supplied listener to this value, such that it will be notified when this value
     * changes. The listener is held by a strong reference, so it's held in memory by virtue of
     * being connected.
     * @return a connection instance which can be used to cancel the connection.
     */
    @discardableResult
    public func connect(_ listener: @escaping Listener) -> Connection {
        return addConnection(NotifierImpl<T>(listener))
    }

    @discardableResult
    public func connect(_ listener: @escaping (T) -> Void) -> Connection {
        return connect { newValue, _ in
            listener(newValue)
        }
    }

    @discardableResult
    public func connect(_ listener: @escaping () -> Void) -> Connection {
        return connect { _, _ in
            listener()
        }
    }

    /**
     * Connects the supplied listener to this value, such that it will be notified when this value
     * changes. Also immediately notifies the listener of the current value. Note that the previous
     * value supplied with this notification will be the same as its current value.
     * @return a connection instance which can be used to cancel the connection.
     */
    @discardableResult
    public func connectNotify(_ listener: @escaping Listener) -> Connection {
        let conn: Connection = connect(listener)
        listener(self.value, self.value)
        return conn
    }

    @discardableResult
    public func connectNotify(_ listener: @escaping (T) -> Void) -> Connection {
        return connectNotify { newValue, _ in
            listener(newValue)
        }
    }

    @discardableResult
    public func connectNotify(_ listener: @escaping () -> Void) -> Connection {
        return connectNotify { _, _ in
            listener()
        }
    }

    private class NotifierImpl<T>: Notifier {
        public let listener: ValueView<T>.Listener

        public init(_ listener: @escaping ValueView<T>.Listener) {
            self.listener = listener
        }

        public func notify(_ a1: Any?, _ a2: Any?) {
            listener(a1 as! T, a2 as! T)
        }
    }
}

/// A reactive value that stores primitives
public class PrimitiveValue<T: Equatable>: ValueView<T> {
    public init(_ value: T) {
        _value = value
    }

    override public var value: T {
        get { return _value }
        set {
            if newValue != _value {
                let oldValue = _value
                _value = newValue
                notify(newValue, oldValue)
            }
        }
    }

    private var _value: T
}

// A reactive value that stores objects
public class Value<T: AnyObject>: ValueView<T> {
    public init(_ value: T) {
        _value = value
    }

    override public var value: T {
        get { return _value }
        set {
            if newValue !== _value {
                let oldValue = _value
                _value = newValue
                notify(newValue, oldValue)
            }
        }
    }

    private var _value: T
}

/// Equivalent to ValueView, but with support for optional values
public class OptionalView<T>: Reactor<T, T> {
    /// Listener receives the old value and new value
    public typealias Listener = (T?, T?) -> Void

    /// The concrete value that we currently store
    public var value: T? { fatalError("Subclasses must implement") }

    /**
     * Connects the supplied listener to this value, such that it will be notified when this value
     * changes. The listener is held by a strong reference, so it's held in memory by virtue of
     * being connected.
     * @return a connection instance which can be used to cancel the connection.
     */
    @discardableResult
    public func connect(_ listener: @escaping Listener) -> Connection {
        return addConnection(NotifierImpl<T>(listener))
    }

    @discardableResult
    public func connect(_ listener: @escaping (T?) -> Void) -> Connection {
        return connect { newValue, _ in
            listener(newValue)
        }
    }

    @discardableResult
    public func connect(_ listener: @escaping () -> Void) -> Connection {
        return connect { _, _ in
            listener()
        }
    }

    /**
     * Connects the supplied listener to this value, such that it will be notified when this value
     * changes. Also immediately notifies the listener of the current value. Note that the previous
     * value supplied with this notification will be the same as its current value.
     * @return a connection instance which can be used to cancel the connection.
     */
    @discardableResult
    public func connectNotify(_ listener: @escaping Listener) -> Connection {
        let conn: Connection = connect(listener)
        listener(self.value, self.value)
        return conn
    }

    @discardableResult
    public func connectNotify(_ listener: @escaping (T?) -> Void) -> Connection {
        return connectNotify { newValue, _ in
            listener(newValue)
        }
    }

    @discardableResult
    public func connectNotify(_ listener: @escaping () -> Void) -> Connection {
        return connectNotify { _, _ in
            listener()
        }
    }

    private class NotifierImpl<T>: Notifier {
        public let listener: OptionalView<T>.Listener

        public init(_ listener: @escaping OptionalView<T>.Listener) {
            self.listener = listener
        }

        public func notify(_ a1: Any?, _ a2: Any?) {
            listener(a1 as? T, a2 as? T)
        }
    }
}

public class Optional<T: AnyObject>: OptionalView<T> {
    public init(_ value: T? = nil) {
        _value = value
    }

    override public var value: T? {
        get { return _value }
        set {
            if newValue !== _value {
                let oldValue = _value
                _value = newValue
                notify(newValue, oldValue)
            }
        }
    }

    private var _value: T?
}

public typealias IntValue = PrimitiveValue<Int>
public typealias FloatValue = PrimitiveValue<Float>
public typealias DoubleValue = PrimitiveValue<Double>
public typealias BoolValue = PrimitiveValue<Bool>
