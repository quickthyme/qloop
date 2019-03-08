
import XCTest
import QLoop

class QLoopIteratorContinueOutputTests: XCTestCase {

    func test_iterate_1_times_should_call_performFromLastOutput_1_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueOutput()
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 0)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 1)
    }

    func test_iterate_2_times_should_call_performFromLastOutput_2_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueOutput()
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 0)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 2)
    }

    func test_iterate_3_times_should_call_performFromLastOutput_3_times() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueOutput()
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 0)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 3)
    }

    func test_when_discontinue_becomes_true_then_it_should_stop() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorContinueOutput()
        subject.iterate(mockLoop)
        subject.iterate(mockLoop)
        mockLoop.discontinue = true
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 0)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 2)
    }
}
