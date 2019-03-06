
public class QLoopAnchor<Input> {

    public var input: Input? {
        didSet { onChange(input) }
    }

    public var onChange: (Input?)->()

    public init() {
        self.onChange = {_ in }
    }
    public init(onChange: @escaping (Input?)->()) {
        self.onChange = onChange
    }
}
