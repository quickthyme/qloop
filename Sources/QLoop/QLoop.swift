
public final class QLoop<Input, Output>: QLoopIterable {
    public typealias Operation = QLSegment<Input, Output>.Operation
    public typealias Completion = QLSegment<Input, Output>.Completion
    public typealias OnChange = QLAnchor<Output>.OnChange
    public typealias OnError = QLAnchor<Output>.OnError

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

    public var input: QLAnchor<Input> = QLAnchor<Input>()
    public var output: QLAnchor<Output> = QLAnchor<Output>() {
        didSet { applyOutputObservers() }
    }

    public func perform() {
        input.value = nil
    }

    public func perform(_ inputValue: Input?) {
        self.input.value = inputValue
    }

    public func performFromLastOutput() {
        self.perform(self.output.value as? Input)
    }

    public var discontinue: Bool = false
    public var shouldResume: Bool = false

    public var onChange: OnChange
    public var onError: OnError

    public var iterator: QLoopIterating

    public func bind(path: QLPath<Input, Output>) {
        self.input = path.input
        self.output = path.output
    }

    public func destroy() {
        self.input = QLAnchor<Input>()
        self.output = QLAnchor<Output>()
    }

    public func findSegments(with operationId: AnyHashable) -> [AnySegment] {
        return output.inputSegment?.findSegments(with: operationId) ?? []
    }

    public func describeOperationPath() -> String {
        return output.inputSegment?.describeOperationPath() ?? ""
    }

    public func operationPath() -> [([AnyHashable], Bool)] {
        return output.inputSegment?.operationPath() ?? []
    }

    private func applyOutputObservers() {
        self.output.onChange = ({
            self.onChange($0)
            self.iterator.iterate(self)
        })

        self.output.onError = ({
            self.onError($0)
            self.discontinue = !self.shouldResume
            self.iterator.iterate(self)
        })
    }
}
