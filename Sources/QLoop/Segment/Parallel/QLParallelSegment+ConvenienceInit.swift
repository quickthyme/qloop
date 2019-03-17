
public typealias QLps = QLParallelSegment

public extension QLParallelSegment {

    public convenience init(_ operations: [AnyHashable:ParallelOperation]) {
        self.init(operations,
                  transducer: nil,
                  errorHandler: nil,
                  output: nil)
    }

    public convenience init(_ operations: [AnyHashable:ParallelOperation],
                            errorHandler: ErrorHandler?) {
        self.init(operations,
                  transducer: nil,
                  errorHandler: errorHandler,
                  output: nil)
    }

    public convenience init(_ operations: [AnyHashable:ParallelOperation],
                            transducer: Transducer?) {
        self.init(operations,
                  transducer: transducer,
                  errorHandler: nil,
                  output: nil)
    }

    public convenience init(_ operations: [AnyHashable:ParallelOperation],
                            transducer: Transducer?,
                            errorHandler: ErrorHandler?) {
        self.init(operations,
                  transducer: transducer,
                  errorHandler: errorHandler,
                  output: nil)
    }

    public convenience init(_ operations: [AnyHashable:ParallelOperation],
                            transducer: Transducer?,
                            output: QLAnchor<Output>?) {
        self.init(operations,
                  transducer: transducer,
                  errorHandler: nil,
                  output: output)
    }

    public convenience init<Unknown>(_ operations: [AnyHashable:ParallelOperation],
                                     transducer: Transducer?,
                                     outputSegment: QLSegment<Output, Unknown>?) {
        self.init(operations,
                  transducer: transducer,
                  errorHandler: nil,
                  output: outputSegment?.input)
    }

    public convenience init<Unknown>(_ operations: [AnyHashable:ParallelOperation],
                                     transducer: Transducer?,
                                     errorHandler: ErrorHandler?,
                                     outputSegment: QLSegment<Output, Unknown>?) {
        self.init(operations,
                  transducer: transducer,
                  errorHandler: errorHandler,
                  output: outputSegment?.input)
    }
}
