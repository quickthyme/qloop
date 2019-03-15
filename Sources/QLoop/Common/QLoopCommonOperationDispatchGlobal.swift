
import Dispatch

public extension QLoopCommon.Operation {

    public struct DispatchGlobal<Input> {
        public typealias Completion = (Input?) -> ()
        public typealias ErrCompletion = (Error) -> ()
        public typealias Operation = (Input?, @escaping Completion) -> ()
        public typealias Handler = (Error, @escaping Completion, @escaping ErrCompletion) -> ()

        public init(_ qosClass: DispatchQoS.QoSClass) {
            self.id = "global_qos_thread_\(qosClass)"
            self.qosClass = qosClass
        }

        public let id: String
        public let qosClass: DispatchQoS.QoSClass

        public var op: Operation {
            let qos = qosClass
            return ({ input, completion in
                DispatchQueue.global(qos: qos).async {
                    completion(input)
                }
            })
        }

        public var err: Handler {
            let qos = qosClass
            return ({ error, _, errCompletion in
                DispatchQueue.global(qos: qos).async {
                    errCompletion(error)
                }
            })
        }
    }
}
