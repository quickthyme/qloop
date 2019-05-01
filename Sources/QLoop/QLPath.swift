open class QLPath<Input, Output> {
    public typealias Operation = QLSegment<Input, Output>.Operation
    public typealias Completion = QLSegment<Input, Output>.Completion

    public required init?(_ segments: AnySegment...) {

        guard
            let lastSegment = segments.last,
            let firstSegment = segments.first
            else { return nil }

        do {
            let _: AnySegment =

            try segments.reduce(
                firstSegment,
                ({ result, next in
                    guard (result !== next) else { return result }
                    guard let _ = result.linked(to: next)
                        else { throw QLCommon.Error.AnchorMismatch }
                    return next
                })
            )

            lastSegment.applyOutputAnchor(self.output)
            self.input = firstSegment.inputAnchor as! QLAnchor<Input>

        } catch { return nil }
    }

    public final var input: QLAnchor<Input> = QLAnchor<Input>()
    public final var output: QLAnchor<Output> = QLAnchor<Output>()

    public final func findSegments(with operationId: AnyHashable) -> [AnySegment] {
        return output.inputSegment?.findSegments(with: operationId) ?? []
    }

    public final func describeOperationPath() -> String {
        return output.inputSegment?.describeOperationPath() ?? ""
    }

    public final func operationPath() -> QLoopOperationPath {
        return output.inputSegment?.operationPath() ?? []
    }
}
