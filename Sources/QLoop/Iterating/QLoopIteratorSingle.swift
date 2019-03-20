
public final class QLoopIteratorSingle: QLoopIterating {

    public init() {
    }

    public func reset() { /**/ }

    @discardableResult
    public func iterate(_ loop: QLoopIterable) -> Bool {
        return false
    }
}
