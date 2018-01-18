//
// RSwift

import Foundation

/** Internal plumbing for Signal */
public class Reactor<T> {
    typealias Listener = (T) -> Void

    internal func notify(_ value: T) {
        // Ideally, we'd simply return inside the if _isDispatching block, but the
        // synchronized clause is a closure; returning from there keeps us inside
        // this function
        var alreadyDispatching: Bool = false

        synchronized(self) {
            if _isDispatching {
                alreadyDispatching = true
                _pendingRuns = Runs.append(_pendingRuns) {
                    self.notify(value)
                }
            } else {
                _isDispatching = true
            }
        }

        if alreadyDispatching {
            return
        }

        var cons = _listeners
        while cons != nil {
            let c = cons!
            if let listener = c.listener {
                listener(value)
            }
            if c.oneShot {
                c.dispose()
            }
            cons = c.next
        }

        synchronized(self) {
            _isDispatching = false
        }

        // perform any operations that were deferred while we were dispatching
        var run: Runs? = nextRun()
        while run != nil {
            run!.action()
            run = nextRun()
        }
    }

    @discardableResult
    internal func addConnection(_ listener: @escaping Listener) -> Cons {
        return addCons(Cons(owner: self, listener: listener))
    }

    @discardableResult
    internal func addCons(_ cons: Cons) -> Cons {
        synchronized(self) {
            if _isDispatching {
                _pendingRuns = Runs.append(_pendingRuns) {
                    self._listeners = Cons.insert(self._listeners, cons)
                }
            } else {
                _listeners = Cons.insert(_listeners, cons)
            }
        }
        return cons
    }

    private func disconnect(_ cons: Cons) {
        synchronized(self) {
            if _isDispatching {
                _pendingRuns = Runs.append(_pendingRuns) {
                    self._listeners = Cons.remove(self._listeners, cons)
                }
            } else {
                _listeners = Cons.remove(_listeners, cons)
            }
        }
    }

    private func nextRun() -> Runs? {
        var run: Runs?
        synchronized(self) {
            run = _pendingRuns
            if run != nil {
                _pendingRuns = run!.next
            }
        }
        return run
    }

    /** A linked list of listeners */
    internal class Cons: Connection {
        public var listener: Listener?
        public var next: Cons?
        public var oneShot: Bool { return _oneShot }

        public init(owner: Reactor<T>, listener: @escaping Listener) {
            _owner = owner
            self.listener = listener
        }

        public func once() -> Connection {
            _oneShot = true
            return self
        }

        public func atPrio(_ priority: Int) -> Connection {
            guard let owner = _owner else {
                return self
            }

            owner.disconnect(self)
            self.next = nil
            _priority = priority
            owner.addCons(self)
            return self
        }

        public func dispose() {
            guard let owner = _owner else {
                return
            }

            owner.disconnect(self)
            self.listener = nil
            _owner = nil
        }

        public static func insert(_ head: Cons?, _ cons: Cons) -> Cons {
            if head == nil {
                return cons
            } else {
                let head = head!
                if cons._priority > head._priority {
                    cons.next = head
                    return cons
                } else {
                    head.next = insert(head.next, cons)
                    return head
                }
            }
        }

        public static func remove(_ head: Cons?, _ cons: Cons) -> Cons? {
            if let head = head {
                if head === cons {
                    return head.next
                } else {
                    head.next = remove(head.next, cons)
                    return head
                }
            } else {
                return nil
            }
        }

        private weak var _owner: Reactor<T>?
        private var _oneShot: Bool = false
        private var _priority: Int = 0
    }

    internal class Runs {
        typealias Action = () -> Void
        let action: Action
        var next: Runs?

        init(_ action: @escaping Action) {
            self.action = action
        }

        static func append(_ head: Runs?, action: @escaping Action) -> Runs {
            if let head = head {
                head.next = append(head.next, action: action)
                return head
            } else {
                return Runs(action)
            }
        }
    }

    private var _listeners: Cons?
    private var _isDispatching: Bool = false
    private var _pendingRuns: Runs?
}
