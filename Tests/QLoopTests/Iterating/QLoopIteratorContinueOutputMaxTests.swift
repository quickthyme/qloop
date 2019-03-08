
import XCTest
import QLoop

class QLoopIteratorContinueOutputMaxTests: XCTestCase {

    func test_iterate_max1_should_call_performFromLastOutput_0_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueOutputMax(1)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 0)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 0)
    }

    func test_iterate_max2_should_call_performFromLastOutput_1_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueOutputMax(2)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 0)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 1)
    }

    func test_iterate_max3_should_call_performFromLastOutput_2_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueOutputMax(3)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 0)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 2)
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

        XCTAssertEqual(mockLoop.timesCalled_perform, 0)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 3)
    }
}
