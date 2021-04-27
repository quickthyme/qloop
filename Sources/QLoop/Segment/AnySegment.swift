public protocol AnySegment: AnyObject {
    var inputAnchor: AnyAnchor { get }
    var outputAnchor: AnyAnchor? { get }
    var operationIds: [AnyHashable] { get }
    var hasErrorHandler: Bool { get }
    func linked(to otherSegment: AnySegment) -> Self?
    func applyOutputAnchor(_ otherAnchor: AnyAnchor)
    func findSegments(with operationId: AnyHashable) -> [AnySegment]
    func describeOperationPath() -> String
    func operationPath() -> QLoopOperationPath
}

public typealias QLoopOperationPath = [(operationIds: [AnyHashable], hasErrorHandler: Bool)]
