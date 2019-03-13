
open class QLoopPath<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias Completion = QLoopSegment<Input, Output>.Completion

    public required init?(_ segments: AnyLoopSegment...) {

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

    public final var inputAnchor: QLoopAnchor<Input> = QLoopAnchor<Input>()
    public final var outputAnchor: QLoopAnchor<Output> = QLoopAnchor<Output>()

    public final func findSegments(with operationId: AnyHashable) -> [AnyLoopSegment] {
        return outputAnchor.inputSegment?.findSegments(with: operationId) ?? []
    }

    public final func describeOperationPath() -> String {
        return outputAnchor.inputSegment?.describeOperationPath() ?? ""
    }

    public final func operationPath() -> [([AnyHashable], Bool)] {
        return outputAnchor.inputSegment?.operationPath() ?? []
    }
}
