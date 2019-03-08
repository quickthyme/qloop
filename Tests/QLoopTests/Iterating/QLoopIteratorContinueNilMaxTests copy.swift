
import XCTest
import QLoop

class QLoopIteratorContinueNilMaxTests: XCTestCase {

    func test_iterate_max1_shouldCallPerform_0_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueNilMax(1)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 0)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 0)
    }

    func test_iterate_max2_shouldCallPerform_1_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueNilMax(2)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 1)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 0)
    }

    func test_iterate_max3_shouldCallPerform_2_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueNilMax(3)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 2)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 0)
    }

    func test_when_discontinue_becomes_true_then_it_should_stop() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueNilMax(6)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        mockLoop.discontinue = true
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 3)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 0)
    }
}
