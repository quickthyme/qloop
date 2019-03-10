
public protocol AnyLoopSegment: class {
    var anyInputAnchor: AnyLoopAnchor { get }
    var anyOutputAnchor: AnyLoopAnchor? { get }
    var operationIds: [AnyHashable] { get }
    func linked(to otherSegment: AnyLoopSegment) -> Self?
    func applyOutputAnchor(_ otherAnchor: AnyLoopAnchor)
    func findSegments(with operationId: AnyHashable) -> [AnyLoopSegment]
}

open class QLoopSegment<Input, Output>: AnyLoopSegment {
    public typealias Operation = (Input?, Completion) throws -> ()
    public typealias Completion = (Output?) -> ()

    internal init() {}

    open var inputAnchor: QLoopAnchor<Input> = QLoopAnchor<Input>()
    open weak var outputAnchor: QLoopAnchor<Output>?

    open var operation: Operation = {_,_  in }
    open var operationIds: [AnyHashable] { return [] }

    public var anyInputAnchor: AnyLoopAnchor {
        return self.inputAnchor
    }

    public var anyOutputAnchor: AnyLoopAnchor? {
        return self.outputAnchor
    }

    public func linked(to otherSegment: AnyLoopSegment) -> Self? {
        guard
            let compatibleInput = otherSegment.anyInputAnchor as? QLoopAnchor<Output>
            else { return nil }
        self.outputAnchor = compatibleInput
        return self
    }

    public func applyOutputAnchor(_ otherAnchor: AnyLoopAnchor) {
        self.outputAnchor = otherAnchor as? QLoopAnchor<Output> 
    }

    public func findSegments(with operationId: AnyHashable) -> [AnyLoopSegment] {
        return QLoopSegment.findSegments(with: operationId, fromSegment: self)
    }

    public static func findSegments(with operationId: AnyHashable,
                                    fromSegment: AnyLoopSegment,
                                    currentResults: [AnyLoopSegment] = []) -> [AnyLoopSegment] {

        let newResults = (fromSegment.operationIds.contains(operationId))
            ? [fromSegment] + currentResults
            : currentResults

        guard let next = fromSegment.anyInputAnchor.backwardOwner else { return newResults }
        return findSegments(with: operationId, fromSegment: next, currentResults: newResults)
    }
}
