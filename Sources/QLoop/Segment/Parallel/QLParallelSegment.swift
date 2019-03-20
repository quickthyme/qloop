
import Dispatch

public final class QLParallelSegment<Input, Output>: QLSegment<Input, Output> {
    public typealias ParallelOperation = QLSegment<Input, Any>.Operation
    public typealias ErrorHandler = QLSegment<Input, Output>.ErrorHandler
    public typealias Completion = QLSegment<Input, Output>.Completion
    public typealias ErrorCompletion = QLSegment<Input, Output>.ErrorCompletion
    public typealias Combiner = (Output?, (Output?, (AnyHashable, Any?)) -> Output?)

    lazy var startingQueue = DispatchQueue(label: "\(self).startingQueue")

    public required init(_ operations: [AnyHashable:ParallelOperation],
                         combiner: Combiner?,
                         errorHandler: ErrorHandler?,
                         output: QLAnchor<Output>?) {
        super.init()
        if let tx = combiner { self.combiner = tx }
        self.errorHandler = errorHandler
        self.operations = operations.map { ($0.key, $0.value) }
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

    public override var operationIds: [AnyHashable] { return operations.map { $0.0 } }

    public var operationQueues: [AnyHashable:DispatchQueue] = [:]

    private var combiner: Combiner = (nil, { r,n in return (n.1 as? Output ?? r) })

    private var operations: [(AnyHashable, ParallelOperation)] = []

    private var operationRunnersStarted: Int = 0

    private var runningOperations: Set<OperationRunner> = []

    private final func applyInputObservers() {
        guard let _ = self.output else { return }

        self.input.onChange = ({ input in
            let startId = self.getSynchronizedStartId()
            let runner = self.getNewOperationRunner(startId)
            self.startOperationRunner(runner, input)
        })

        self.input.onError = makeOnError()
    }

    private func getSynchronizedStartId() -> Int {
        var startId: Int = 0
        startingQueue.sync {
            startId = self.operationRunnersStarted + 1
            self.operationRunnersStarted = startId
        }
        return startId
    }

    private func getNewOperationRunner(_ startId: AnyHashable) -> OperationRunner {
        let runner = OperationRunner(startId, self.operations, self.operationQueues)
        runner.completion = makeRunnerCompletion(for: runner)
        runner.errorCompletion = makeOnError()
        return runner
    }

    private func makeRunnerCompletion(for runner: OperationRunner) -> ([(AnyHashable, Any?)])->() {
        return ({ results in
            self.combineOperationResults(results)
            self.destoryOperationRunner(runner)
        })
    }

    private func makeOnError() -> (Error)->() {
        return ({ error in
            type(of: self).handleError(error, self)
        })
    }

    fileprivate func combineOperationResults(_ opResults:[(AnyHashable, Any?)]) {
        let tr = self.combiner
        self.output?.value = opResults.reduce(tr.0, tr.1)
    }

    private func startOperationRunner(_ runner: OperationRunner, _ input: Input?) {
        startingQueue.sync { let _ = self.runningOperations.insert(runner) }
        runner.run(input)
    }

    private func destoryOperationRunner(_ runner: OperationRunner) {
        startingQueue.sync { let _ = runningOperations.remove(runner) }
    }
}
