
public final class QLoopIteratorContinueNil: QLoopIterating {

    public init() {
    }

    public func reset() { /**/ }

    @discardableResult
    public func iterate(_ loop: QLoopIterable) -> Bool {
        guard (loop.discontinue == false) else { return false }
        loop.iteration()
        return true
    }
}
