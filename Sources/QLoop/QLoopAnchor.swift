
public protocol AnyLoopAnchor: class {
    var backwardOwner: AnyLoopSegment? { get }
}

public final class QLoopAnchor<Input>: AnyLoopAnchor {
    public typealias OnChange = (Input?)->()
    public typealias OnError = (Error)->()
    private struct NotAnError: Error { }

    public var input: Input? {
        didSet { onChange(input) }
    }

    public var error: Error = NotAnError() {
        didSet {
            if !(error is NotAnError) { onError(error) } }
    }

    public var onChange: OnChange
    public var onError: OnError

    public var backwardOwner: AnyLoopSegment?

    public convenience init() {
        self.init(onChange: {_ in }, onError: {_ in })
    }

    public convenience init(onChange: @escaping OnChange) {
        self.init(onChange: onChange, onError: {_ in })
    }

    public required init(onChange: @escaping OnChange,
                         onError: @escaping OnError) {
        self.onChange = onChange
        self.onError = onError
    }
}
