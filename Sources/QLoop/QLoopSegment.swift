
open class QLoopSegment<Input, Output> {
    public typealias Operation = ( Input?, Completion)->()
    public typealias Completion = (Output?)->()

    public var inputAnchor: QLoopAnchor<Input> = QLoopAnchor<Input>()
    public var outputAnchor: QLoopAnchor<Output>

    public required init(_ operation: @escaping Operation,
                         _ outputAnchor: QLoopAnchor<Output>) {
        self.outputAnchor = outputAnchor
        self.inputAnchor = QLoopAnchor<Input>(
            onChange: QLoopSegment.invokeOperation(operation, outputAnchor)
        )
    }

    public convenience init<Unknown>(_ operation: @escaping Operation,
                                     _ output: QLoopSegment<Output, Unknown>) {
        self.init(operation, output.inputAnchor)
    }

    private static func invokeOperation(_ operation: @escaping Operation,
                                        _ outputAnchor: QLoopAnchor<Output>?) -> (Input?)->() {
        return { input in
            operation(input, { output in outputAnchor?.input = output })
        }
    }
}
