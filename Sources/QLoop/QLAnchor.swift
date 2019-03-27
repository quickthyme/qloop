
import Dispatch

public protocol AnyAnchor: class {
    var inputSegment: AnySegment? { get }
}

public final class QLAnchor<Input>: AnyAnchor {
    public typealias OnChange = (Input?)->()
    public typealias OnError = (Error)->()

    lazy var inputQueue = DispatchQueue(label: "\(self).inputQueue")

    public required init(onChange: @escaping OnChange,
                         onError: @escaping OnError) {
        self.onChange = onChange
        self.onError = onError
    }

    public var value: Input? {
        get {
            var safeInput: Input? = nil
            inputQueue.sync { safeInput = self._value }
            return safeInput
        }
        set {
            inputQueue.sync { self._value = newValue }
            DispatchQueue.main.async {
                self.onChange(newValue)
            }

            if (QLCommon.Config.Anchor.releaseValues) {
                inputQueue.sync { self._value = nil }
            }
        }
    }
    private var _value: Input?


    public var error: Error? {
        get {
            var safeError: Error? = nil
            inputQueue.sync { safeError = self._error }
            return safeError
        }
        set {
            let err: Error = newValue ?? QLCommon.Error.ThrownButNotSet
            inputQueue.sync { self._error = err }
            DispatchQueue.main.async {
                self.onError(err)
            }

            if (QLCommon.Config.Anchor.releaseValues) {
                inputQueue.sync { self._error = nil }
            }
        }
    }
    private var _error: Error?

    public var onChange: OnChange
    public var onError: OnError

    public var inputSegment: AnySegment?
}
