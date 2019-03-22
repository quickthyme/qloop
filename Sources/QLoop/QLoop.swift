
public final class QLoop<Input, Output>: QLoopIterable {
    public typealias Operation = QLSegment<Input, Output>.Operation
    public typealias Completion = QLSegment<Input, Output>.Completion
    public typealias OnChange = QLAnchor<Output>.OnChange
    public typealias OnError = QLAnchor<Output>.OnError

    public required init(iterator: QLoopIterating,
                         onFinal: @escaping OnChange,
                         onChange: @escaping OnChange,
                         onError: @escaping OnError) {
        self.iterator = iterator
        self.onFinal = onFinal
        self.onChange = onChange
        self.onError = onError
        self.applyOutputObservers()
    }

    public var input: QLAnchor<Input> = QLAnchor<Input>()
    public var output: QLAnchor<Output> = QLAnchor<Output>() {
        didSet { applyOutputObservers() }
    }

    private var lastValue: Output? = nil

    public func perform() {
        self.perform(nil)
    }

    public func perform(_ inputValue: Input?) {
        self.iterator.reset()
        self.input.value = inputValue
    }

    public func iteration() {
        self.input.value = nil
    }

    public func iterationFromLastOutput() {
        self.input.value = (self.lastValue as? Input)
    }

    public var discontinue: Bool = false
    public var shouldResume: Bool = false

    public var onFinal: OnChange
    public var onChange: OnChange
    public var onError: OnError

    public var iterator: QLoopIterating

    public func bind(path: QLPath<Input, Output>) {
        self.input = path.input
        self.output = path.output
    }

    public func bind(segment: QLSegment<Input, Output>) {
        segment.output = self.output
        self.input = segment.input
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
            self.lastValue = $0
            self.onChange($0)
            if (self.iterator.iterate(self) == false) {
                self.onFinal($0)
            }
        })

        self.output.onError = ({
            self.onError($0)
            self.discontinue = !self.shouldResume
            let _ = self.iterator.iterate(self)
        })
    }
}
