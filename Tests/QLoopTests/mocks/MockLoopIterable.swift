
import QLoop

class MockLoopIterable: QLoopIterable {

    var discontinue: Bool = false

    var timesCalled_perform: Int = 0
    var timesCalled_performFromLastOutput: Int = 0

    func perform() {
        timesCalled_perform += 1
    }

    func performFromLastOutput() {
        timesCalled_performFromLastOutput += 1
    }
}
