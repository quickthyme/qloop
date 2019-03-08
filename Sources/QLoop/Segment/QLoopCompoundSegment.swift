
public final class QLoopCompoundSegment<Input, Output>: QLoopSegment<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias Completion = QLoopSegment<Input, Output>.Completion
    public typealias Reducer = (Output, nextPartialResult: (Output, (AnyHashable, Output?)) -> Output)

    class OperationBox<Output> {
        var operation: Operation
        var completed: Bool
        var value: Output?
        init(_ operation: @escaping Operation) {
            self.operation = operation
            self.completed = false
            self.value = nil
        }
    }

    private var reducer: Reducer? = nil

    private var operations: [AnyHashable:OperationBox<Output>] = [:]

    private var totalCompleted: Int = 0 {
        didSet {
            guard (totalCompleted >= self.operations.count) else { return }

            guard let r = self.reducer else {
                self.outputAnchor.input = self.operations.first?.value.value
                return
            }

            self.outputAnchor.input =
                self.operations
                    .map { ($0.key, $0.value.value) }
                    .reduce(r.0, r.1)
        }
    }

    public convenience init<Unknown>(operations: [AnyHashable:Operation],
                                     reducer: Reducer?,
                                     _ output: QLoopSegment<Output, Unknown>) {
        self.init(operations: operations,
                  reducer: reducer,
                  outputAnchor: output.inputAnchor)
    }

    public required init(operations: [AnyHashable:Operation],
                         reducer: Reducer?,
                         outputAnchor: QLoopAnchor<Output>) {
        super.init()
        self.reducer = reducer
        self.operations = operations.mapValues { OperationBox($0) }
        self.outputAnchor = outputAnchor
        self.inputAnchor = QLoopAnchor<Input>(
            onChange: ({ input in
                for (_, opBox) in self.operations {
                    do {
                        try opBox.operation(input, { output in
                            opBox.value = output
                            opBox.completed = true
                            self.totalCompleted += 1
                        })
                    } catch {
                        outputAnchor.error = error
                    }
                }
            }),

            onError: ({
                outputAnchor.error = $0
            }))
    }
}
