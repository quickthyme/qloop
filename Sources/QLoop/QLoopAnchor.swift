
public protocol AnyLoopAnchor: class {
    var inputSegment: AnyLoopSegment? { get }
}

public final class QLoopAnchor<Input>: AnyLoopAnchor {
    public typealias OnChange = (Input?)->()
    public typealias OnError = (Error)->()

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

    public var input: Input? {
        didSet { onChange(input) }
    }

    public var error: Error? {
        didSet { if let err = error { onError(err) } }
    }

    public var onChange: OnChange
    public var onError: OnError

    public var inputSegment: AnyLoopSegment?
}
