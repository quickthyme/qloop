
import Dispatch

fileprivate let completionQueue = DispatchQueue(label: "QLoopCompoundSegment.CompletionQueue")

public final class QLoopCompoundSegment<Input, Output>: QLoopSegment<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias ErrorHandler = QLoopSegment<Input, Output>.ErrorHandler
    public typealias Completion = QLoopSegment<Input, Output>.Completion
    public typealias ErrorCompletion = QLoopSegment<Input, Output>.ErrorCompletion
    public typealias Reducer = (Output, nextPartialResult: (Output, (AnyHashable, Output?)) -> Output)

    class OperationBox<Output> {
        var id: AnyHashable
        var operation: Operation
        var completed: Bool
        var value: Output?
        init(_ id: AnyHashable, _ operation: @escaping Operation) {
            self.id = id
            self.operation = operation
            self.completed = false
            self.value = nil
        }
    }

    public convenience init(_ operations: [AnyHashable:Operation]) {
        self.init(operations,
                  reducer: nil,
                  errorHandler: nil,
                  outputAnchor: QLoopAnchor<Output>())
    }

    public convenience init(_ operations: [AnyHashable:Operation],
                            errorHandler: ErrorHandler?) {
        self.init(operations,
                  reducer: nil,
                  errorHandler: errorHandler,
                  outputAnchor: QLoopAnchor<Output>())
    }

    public convenience init(_ operations: [AnyHashable:Operation],
                            reducer: Reducer?) {
        self.init(operations,
                  reducer: reducer,
                  errorHandler: nil,
                  outputAnchor: QLoopAnchor<Output>())
    }

    public convenience init(_ operations: [AnyHashable:Operation],
                            reducer: Reducer?,
                            errorHandler: ErrorHandler?) {
        self.init(operations,
                  reducer: reducer,
                  errorHandler: errorHandler,
                  outputAnchor: QLoopAnchor<Output>())
    }

    public convenience init<Unknown>(_ operations: [AnyHashable:Operation],
                                     reducer: Reducer?,
                                     output: QLoopSegment<Output, Unknown>) {
        self.init(operations,
                  reducer: reducer,
                  errorHandler: nil,
                  outputAnchor: output.inputAnchor)
    }

    public convenience init<Unknown>(_ operations: [AnyHashable:Operation],
                                     reducer: Reducer?,
                                     errorHandler: ErrorHandler?,
                                     output: QLoopSegment<Output, Unknown>) {
        self.init(operations,
                  reducer: reducer,
                  errorHandler: errorHandler,
                  outputAnchor: output.inputAnchor)
    }

    public convenience init(_ operations: [AnyHashable:Operation],
                            reducer: Reducer?,
                            outputAnchor: QLoopAnchor<Output>) {
        self.init(operations,
                  reducer: reducer,
                  errorHandler: nil,
                  outputAnchor: outputAnchor)
    }

    public required init(_ operations: [AnyHashable:Operation],
                         reducer: Reducer?,
                         errorHandler: ErrorHandler?,
                         outputAnchor: QLoopAnchor<Output>) {
        super.init()
        self.reducer = reducer
        self.errorHandler = errorHandler
        self.operations = operations.map { OperationBox($0.key, $0.value) }
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

    public override var operationIds: [AnyHashable] { return operations.map { $0.id } }

    private var reducer: Reducer? = nil

    private var operations: [OperationBox<Output>] = []

    fileprivate var totalCompleted: Int {
        get {
            var totalCompleted: Int = 0
            completionQueue.sync {
                totalCompleted = self._totalCompleted
            }
            return totalCompleted
        }
        set {
            completionQueue.sync {
                self._totalCompleted = newValue
            }
            self.didSetTotalCompleted(newValue)
        }
    }
    fileprivate var _totalCompleted: Int = 0

    fileprivate func didSetTotalCompleted(_ totalCompleted: Int) {
        guard (totalCompleted >= self.operations.count) else { return }

        guard let r = self.reducer else {
            self.outputAnchor?.input = self.operations.first?.value
            return
        }

        self.outputAnchor?.input =
            self.operations
                .map { ($0.id, $0.value) }
                .reduce(r.0, r.1)
    }

    private final func applyInputObservers() {
        guard let _ = self.outputAnchor else { return }

        self.inputAnchor.onChange = ({ input in
            for opBox in self.operations {

                do {
                    try opBox.operation(input, { output in
                        opBox.value = output
                        opBox.completed = true
                        self.totalCompleted += 1
                    })
                }

                catch {
                    type(of: self).handleError(error, self)
                }
            }
        })

        self.inputAnchor.onError = ({ error in
            type(of: self).handleError(error, self)
        })
    }
}
