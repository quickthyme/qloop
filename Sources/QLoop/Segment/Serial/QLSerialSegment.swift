import Dispatch

public typealias QLss = QLSerialSegment

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

    public convenience init(_ operationId: AnyHashable,
                     _ operation: @escaping Operation) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: nil,
                  output: nil)
    }

    public convenience init(_ operationId: AnyHashable,
                     _ operation: @escaping Operation,
                     errorHandler: ErrorHandler?) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: errorHandler,
                  output: nil)
    }

    public convenience init(_ operationId: AnyHashable,
                     _ operation: @escaping Operation,
                     operationQueue: DispatchQueue?) {
        self.init(operationId, operation)
        if let queue = operationQueue {
            self.operationQueue = queue
        }
    }

    public convenience init(_ operationId: AnyHashable,
                     _ operation: @escaping Operation,
                     operationQueue: DispatchQueue?,
                     errorHandler: ErrorHandler?) {
        self.init(operationId, operation,
                  errorHandler: errorHandler)
        if let queue = operationQueue {
            self.operationQueue = queue
        }
    }

    public convenience init(_ operationId: AnyHashable,
                     _ operation: @escaping Operation,
                     output: QLAnchor<Output>?) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: nil,
                  output: output)
    }

    public convenience init(_ operationId: AnyHashable,
                     _ operation: @escaping Operation,
                     errorHandler: ErrorHandler?,
                     output: QLAnchor<Output>?) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: errorHandler,
                  output: output)
    }

    public convenience init<Unknown>(_ operationId: AnyHashable,
                              _ operation: @escaping Operation,
                              outputSegment: QLSegment<Output, Unknown>?) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: nil,
                  output: outputSegment?.input)
    }

    public convenience init<Unknown>(_ operationId: AnyHashable,
                              _ operation: @escaping Operation,
                              errorHandler: ErrorHandler?,
                              outputSegment: QLSegment<Output, Unknown>?) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: errorHandler,
                  output: outputSegment?.input)
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

    public lazy var operationQueue: DispatchQueue = DispatchQueue.main

    private final func applyInputObservers() {

        self.input.onChange = ({ input in
            self.operationQueue.async {
                self.tryOperation(input)
            }
        })

        self.input.onError = ({ error in
            type(of: self).handleError(error, self)
        })
    }

    private final func tryOperation(_ input: Input?) {
        guard let outAnchor = self.output else { return }
        let completion: Completion = { outAnchor.value = $0 }
        do { try self.operation(input, completion) }
        catch { type(of: self).handleError(error, self) }
    }
}
