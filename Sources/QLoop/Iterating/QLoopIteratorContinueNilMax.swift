
public final class QLoopIteratorContinueNilMax: QLoopIterating {

    public var iterations: Int = 0
    public var maxIterations: Int

    public init(_ maxIterations: Int) {
        self.maxIterations = maxIterations
    }

    public func reset() {
        iterations = 0
    }

    @discardableResult
    public func iterate(_ loop: QLoopIterable) -> Bool {
        guard (loop.discontinue == false) else { return false }
        iterations += 1
        if (iterations < maxIterations) {
            loop.iteration()
            return true
        } else {
            return false
        }
    }
}
