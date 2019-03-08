
public final class QLoopIteratorContinueOutput: QLoopIterating {

    public init() {
    }

    public func iterate(_ loop: QLoopIterable) {
        guard (loop.discontinue == false) else { return }
        loop.performFromLastOutput()
    }
}
