
public typealias QLps = QLParallelSegment

public extension QLParallelSegment {

    convenience init(_ operations: [AnyHashable:ParallelOperation]) {
        self.init(operations,
                  combiner: nil,
                  errorHandler: nil,
                  output: nil)
    }

    convenience init(_ operations: [AnyHashable:ParallelOperation],
                            errorHandler: ErrorHandler?) {
        self.init(operations,
                  combiner: nil,
                  errorHandler: errorHandler,
                  output: nil)
    }

    convenience init(_ operations: [AnyHashable:ParallelOperation],
                            combiner: Combiner?) {
        self.init(operations,
                  combiner: combiner,
                  errorHandler: nil,
                  output: nil)
    }

    convenience init(_ operations: [AnyHashable:ParallelOperation],
                            combiner: Combiner?,
                            errorHandler: ErrorHandler?) {
        self.init(operations,
                  combiner: combiner,
                  errorHandler: errorHandler,
                  output: nil)
    }

    convenience init(_ operations: [AnyHashable:ParallelOperation],
                            combiner: Combiner?,
                            output: QLAnchor<Output>?) {
        self.init(operations,
                  combiner: combiner,
                  errorHandler: nil,
                  output: output)
    }

    convenience init<Unknown>(_ operations: [AnyHashable:ParallelOperation],
                                     combiner: Combiner?,
                                     outputSegment: QLSegment<Output, Unknown>?) {
        self.init(operations,
                  combiner: combiner,
                  errorHandler: nil,
                  output: outputSegment?.input)
    }

    convenience init<Unknown>(_ operations: [AnyHashable:ParallelOperation],
                                     combiner: Combiner?,
                                     errorHandler: ErrorHandler?,
                                     outputSegment: QLSegment<Output, Unknown>?) {
        self.init(operations,
                  combiner: combiner,
                  errorHandler: errorHandler,
                  output: outputSegment?.input)
    }
}
