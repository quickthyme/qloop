
public final class QLoopLinearSegment<Input, Output>: QLoopSegment<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias Completion = QLoopSegment<Input, Output>.Completion

    public override var inputAnchor: QLoopAnchor<Input> {
        didSet { applyInputObservers() }
    }

    public override weak var outputAnchor: QLoopAnchor<Output>? {
        didSet {
            self.outputAnchor?.backwardOwner = self
            applyInputObservers()
        }
    }

    public let operationId: AnyHashable

    public convenience init(_ operationId: AnyHashable,
                            _ operation: @escaping Operation) {
        self.init(operationId, operation, QLoopAnchor<Output>())
    }

    public convenience init<Unknown>(_ operationId: AnyHashable,
                                     _ operation: @escaping Operation,
                                     _ output: QLoopSegment<Output, Unknown>) {
        self.init(operationId, operation, output.inputAnchor)
    }

    public required init(_ operationId: AnyHashable,
                         _ operation: @escaping Operation,
                         _ outputAnchor: QLoopAnchor<Output>) {
        self.operationId = operationId
        super.init()
        self.operation = operation
        self.outputAnchor = outputAnchor
        self.inputAnchor = QLoopAnchor<Input>()
    }

    private final func applyInputObservers() {
        guard let outAnchor = self.outputAnchor else { return }

        self.inputAnchor.onChange = ({ input in
            do {
                try self.operation(input, { outAnchor.input = $0 })
            } catch {
                outAnchor.error = error
            }
        })

        self.inputAnchor.onError = ({ error in
            outAnchor.error = error
        })
    }
}
