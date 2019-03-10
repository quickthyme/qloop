
public class QLoopPath<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias Completion = QLoopSegment<Input, Output>.Completion

    public var inputAnchor: QLoopAnchor<Input> = QLoopAnchor<Input>()
    public var outputAnchor: QLoopAnchor<Output> = QLoopAnchor<Output>()

    public init?(_ segments: AnyLoopSegment...) {

        guard
            let lastSegment = segments.last,
            let firstSegment = segments.first
            else { return nil }

        do {
            let _: AnyLoopSegment =

            try segments.reduce(
                firstSegment,
                ({ result, next in
                    guard (result !== next) else { return result }
                    guard let _ = result.linked(to: next)
                        else { throw QLoopError.AnchorMismatch }
                    return next
                })
            )

            lastSegment.applyOutputAnchor(self.outputAnchor)
            self.inputAnchor = firstSegment.anyInputAnchor as! QLoopAnchor<Input>

        } catch { return nil }
    }
}
