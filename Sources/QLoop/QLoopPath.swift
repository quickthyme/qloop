
@discardableResult
public func QLoopPath<Input, Output>(_ segment: QLoopSegment<Input, Output>,
                                     _ segments: AnyLoopSegment...) -> QLoopSegment<Input, Output> {

    do {
        let _: AnyLoopSegment = try segments
            .reduce(segment as AnyLoopSegment, { result, next in
                guard (result !== next) else { return result }
                guard let _ = result.linked(to: next)
                    else { throw QLoopError.AnchorMismatch }
                return next
            })
        return segment
    } catch {
        return QLoopBrokenPath<Input, Output>(error)
    }
}


public class QLoopBrokenPath<Input, Output>: QLoopSegment<Input, Output> {
    let error:Error
    init(_ error: Error) { self.error = error }
}
