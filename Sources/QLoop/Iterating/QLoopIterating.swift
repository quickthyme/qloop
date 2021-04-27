public protocol QLoopIterating: AnyObject {
    @discardableResult
    func iterate(_ loop: QLoopIterable) -> Bool
}

public protocol QLoopIteratingResettable: QLoopIterating {
    func reset()
}

public protocol QLoopIterable {
    var discontinue: Bool { get }
    func iteration()
    func iterationFromLastOutput()
}
