
import QLoop

class MockLoopIterator: QLoopIterating {

    var didCall_reset: Bool = false
    func reset() {
        didCall_reset = true
    }

    var didCall_iterate: Bool = false
    var valueFor_iterate_loop: QLoopIterable? = nil
    var shouldIterate: Bool = true
    func iterate(_ loop: QLoopIterable) -> Bool {
        didCall_iterate = true
        valueFor_iterate_loop = loop
        return shouldIterate
    }
}
