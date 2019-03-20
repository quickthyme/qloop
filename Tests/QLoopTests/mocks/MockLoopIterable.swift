
import QLoop

class MockLoopIterable: QLoopIterable {

    var discontinue: Bool = false

    var timesCalled_iteration: Int = 0
    var timesCalled_iterationFromLastOutput: Int = 0

    func iteration() {
        timesCalled_iteration += 1
    }

    func iterationFromLastOutput() {
        timesCalled_iterationFromLastOutput += 1
    }
}
