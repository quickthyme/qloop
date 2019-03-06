
public enum QLoopIterationMode: Equatable {
    case single
    case countNil(Int)
    case countVal(Int)
    case continueNil
    case continueVal
}

public final class QLoop<Input, Output> {
    public typealias Operation = QLoopSegment<Input, Output>.Operation
    public typealias Completion = QLoopSegment<Input, Output>.Completion

    public lazy var inputAnchor: QLoopAnchor<Input> = QLoopAnchor<Input>()
    public lazy var outputAnchor: QLoopAnchor<Output> = QLoopAnchor<Output>(
        onChange: {
            self.onChange($0)
            self.iterate()
    })

    public func perform(_ input: Input? = nil) {
        inputAnchor.input = input
    }

    public var mode: QLoopIterationMode = .single

    public var discontinue: Bool = false

    public var onChange: (Output?)->()

    public convenience init() {
        self.init(mode: .single, onChange: {_ in})
    }

    public convenience init(onChange: @escaping (Output?)->()) {
        self.init(mode: .single, onChange: onChange)
    }

    public required init(mode: QLoopIterationMode,
                         onChange: @escaping (Output?)->()) {
        self.mode = mode
        self.onChange = onChange
    }

    private func iterate() {
        guard (discontinue == false)
            else { discontinue = false; return }

        switch(mode) {

        case .single:
            return

        case .countNil(let num):
            _iterations += 1
            if (_iterations < num) { self.perform() }

        case .countVal(let num):
            _iterations += 1
            if (_iterations < num) {
                self.perform(self.outputAnchor.input as? Input)
            }

        case .continueNil:
            self.perform()

        case .continueVal:
            self.perform(self.outputAnchor.input as? Input)
        }
    }
    private var _iterations: Int = 0
}
