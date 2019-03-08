
import XCTest
import QLoop

class QLoopIteratorSingleTests: XCTestCase {

    func test_iteratorSingle_iterate_shouldNotCallPerform() {
        let mockLoop = MockLoopIterable()
        let subject = QLoopIteratorSingle()
        subject.iterate(mockLoop)

        XCTAssertEqual(mockLoop.timesCalled_perform, 0)
        XCTAssertEqual(mockLoop.timesCalled_performFromLastOutput, 0)
    }
}
