
public final class QLoop<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias Completion = QLoopSegment<Input, Output>.Completion

    public lazy var inputAnchor: QLoopAnchor<Input> = QLoopAnchor<Input>()
    public lazy var outputAnchor: QLoopAnchor<Output> = QLoopAnchor<Output>(
        onChange: { self.onChange($0) }
    )

    public func perform(_ input: Input? = nil) {
        inputAnchor.input = input
    }

    public var onChange: (Output?)->()

    public init() { self.onChange = {_ in } }

    public init(onChange: @escaping (Output?)->()) {
        self.onChange = onChange
    }
}
