
open class QLoopSegment<Input, Output> {
    public typealias Operation = (Input?, Completion)->()
    public typealias Completion = (Output?)->()

    open var inputAnchor: QLoopAnchor<Input> = QLoopAnchor<Input>()
    open var outputAnchor: QLoopAnchor<Output> = QLoopAnchor<Output>()
}
