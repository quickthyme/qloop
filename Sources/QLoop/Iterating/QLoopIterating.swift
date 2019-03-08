
public protocol QLoopIterating: class {
    func iterate(_ loop: QLoopIterable)
}

public protocol QLoopIterable {
    var discontinue: Bool { get }
    func perform()
    func performFromLastOutput()
}
