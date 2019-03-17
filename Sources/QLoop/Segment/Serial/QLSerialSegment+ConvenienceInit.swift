
public typealias QLss = QLSerialSegment

public extension QLSerialSegment {

    public convenience init(_ operationId: AnyHashable,
                            _ operation: @escaping Operation) {
        self.init(operationId, operation, errorHandler: nil, output: nil)
    }

    public convenience init(_ operationId: AnyHashable,
                            _ operation: @escaping Operation,
                            errorHandler: ErrorHandler?) {
        self.init(operationId, operation, errorHandler: errorHandler, output: nil)
    }

    public convenience init(_ operationId: AnyHashable,
                            _ operation: @escaping Operation,
                            output: QLAnchor<Output>?) {
        self.init(operationId, operation, errorHandler: nil, output: output)
    }

    public convenience init(_ operationId: AnyHashable,
                            _ operation: @escaping Operation,
                            errorHandler: ErrorHandler?,
                            output: QLAnchor<Output>?) {
        self.init(operationId: operationId, operation: operation,
                  errorHandler: errorHandler, output: output)
    }

    public convenience init<Unknown>(_ operationId: AnyHashable,
                                     _ operation: @escaping Operation,
                                     outputSegment: QLSegment<Output, Unknown>?) {
        self.init(operationId, operation, errorHandler: nil, output: outputSegment?.input)
    }


    public convenience init<Unknown>(_ operationId: AnyHashable,
                                     _ operation: @escaping Operation,
                                     errorHandler: ErrorHandler?,
                                     outputSegment: QLSegment<Output, Unknown>?) {
        self.init(operationId, operation, errorHandler: errorHandler, output: outputSegment?.input)
    }
}
