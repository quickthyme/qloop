
import QLoop

class MockLoopIterator: QLoopIterating {
    var didCall_iterate: Bool = false
    var valueFor_iterate_loop: QLoopIterable? = nil
    func iterate(_ loop: QLoopIterable) {
        didCall_iterate = true
        valueFor_iterate_loop = loop
    }
}
