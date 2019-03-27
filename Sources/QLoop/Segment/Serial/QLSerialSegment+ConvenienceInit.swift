
public typealias QLss = QLSerialSegment

public extension QLSerialSegment {

    convenience init(_ operationId: AnyHashable,
                     _ operation: @escaping Operation) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: nil,
                  output: nil)
    }

    convenience init(_ operationId: AnyHashable,
                     _ operation: @escaping Operation,
                     errorHandler: ErrorHandler?) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: errorHandler,
                  output: nil)
    }

    convenience init(_ operationId: AnyHashable,
                     _ operation: @escaping Operation,
                     output: QLAnchor<Output>?) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: nil,
                  output: output)
    }

    convenience init(_ operationId: AnyHashable,
                     _ operation: @escaping Operation,
                     errorHandler: ErrorHandler?,
                     output: QLAnchor<Output>?) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: errorHandler,
                  output: output)
    }

    convenience init<Unknown>(_ operationId: AnyHashable,
                              _ operation: @escaping Operation,
                              outputSegment: QLSegment<Output, Unknown>?) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: nil,
                  output: outputSegment?.input)
    }


    convenience init<Unknown>(_ operationId: AnyHashable,
                              _ operation: @escaping Operation,
                              errorHandler: ErrorHandler?,
                              outputSegment: QLSegment<Output, Unknown>?) {
        self.init(operationId: operationId,
                  operation: operation,
                  errorHandler: errorHandler,
                  output: outputSegment?.input)
    }
}
