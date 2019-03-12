
public protocol AnyLoopSegment: class {
    var anyInputAnchor: AnyLoopAnchor { get }
    var anyOutputAnchor: AnyLoopAnchor? { get }
    var operationIds: [AnyHashable] { get }
    var hasErrorHandler: Bool { get }
    func linked(to otherSegment: AnyLoopSegment) -> Self?
    func applyOutputAnchor(_ otherAnchor: AnyLoopAnchor)
    func findSegments(with operationId: AnyHashable) -> [AnyLoopSegment]
    func describeOperationPath() -> String
    func operationPath() -> [([AnyHashable], Bool)]
}

open class QLoopSegment<Input, Output>: AnyLoopSegment {
    public typealias Operation = (Input?, @escaping Completion) throws -> ()
    public typealias ErrorHandler = (Error, @escaping Completion, @escaping ErrorCompletion) -> ()
    public typealias Completion = (Output?) -> ()
    public typealias ErrorCompletion = (Error) -> ()

    internal init() {}

    open var inputAnchor: QLoopAnchor<Input> = QLoopAnchor<Input>()
    open weak var outputAnchor: QLoopAnchor<Output>?

    open var operation: Operation = {_,_  in }
    open var operationIds: [AnyHashable] { return [] }

    public var hasErrorHandler: Bool { return self.errorHandler != nil }

    public var errorHandler: ErrorHandler? = {_,_,_  in }

    internal static func handleError(error: Error, segment: QLoopSegment<Input, Output>) {
        guard let outAnchor = segment.outputAnchor else { return }
        guard let handler = segment.errorHandler
            else { outAnchor.error = error; return }
        let completion: Completion = { outAnchor.input = $0 }
        let errorCompletion: ErrorCompletion = { outAnchor.error = $0 }
        handler(error, completion, errorCompletion)
    }


    // MARK: - Shared type-erased functions

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
        return type(of: self).findSegments(with: operationId, fromSegment: self)
    }

    public static func findSegments(with operationId: AnyHashable, fromSegment: AnyLoopSegment,
                                    currentResults: [AnyLoopSegment] = []) -> [AnyLoopSegment] {
        let newResults = (fromSegment.operationIds.contains(operationId))
            ? [fromSegment] + currentResults
            : currentResults
        guard let next = fromSegment.anyInputAnchor.backwardOwner else { return newResults }
        return findSegments(with: operationId, fromSegment: next, currentResults: newResults)
    }


    public func describeOperationPath() -> String {
        return type(of: self).describeOperationPath(fromSegment: self)
    }

    public static func describeOperationPath(fromSegment: AnyLoopSegment) -> String {
        let opPath = operationPath(fromSegment: fromSegment)
        return opPath.reduce("", { (currentOps, next) in
            let nextOps: String =
                "{"
                    + next.0.map({ "\($0)\((next.1) ? "*" : "")" })
                    .sorted()
                    .joined(separator: ":")
                + "}"
            return (currentOps != "")
                ? [currentOps, nextOps].joined(separator: "-")
                : nextOps
        })
    }


    public func operationPath() -> [([AnyHashable], Bool)] {
        return type(of: self).operationPath(fromSegment: self)
    }

    public static func operationPath(fromSegment: AnyLoopSegment,
                                     currentResults: [([AnyHashable], Bool)] = []) -> [([AnyHashable], Bool)] {
        let newResults = [(fromSegment.operationIds, fromSegment.hasErrorHandler)] + currentResults
        guard let next = fromSegment.anyInputAnchor.backwardOwner else { return newResults }
        return operationPath(fromSegment: next, currentResults: newResults)
    }
}
