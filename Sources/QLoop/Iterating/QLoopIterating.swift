
public protocol QLoopIterating: class {
    @discardableResult
    func iterate(_ loop: QLoopIterable) -> Bool
    func reset()
}

public protocol QLoopIterable {
    var discontinue: Bool { get }
    func iteration()
    func iterationFromLastOutput()
}
