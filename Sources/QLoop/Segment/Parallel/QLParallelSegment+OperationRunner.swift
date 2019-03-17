
import Dispatch

fileprivate let completionQueue = DispatchQueue(label: "QLParallelSegment.CompletionQueue")

internal extension QLParallelSegment {

    class OperationBox {
        var id: AnyHashable
        var operation: ParallelOperation
        var completed: Bool
        var value: Any?
        var queue: DispatchQueue?
        init(_ id: AnyHashable,
             _ operation: @escaping ParallelOperation,
             _ queue: DispatchQueue?) {
            self.id = id
            self.operation = operation
            self.completed = false
            self.value = nil
            self.queue = queue
        }
    }

    class OperationRunner: Hashable {

        init(_ id: AnyHashable,
             _ operations: [(AnyHashable, ParallelOperation)],
             _ queues: [AnyHashable:DispatchQueue]) {
            self.id = id
            self.operations = operations.map {
                return OperationBox($0.0, $0.1, queues[$0.0])
            }
        }

        var id: AnyHashable
        var operations: [OperationBox] = []
        var completion: ( ([(AnyHashable, Any?)])->() )!
        var errorCompletion: ( (Error)->() )!

        func run(_ input: Input?) {
            for opBox in self.operations {
                if let queue = opBox.queue {
                    queue.async { self.runOperation(input, opBox) }
                } else {
                    runOperation(input, opBox)
                }
            }
        }

        func runOperation(_ input: Input?, _ opBox: OperationBox) {
            do { try opBox.operation(input, { output in
                opBox.value = output
                opBox.completed = true
                self.totalCompleted += 1 })
            } catch {
                self.errorCompletion(error)
            }
        }

        var totalCompleted: Int {
            get {
                var totalCompleted: Int = 0
                completionQueue.sync { totalCompleted = self._totalCompleted }
                return totalCompleted
            }
            set {
                completionQueue.sync { self._totalCompleted = newValue }
                self.didSetTotalCompleted(newValue)
            }
        }

        private var _totalCompleted: Int = 0

        fileprivate func didSetTotalCompleted(_ totalCompleted: Int) {
            guard (totalCompleted >= self.operations.count) else { return }
            self.completion(operations.map { ($0.id, $0.value) })
        }

        static func == (lhs: QLParallelSegment<Input, Output>.OperationRunner,
                        rhs: QLParallelSegment<Input, Output>.OperationRunner) -> Bool {
            return lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
