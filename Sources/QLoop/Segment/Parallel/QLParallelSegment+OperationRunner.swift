
import Dispatch

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
        let completionQueue = DispatchQueue.init(label: "QLParallelSegment.CompletionQueue")

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
                self.allCompleted = true })
            } catch {
                self.errorCompletion(error)
            }
        }

        var allCompleted: Bool {
            get {
                var isCompleted: Bool = false
                completionQueue.sync { isCompleted = self.__allCompleted }
                return isCompleted
            }
            set {
                completionQueue.sync {
                    if (self.__allCompleted == true) { return }
                    self.__allCompleted = self.operations
                        .reduce(true, { ($1.completed) ? $0 : false } )
                    if (self.__allCompleted == true) {
                        self.completion(operations.map { ($0.id, $0.value) })
                    }
                }
            }
        }
        private var __allCompleted: Bool = false

        static func == (lhs: QLParallelSegment<Input, Output>.OperationRunner,
                        rhs: QLParallelSegment<Input, Output>.OperationRunner) -> Bool {
            return lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
