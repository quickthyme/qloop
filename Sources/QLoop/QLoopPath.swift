
public struct QLoopPath {
    @discardableResult
    public static func inputAnchor<Input, Output>(_ segment: QLoopSegment<Input, Output>,
                                                  _ segments: AnyLoopSegment...) -> QLoopAnchor<Input> {
        do {
            let _: AnyLoopSegment =

            try segments.reduce(
                segment as AnyLoopSegment,
                ({ result, next in
                    guard let _ = result.linked(to: next)
                        else { throw QLoopError.AnchorMismatch }
                    return next
                })
            )

            return segment.inputAnchor

        } catch { fatalError("\(error)") }
    }
}

