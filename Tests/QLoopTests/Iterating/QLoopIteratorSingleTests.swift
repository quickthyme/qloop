
import XCTest
import QLoop

class QLoopIteratorSingleTests: XCTestCase {

    func test_iteratorSingle_iterate_shouldNotCallIteration() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorSingle()
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_iteration, 0)
        XCTAssertEqual(mockLoop.timesCalled_iterationFromLastOutput, 0)
    }
}
