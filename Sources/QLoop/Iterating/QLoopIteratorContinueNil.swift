
public final class QLoopIteratorContinueNil: QLoopIterating {

    public init() {
    }

    public func iterate(_ loop: QLoopIterable) {
        guard (loop.discontinue == false) else { return }
        loop.perform()
    }
}
