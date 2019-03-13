
public final class QLoopLinearSegment<Input, Output>: QLoopSegment<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias ErrorHandler = QLoopSegment<Input, Output>.ErrorHandler
    public typealias Completion = QLoopSegment<Input, Output>.Completion
    public typealias ErrorCompletion = QLoopSegment<Input, Output>.ErrorCompletion

    public convenience init(_ operationId: AnyHashable,
                            _ operation: @escaping Operation) {
        self.init(operationId, operation, errorHandler: nil, outputAnchor: QLoopAnchor<Output>())
    }

    public convenience init(_ operationId: AnyHashable,
                            _ operation: @escaping Operation,
                            errorHandler: ErrorHandler?) {
        self.init(operationId, operation, errorHandler: errorHandler, outputAnchor: QLoopAnchor<Output>())
    }

    public convenience init<Unknown>(_ operationId: AnyHashable,
                                     _ operation: @escaping Operation,
                                     output: QLoopSegment<Output, Unknown>) {
        self.init(operationId, operation, errorHandler: nil, outputAnchor: output.inputAnchor)
    }

    public convenience init(_ operationId: AnyHashable,
                            _ operation: @escaping Operation,
                            outputAnchor: QLoopAnchor<Output>) {
        self.init(operationId, operation, errorHandler: nil, outputAnchor: outputAnchor)
    }

    public convenience init<Unknown>(_ operationId: AnyHashable,
                                     _ operation: @escaping Operation,
                                     errorHandler: ErrorHandler?,
                                     output: QLoopSegment<Output, Unknown>) {
        self.init(operationId, operation, errorHandler: errorHandler, outputAnchor: output.inputAnchor)
    }

    public convenience init(_ operationId: AnyHashable,
                            _ operation: @escaping Operation,
                            errorHandler: ErrorHandler?,
                            outputAnchor: QLoopAnchor<Output>) {
        self.init(operationId: operationId, operation: operation,
                  errorHandler: errorHandler, outputAnchor: outputAnchor)
    }

    public required init(operationId: AnyHashable,
                         operation: @escaping Operation,
                         errorHandler: ErrorHandler?,
                         outputAnchor: QLoopAnchor<Output>) {
        self.operationId = operationId
        super.init()
        self.operation = operation
        self.errorHandler = errorHandler
        self.outputAnchor = outputAnchor
        self.inputAnchor = QLoopAnchor<Input>()
    }


    public override var inputAnchor: QLoopAnchor<Input> {
        didSet { applyInputObservers() }
    }

    public override weak var outputAnchor: QLoopAnchor<Output>? {
        didSet {
            self.outputAnchor?.inputSegment = self
            applyInputObservers()
        }
    }

    public let operationId: AnyHashable

    public override var operationIds: [AnyHashable] { return [operationId] }

    private final func applyInputObservers() {
        guard let outAnchor = self.outputAnchor else { return }

        self.inputAnchor.onChange = ({ input in
            let completion: Completion = { outAnchor.input = $0 }
            do { try self.operation(input, completion) }
            catch { type(of: self).handleError(error, self) }
        })

        self.inputAnchor.onError = ({ error in
            type(of: self).handleError(error, self)
        })
    }
}
