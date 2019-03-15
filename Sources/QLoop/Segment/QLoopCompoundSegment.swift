
import Dispatch

fileprivate let startingQueue = DispatchQueue(label: "QLoopCompoundSegment.StartingQueue")
fileprivate let completionQueue = DispatchQueue(label: "QLoopCompoundSegment.CompletionQueue")

public final class QLoopCompoundSegment<Input, Output>: QLoopSegment<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias ErrorHandler = QLoopSegment<Input, Output>.ErrorHandler
    public typealias Completion = QLoopSegment<Input, Output>.Completion
    public typealias ErrorCompletion = QLoopSegment<Input, Output>.ErrorCompletion
    public typealias Reducer = (Output, nextPartialResult: (Output, (AnyHashable, Output?)) -> Output)

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

    private var operations: [OperationBox] = []
    private var operationSetsStarted: Int = 0
    private var runningOperations: Set<OperationSet> = []

    fileprivate func reduceOperationResults(_ opResults:[(AnyHashable, Output?)]) {
        if let r = self.reducer {
            self.outputAnchor?.value = opResults.reduce(r.0, r.1)
        } else {
            self.outputAnchor?.value = opResults.first?.1
        }
    }

    private final func applyInputObservers() {
        guard let _ = self.outputAnchor else { return }

        self.inputAnchor.onChange = ({ input in

            var setId: Int = 0
            startingQueue.sync {
                setId = self.operationSetsStarted + 1
                self.operationSetsStarted = setId
            }

            let newOperationSet = OperationSet(setId, self.operations)

            newOperationSet.completion = ({ results in
                self.reduceOperationResults(results)
                self.destoryOperationSet(newOperationSet)
            })

            newOperationSet.errorCompletion = ({ error in
                type(of: self).handleError(error, self)
            })

            self.startOperationSet(newOperationSet, input)
        })

        self.inputAnchor.onError = ({ error in
            type(of: self).handleError(error, self)
        })
    }

    private func startOperationSet(_ operationSet: OperationSet, _ input: Input?) {
        startingQueue.sync { let _ = self.runningOperations.insert(operationSet) }
        operationSet.run(input)
    }

    private func destoryOperationSet(_ operationSet: OperationSet) {
        startingQueue.sync { let _ = runningOperations.remove(operationSet) }
    }

    private class OperationBox {
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

    private class OperationSet: Hashable {
        init(_ id: AnyHashable,
             _ operations: [OperationBox]) {
            self.id = id
            self.operations = operations
        }

        var id: AnyHashable
        var operations: [OperationBox] = []
        var completion: ( ([(AnyHashable, Output?)])->() )!
        var errorCompletion: ( (Error)->() )!

        func run(_ input: Input?) {
            for opBox in self.operations {

                do {
                    try opBox.operation(input, { output in
                        opBox.value = output
                        opBox.completed = true
                        self.totalCompleted += 1
                    })
                }

                catch {
                    self.errorCompletion(error)
                }
            }
        }

        var totalCompleted: Int {
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
        private var _totalCompleted: Int = 0

        fileprivate func didSetTotalCompleted(_ totalCompleted: Int) {
            guard (totalCompleted >= self.operations.count) else { return }
            self.completion(operations.map { ($0.id, $0.value) })
        }

        static func == (lhs: QLoopCompoundSegment<Input, Output>.OperationSet,
                        rhs: QLoopCompoundSegment<Input, Output>.OperationSet) -> Bool {
            return lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
