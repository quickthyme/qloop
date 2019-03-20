
import XCTest
import QLoop

class QLoopIteratorContinueOutputMaxTests: XCTestCase {

    func test_iterate_max1_should_call_iterationFromLastOutput_0_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueOutputMax(1)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_iteration, 0)
        XCTAssertEqual(mockLoop.timesCalled_iterationFromLastOutput, 0)
    }

    func test_iterate_max2_should_call_iterationFromLastOutput_1_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueOutputMax(2)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_iteration, 0)
        XCTAssertEqual(mockLoop.timesCalled_iterationFromLastOutput, 1)
    }

    func test_iterate_max3_should_call_iterationFromLastOutput_2_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueOutputMax(3)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_iteration, 0)
        XCTAssertEqual(mockLoop.timesCalled_iterationFromLastOutput, 2)
    }

    func test_when_discontinue_becomes_true_then_it_should_stop() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueOutputMax(6)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        mockLoop.discontinue = true
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_iteration, 0)
        XCTAssertEqual(mockLoop.timesCalled_iterationFromLastOutput, 3)
    }
}
