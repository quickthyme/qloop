open class QLSegment<Input, Output>: AnySegment {
    public typealias Operation = (Input?, @escaping Completion) throws -> ()
    public typealias ErrorHandler = (Error, @escaping Completion, @escaping ErrorCompletion) -> ()
    public typealias Completion = (Output?) -> ()
    public typealias ErrorCompletion = (Error) -> ()

    internal init() {}

    open var input: QLAnchor<Input> = QLAnchor<Input>()
    open weak var output: QLAnchor<Output>?

    open var operation: Operation = {_,_  in }
    open var operationIds: [AnyHashable] { return [] }

    public var hasErrorHandler: Bool { return self.errorHandler != nil }

    public var errorHandler: ErrorHandler? = nil

    internal static func handleError(_ error: Error, _ segment: QLSegment<Input, Output>) {
        guard let outAnchor = segment.output else { return }
        guard let handler = segment.errorHandler
            else { outAnchor.error = error; return }
        let completion: Completion = { outAnchor.value = $0 }
        let errorCompletion: ErrorCompletion = { outAnchor.error = $0 }
        handler(error, completion, errorCompletion)
    }


    // MARK: - Shared type-erased functions

    public var inputAnchor: AnyAnchor {
        return self.input
    }

    public var outputAnchor: AnyAnchor? {
        return self.output
    }

    public func linked(to otherSegment: AnySegment) -> Self? {
        guard
            let compatibleInput = otherSegment.inputAnchor as? QLAnchor<Output>
            else { return nil }
        self.output = compatibleInput
        return self
    }

    public func applyOutputAnchor(_ otherAnchor: AnyAnchor) {
        self.output = otherAnchor as? QLAnchor<Output> 
    }


    public func findSegments(with operationId: AnyHashable) -> [AnySegment] {
        return type(of: self).findSegments(with: operationId, fromSegment: self)
    }

    public static func findSegments(with operationId: AnyHashable, fromSegment: AnySegment,
                                    currentResults: [AnySegment] = []) -> [AnySegment] {
        let newResults = (fromSegment.operationIds.contains(operationId))
            ? [fromSegment] + currentResults
            : currentResults
        guard let next = fromSegment.inputAnchor.inputSegment else { return newResults }
        return findSegments(with: operationId, fromSegment: next, currentResults: newResults)
    }


    public func describeOperationPath() -> String {
        return type(of: self).describeOperationPath(fromSegment: self)
    }

    public static func describeOperationPath(fromSegment: AnySegment) -> String {
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

    public func operationPath() -> QLoopOperationPath {
        return type(of: self).operationPath(fromSegment: self)
    }

    public static func operationPath(fromSegment: AnySegment,
                                     _ preResults: QLoopOperationPath = []) -> QLoopOperationPath {
        let newResults = [(fromSegment.operationIds, fromSegment.hasErrorHandler)] + preResults
        guard let next = fromSegment.inputAnchor.inputSegment else { return newResults }
        return operationPath(fromSegment: next, newResults)
    }
}
