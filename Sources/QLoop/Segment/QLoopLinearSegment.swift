
public final class QLoopLinearSegment<Input, Output>: QLoopSegment<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias Completion = QLoopSegment<Input, Output>.Completion

    override public var inputAnchor: QLoopAnchor<Input> {
        didSet { applyInputObservers() }
    }

    override public var outputAnchor: QLoopAnchor<Output> {
        didSet { applyInputObservers() }
    }

    public convenience init(_ operation: @escaping Operation) {
        self.init(operation, QLoopAnchor<Output>())
    }

    public convenience init<Unknown>(_ operation: @escaping Operation,
                                     _ output: QLoopSegment<Output, Unknown>) {
        self.init(operation, output.inputAnchor)
    }

    public required init(_ operation: @escaping Operation,
                         _ outputAnchor: QLoopAnchor<Output>) {
        super.init()
        self.operation = operation
        self.outputAnchor = outputAnchor
        self.inputAnchor = QLoopAnchor<Input>()
    }

    private func applyInputObservers() {
        self.inputAnchor.onChange = QLoopLinearSegment<Input, Output>.onInputChange(self)
        self.inputAnchor.onError = QLoopLinearSegment<Input, Output>.onInputError(self)
    }

    private static func onInputChange(_ segment: QLoopLinearSegment<Input, Output>) -> QLoopAnchor<Input>.OnChange {
        return ({ input in
            do {
                try segment.operation(input, { output in segment.outputAnchor.input = output })
            } catch {
                segment.outputAnchor.error = error
            }
        })
    }

    private static func onInputError(_ segment: QLoopLinearSegment<Input, Output>) -> QLoopAnchor<Input>.OnError {
        return ({ error in
            segment.outputAnchor.error = error
        })
    }
}
