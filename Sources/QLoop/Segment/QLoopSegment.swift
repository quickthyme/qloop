
public protocol AnyLoopSegment: class {
    var anyInputAnchor: AnyLoopAnchor { get }
    var anyOutputAnchor: AnyLoopAnchor { get }
    func linked(to otherSegment: AnyLoopSegment) -> Self?
}

open class QLoopSegment<Input, Output>: AnyLoopSegment {
    public typealias Operation = (Input?, Completion) throws -> ()
    public typealias Completion = (Output?) -> ()

    open var inputAnchor: QLoopAnchor<Input> = QLoopAnchor<Input>()
    open var outputAnchor: QLoopAnchor<Output> = QLoopAnchor<Output>()

    open var operation: Operation = {_,_  in }

    public var anyInputAnchor: AnyLoopAnchor {
        return self.inputAnchor
    }

    public var anyOutputAnchor: AnyLoopAnchor {
        return self.outputAnchor
    }

    public func linked(to otherSegment: AnyLoopSegment) -> Self? {
        guard
            let compatibleInput = otherSegment.anyInputAnchor as? QLoopAnchor<Output>
            else { return nil }
        self.outputAnchor = compatibleInput
        return self
    }
}
