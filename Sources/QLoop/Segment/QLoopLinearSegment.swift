
public final class QLoopLinearSegment<Input, Output>: QLoopSegment<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias Completion = QLoopSegment<Input, Output>.Completion

    public convenience init<Unknown>(_ operation: @escaping Operation,
                                     _ output: QLoopSegment<Output, Unknown>) {
        self.init(operation, output.inputAnchor)
    }

    public required init(_ operation: @escaping Operation,
                         _ outputAnchor: QLoopAnchor<Output>) {
        super.init()
        self.outputAnchor = outputAnchor
        self.inputAnchor = QLoopAnchor<Input>(

            onChange: ({ input in
                do {
                    try operation(input, { output in outputAnchor.input = output })
                } catch {
                    outputAnchor.error = error
                }
            }),

            onError: ({
                outputAnchor.error = $0
            }))
    }
}
