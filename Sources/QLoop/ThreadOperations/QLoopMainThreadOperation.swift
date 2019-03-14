
import Dispatch

public struct QLoopMainThreadOperation<Input> {
    public typealias Completion = (Input?) -> ()
    public typealias ErrCompletion = (Error) -> ()
    public typealias Operation = (Input?, @escaping Completion) -> ()
    public typealias Handler = (Error, @escaping Completion, @escaping ErrCompletion) -> ()

    public init() {}

    public let id: String = "main_thread"

    public var op: Operation {
        return ({ input, completion in
            DispatchQueue.main.async {
                completion(input)
            }
        })
    }

    public var err: Handler {
        return ({ error, _, errCompletion in
            DispatchQueue.main.async {
                errCompletion(error)
            }
        })
    }

    public static func constructSegment() -> QLoopLinearSegment<Input, Input> {
        let mainThread = QLoopMainThreadOperation<Input>()
        return QLoopLinearSegment(mainThread.id, mainThread.op, errorHandler: mainThread.err)
    }
}
