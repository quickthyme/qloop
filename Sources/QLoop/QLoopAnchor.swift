
import Dispatch

fileprivate let inputQueue = DispatchQueue(label: "QLoopAnchor.InputQueue",
                                           attributes: .concurrent)

public protocol AnyLoopAnchor: class {
    var inputSegment: AnyLoopSegment? { get }
}

public final class QLoopAnchor<Input>: AnyLoopAnchor {
    public typealias OnChange = (Input?)->()
    public typealias OnError = (Error)->()

    public convenience init() {
        self.init(onChange: {_ in }, onError: {_ in })
    }

    public convenience init(onChange: @escaping OnChange) {
        self.init(onChange: onChange, onError: {_ in })
    }

    public required init(onChange: @escaping OnChange,
                         onError: @escaping OnError) {
        self.onChange = onChange
        self.onError = onError
    }

    public var input: Input? {
        get {
            var safeInput: Input? = nil
            inputQueue.sync() {
                safeInput = self._input
            }
            return safeInput
        }
        set {
            inputQueue.async(flags: .barrier) {
                self._input = newValue
            }
            self.onChange(newValue)
        }
    }
    private var _input: Input?


    public var error: Error? {
        get {
            var safeError: Error? = nil
            inputQueue.sync() {
                safeError = self._error
            }
            return safeError
        }
        set {
            let err: Error = newValue ?? QLoopError.ErrorThrownButNotSet
            inputQueue.async(flags: .barrier) {
                self._error = err
            }
            self.onError(err)
        }
    }
    private var _error: Error?

    public var onChange: OnChange
    public var onError: OnError

    public var inputSegment: AnyLoopSegment?
}
