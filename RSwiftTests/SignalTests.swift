//
//  SignalTests.swift
//  RSwiftTests
//
//  Created by Tim Conkling on 1/18/18.
//  Copyright © 2018 Tim Conkling. All rights reserved.
//

import XCTest
@testable import RSwift

class SignalTests: XCTestCase {
    func testSignalToSlot() {
        let signal = Signal<Int>()
        let slot = AccSlot<Int>()
        signal.connect(slot.onEmit)
        signal.emit(1)
        signal.emit(2)
        signal.emit(3)

        XCTAssertEqual([1, 2, 3], slot.events)
    }

    func testOneShotSlot() {
        let signal = Signal<Int>()
        let slot = AccSlot<Int>()
        signal.connect(slot.onEmit).once()
        signal.emit(1) // slot should be removed after this emit
        signal.emit(2)
        signal.emit(3)

        XCTAssertEqual([1], slot.events)
    }

    func testSlotPriority() {
        let counter = Boxed<Int>(0)
        let slot1 = PriorityTestSlot(counter)
        let slot2 = PriorityTestSlot(counter)
        let slot3 = PriorityTestSlot(counter)
        let slot4 = PriorityTestSlot(counter)

        let signal = UnitSignal()
        signal.connect(slot3.onEmit).atPrio(3)
        signal.connect(slot1.onEmit).atPrio(1)
        signal.connect(slot2.onEmit).atPrio(2)
        signal.connect(slot4.onEmit).atPrio(4)
        signal.emit()

        // Slots will be called in the inverse of their priorities (higher priorities are called first)
        XCTAssertEqual(4, slot1.order)
        XCTAssertEqual(3, slot2.order)
        XCTAssertEqual(2, slot3.order)
        XCTAssertEqual(1, slot4.order)
    }

    func testAddDuringDispatch() {
        let signal = Signal<Int>()
        let toAdd = AccSlot<Int>()

        signal.connect { (_: Int) in
            signal.connect(toAdd.onEmit)
        }.once()

        // This will connect to our new signal, but not dispatch to it
        signal.emit(5)
        XCTAssertEqual(0, toAdd.events.count)

        // This will dispatch to our new signal
        signal.emit(42)
        XCTAssertEqual([42], toAdd.events)
    }

    func testRemoveDuringDispatch() {
        let signal = Signal<Int>()
        let toRemove = AccSlot<Int>()
        let rconn: Connection = signal.connect(toRemove.onEmit)

        // dispatch one event and make sure it's received
        signal.emit(5)
        XCTAssertEqual([5], toRemove.events)

        // now add our removing signal, and dispatch again
        signal.connect { _ in
            rconn.dispose()
        }.atPrio(1) // ensure that we're dispatched before toRemove.emit
        signal.emit(42)

        // toRemove will have been removed during the previous dispatch, so it should not have received the signal
        XCTAssertEqual([5], toRemove.events)
    }

    func testAddAndRemoveDuringDispatch() {
        let signal = Signal<Int>()
        let toAdd = AccSlot<Int>()
        let toRemove = AccSlot<Int>()
        let rconn = signal.connect(toRemove.onEmit)

        // dispatch one event and make sure it's received by toRemove
        signal.emit(5)
        XCTAssertEqual([5], toRemove.events)

        // now add our adder/remover signal and dispatch again
        signal.connect { _ in
            rconn.dispose()
            signal.connect(toAdd.onEmit)
        }
        signal.emit(42)

        // make sure toRemove got this event and toAdd didn't
        XCTAssertEqual([5, 42], toRemove.events)
        XCTAssertEqual(0, toAdd.events.count)

        // finally, emit once more and ensure that toAdd got it and toRemove didn't
        signal.emit(9)
        XCTAssertEqual([9], toAdd.events)
        XCTAssertEqual([5, 42], toRemove.events)
    }

    func testUnitSlot() {
        let signal = Signal<Int>()
        var fired: Bool = false
        signal.connect { _ in fired = true }
        signal.emit(42)
        XCTAssert(fired)
    }
}

fileprivate enum TestError: Error {
    case test
}

fileprivate class AccSlot<T> {
    public var events: [T] = []
    public func onEmit(event: T) {
        events.append(event)
    }
}

fileprivate class Boxed<T: Numeric> {
    public var value: T
    public init(_ value: T = 0) {
        self.value = value
    }
}

fileprivate class PriorityTestSlot {
    public var order: Int = 0
    public let counter: Boxed<Int>

    public init(_ counter: Boxed<Int>) {
        self.counter = counter
    }

    public func onEmit() {
        self.counter.value += 1
        self.order = self.counter.value
    }
}
