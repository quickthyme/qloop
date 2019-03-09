
public final class QLoopLinearSegment<Input, Output>: QLoopSegment<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias Completion = QLoopSegment<Input, Output>.Completion

    public override var inputAnchor: QLoopAnchor<Input> {
        didSet { applyInputObservers() }
    }

    public override var outputAnchor: QLoopAnchor<Output> {
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

    private final func applyInputObservers() {
        self.inputAnchor.onChange = ({ input in
            do {
                try self.operation(input, { self.outputAnchor.input = $0 })
            } catch {
                self.outputAnchor.error = error
            }
        })

        self.inputAnchor.onError = ({ error in
            self.outputAnchor.error = error
        })
    }
}
