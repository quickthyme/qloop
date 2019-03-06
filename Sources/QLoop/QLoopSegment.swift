
public class QLoopSegment<Input, Output> {
    public typealias Action = ( Input?, Completion)->()
    public typealias Completion = (Output?)->()

    public var inputAnchor: QLoopAnchor<Input> = QLoopAnchor<Input>()
    public var outputAnchor: QLoopAnchor<Output>

    public required init(_ action: @escaping Action, _ outputAnchor: QLoopAnchor<Output>) {
        self.outputAnchor = outputAnchor
        self.inputAnchor = QLoopAnchor<Input>(
            onChange: QLoopSegment.invokeAction(action, outputAnchor)
        )
    }

    public convenience init<Unknown>(_ action: @escaping Action, _ output: QLoopSegment<Output, Unknown>) {
        self.init(action, output.inputAnchor)
    }

    private static func invokeAction(_ action: @escaping Action,
                                     _ outputAnchor: QLoopAnchor<Output>?) -> (Input?)->() {
        return { input in
            let completion = QLoopSegment.actionCompletion(outputAnchor)
            action(input, completion)
        }
    }

    private static func actionCompletion(_ outputAnchor: QLoopAnchor<Output>?) -> (Output?)->() {
        return { output in
            outputAnchor?.input = output
        }
    }
}
