//
// RSwift

import XCTest
@testable import RSwift

class ValueTests: XCTestCase {
    func testSimpleListener() {
        let value: IntValue = IntValue(42)
        var fired: Bool = false
        value.connect { (newValue: Int, oldValue: Int) in
            XCTAssertEqual(42, oldValue)
            XCTAssertEqual(15, newValue)
            fired = true
        }

        value.value = 15
        XCTAssertEqual(15, value.value)
        XCTAssert(fired)
    }

    func testObject() {
        let foo1 = Foo(1)
        let foo2 = Foo(2)
        let value: Value<Foo> = Value<Foo>(foo1)
        let counter = Counter<Foo>()
        value.connect(counter.onEmit)

        value.value = foo1 // values equal - shouldn't trigger
        counter.assertTriggered(count: 0)
        value.value = foo2
        value.value = foo1
        counter.assertTriggered(count: 2)
    }

    func testOptionalObject() {
        let value = Optional<Foo>()
        let counter = Counter<Foo>()
        value.connect(counter.onEmitOptional)
        value.value = nil
        counter.assertTriggered(count: 0)
        value.value = Foo(1)
        value.value = Foo(2)
        value.value = nil
        counter.assertTriggered(count: 3)
    }

    func testAsOnceSignal() {
        let value: IntValue = IntValue(42)
        let counter = Counter<Int>()
        value.connect(counter.onEmit).once()
        value.value = 15
        value.value = 100
        counter.assertTriggered(count: 1)
    }

    func testConnectNotify() {
        let value = IntValue(42)
        var fired: Int = 0
        var expectedValue = value.value
        value.connectNotify { newValue in
            XCTAssertEqual(expectedValue, newValue)
            fired += 1
        }

        expectedValue = 3
        value.value = 3
        XCTAssertEqual(fired, 2)
    }

    func testDisconnect() {
        let value = IntValue(0)
        var fired: Int = 0

        var conn :Disposable? = nil
        conn = value.connect { newValue in
            XCTAssertEqual(newValue, 42)
            fired += 1
            conn?.dispose()
        }

        value.value = 42
        value.value = 3
        XCTAssertEqual(1, fired)
    }
}

class Foo {
    public let value: Int
    public init(_ value: Int) {
        self.value = value
    }
}

class Counter<T> {
    func trigger() {
        _count += 1
    }

    func assertTriggered(count: Int, message: String = "") {
        XCTAssertEqual(count, _count, message)
    }

    func reset() {
        _count = 0
    }

    func onEmit(value: T) {
        trigger()
    }

    func onEmitOptional(value: T?) {
        trigger()
    }
    
    private var _count: Int = 0
}
