
public final class QLSerialSegment<Input, Output>: QLSegment<Input, Output> {
    public typealias Operation = QLSegment<Input, Output>.Operation
    public typealias ErrorHandler = QLSegment<Input, Output>.ErrorHandler
    public typealias Completion = QLSegment<Input, Output>.Completion
    public typealias ErrorCompletion = QLSegment<Input, Output>.ErrorCompletion

    public required init(operationId: AnyHashable,
                         operation: @escaping Operation,
                         errorHandler: ErrorHandler?,
                         output: QLAnchor<Output>?) {
        self.operationId = operationId
        super.init()
        self.operation = operation
        self.errorHandler = errorHandler
        self.output = output
        self.input = QLAnchor<Input>()
    }


    public override var input: QLAnchor<Input> {
        didSet { applyInputObservers() }
    }

    public override weak var output: QLAnchor<Output>? {
        didSet {
            self.output?.inputSegment = self
            applyInputObservers()
        }
    }

    public let operationId: AnyHashable

    public override var operationIds: [AnyHashable] { return [operationId] }

    private final func applyInputObservers() {
        guard let outAnchor = self.output else { return }

        self.input.onChange = ({ input in
            let completion: Completion = { outAnchor.value = $0 }
            do { try self.operation(input, completion) }
            catch { type(of: self).handleError(error, self) }
        })

        self.input.onError = ({ error in
            type(of: self).handleError(error, self)
        })
    }
}
