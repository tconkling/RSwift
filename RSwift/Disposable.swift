//
// RSwift

import Foundation

/** An object that can be disposed */
public protocol Disposable: class {
    func dispose()
}

/** Manages a set of Disposables that can all be disposed together */
public class DisposableSet: Disposable {
    public init() {
    }
    
    /** Adds a Disposable to the set. Returns that Disposable, for chaining. */
    @discardableResult
    public func add(_ disp: Disposable) -> Disposable {
        _disposables.append(disp)
        return disp
    }

    public func remove(_ disp: Disposable) {
        _disposables = _disposables.filter { $0 !== disp }
    }

    public func clear() {
        for disp: Disposable in _disposables {
            disp.dispose()
        }
        _disposables = []
    }

    public func dispose() {
        clear()
    }

    private var _disposables: [Disposable] = []
}

public class Disposables {
    /**
    Create a Disposable from a function. The function is guaranteed to be called only once,
    even if dispose() is called multiple times.
    */
    public static func create(_ callback: @escaping () -> Void) -> Disposable {
        return CallbackDisposable(callback)
    }

    /** A disposable that just no-ops */
    public static let null: Disposable = NullDisposable()

    private class CallbackDisposable: NSObject, Disposable {
        public init(_ callback: @escaping () -> Void) {
            _callback = callback
        }

        public func dispose() {
            var localCallback: (() -> Void)?
            synchronized(self) {
                localCallback = _callback
                _callback = nil
            }

            if let callback = localCallback {
                callback()
            }
        }

        private var _callback: (() -> Void)?
    }

    private class NullDisposable: Disposable {
        public func dispose() {}
    }
}
