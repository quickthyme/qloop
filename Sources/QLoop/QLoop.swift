
public final class QLoop<Input, Output>: QLoopIterable {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias Completion = QLoopSegment<Input, Output>.Completion
    public typealias OnChange = QLoopAnchor<Output>.OnChange
    public typealias OnError = QLoopAnchor<Output>.OnError

    public var inputAnchor: QLoopAnchor<Input> = QLoopAnchor<Input>()
    public var outputAnchor: QLoopAnchor<Output> = QLoopAnchor<Output>() {
        didSet { applyOutputObservers() }
    }

    public func perform() {
        inputAnchor.input = nil
    }

    public func perform(_ input: Input?) {
        inputAnchor.input = input
    }

    public func performFromLastOutput() {
        self.perform(self.outputAnchor.input as? Input)
    }

    public var discontinue: Bool = false
    public var shouldResume: Bool = false

    public var onChange: OnChange
    public var onError: OnError

    public var iterator: QLoopIterating

    public func bind(path: QLoopPath<Input, Output>) {
        self.inputAnchor = path.inputAnchor
        self.outputAnchor = path.outputAnchor
    }

    public func findSegments(with operationId: AnyHashable) -> [AnyLoopSegment] {
        return outputAnchor.backwardOwner?.findSegments(with: operationId) ?? []
    }

    public func describeOperationPath() -> String {
        return outputAnchor.backwardOwner?.describeOperationPath() ?? ""
    }

    public func operationPath() -> [[AnyHashable]] {
        return outputAnchor.backwardOwner?.operationPath() ?? []
    }

    public convenience init() {
        self.init(iterator: QLoopIteratorSingle(), onChange: {_ in}, onError: {_ in})
    }

    public convenience init(onChange: @escaping (Output?)->()) {
        self.init(iterator: QLoopIteratorSingle(), onChange: onChange, onError: {_ in})
    }

    public convenience init(iterator: QLoopIterating,
                            onChange: @escaping OnChange) {
        self.init(iterator: iterator, onChange: onChange, onError: {_ in})
    }

    public required init(iterator: QLoopIterating,
                         onChange: @escaping OnChange,
                         onError: @escaping OnError) {
        self.iterator = iterator
        self.onChange = onChange
        self.onError = onError
        self.applyOutputObservers()
    }

    private final func applyOutputObservers() {
        self.outputAnchor.onChange = ({
            self.onChange($0)
            self.iterator.iterate(self)
        })

        self.outputAnchor.onError = ({
            self.onError($0)
            self.discontinue = !self.shouldResume
            self.iterator.iterate(self)
        })
    }
}
