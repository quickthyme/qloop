
public final class QLoopIteratorContinueOutput: QLoopIterating {

    public init() {
    }

    public func reset() { /**/ }

    @discardableResult
    public func iterate(_ loop: QLoopIterable) -> Bool {
        guard (loop.discontinue == false) else { return false }
        loop.iterationFromLastOutput()
        return true
    }
}
