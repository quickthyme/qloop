
public final class QLoopIteratorContinueNilMax: QLoopIterating {

    public var iterations: Int = 0
    public var maxIterations: Int

    public init(_ maxIterations: Int) {
        self.maxIterations = maxIterations
    }

    public func iterate(_ loop: QLoopIterable) {
        guard (loop.discontinue == false) else { return }
        iterations += 1
        if (iterations < maxIterations) { loop.perform() }
    }
}
