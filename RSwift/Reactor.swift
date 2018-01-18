//
// RSwift

import Foundation

/** Internal plumbing for Signals and Values */
public class Reactor<T, U> {
    internal func notify(_ a1: T?, _ a2: U?) {
        // Ideally, we'd simply return inside the if _isDispatching block, but the
        // synchronized clause is a closure; returning from there keeps us inside
        // this function
        var alreadyDispatching: Bool = false

        synchronized(self) {
            if _isDispatching {
                alreadyDispatching = true
                _pendingRuns = Runs.append(_pendingRuns) {
                    self.notify(a1, a2)
                }
            } else {
                _isDispatching = true
            }
        }

        if alreadyDispatching {
            return
        }

        var cons = _notifiers
        while cons != nil {
            let c = cons!
            if let notifier = c.notifier {
                notifier.notify(a1, a2)
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
    internal func addConnection(_ notifier: Notifier) -> Cons {
        return addCons(Cons(owner: self, notifier: notifier))
    }

    @discardableResult
    internal func addCons(_ cons: Cons) -> Cons {
        synchronized(self) {
            if _isDispatching {
                _pendingRuns = Runs.append(_pendingRuns) {
                    self._notifiers = Cons.insert(self._notifiers, cons)
                }
            } else {
                _notifiers = Cons.insert(_notifiers, cons)
            }
        }
        return cons
    }

    private func disconnect(_ cons: Cons) {
        synchronized(self) {
            if _isDispatching {
                _pendingRuns = Runs.append(_pendingRuns) {
                    self._notifiers = Cons.remove(self._notifiers, cons)
                }
            } else {
                _notifiers = Cons.remove(_notifiers, cons)
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
        public var notifier: Notifier?
        public var next: Cons?
        public var oneShot: Bool { return _oneShot }

        public init(owner: Reactor<T, U>, notifier: Notifier) {
            _owner = owner
            self.notifier = notifier
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
            self.notifier = nil
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

        private weak var _owner: Reactor<T, U>?
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

    private var _notifiers: Cons?
    private var _isDispatching: Bool = false
    private var _pendingRuns: Runs?
}

internal protocol Notifier {
    func notify(_ a1: Any?, _ a2: Any?)
}
