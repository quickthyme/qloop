
import XCTest
import QLoop

class QLoopIteratorContinueNilTests: XCTestCase {

    func test_iterate_1_times_shouldCallPerform_1_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueNil()
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_iteration, 1)
        XCTAssertEqual(mockLoop.timesCalled_iterationFromLastOutput, 0)
    }

    func test_iterate_2_times_shouldCallPerform_2_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueNil()
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_iteration, 2)
        XCTAssertEqual(mockLoop.timesCalled_iterationFromLastOutput, 0)
    }

    func test_iterate_3_times_shouldCallPerform_3_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueNil()
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_iteration, 3)
        XCTAssertEqual(mockLoop.timesCalled_iterationFromLastOutput, 0)
    }

    func test_when_discontinue_becomes_true_then_it_should_stop() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueNil()
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        mockLoop.discontinue = true
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_iteration, 2)
        XCTAssertEqual(mockLoop.timesCalled_iterationFromLastOutput, 0)
    }
}
