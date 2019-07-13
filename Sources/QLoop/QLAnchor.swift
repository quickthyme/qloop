import Dispatch

public protocol AnyAnchor: class {
    var inputSegment: AnySegment? { get }
}

public final class QLAnchor<Input>: AnyAnchor {
    public typealias OnChange = (Input?)->()
    public typealias OnError = (Error)->()

    public typealias EchoFilter = (Input?, QLAnchor<Input>) -> (Bool)
    internal static var DefaultEchoFilter: EchoFilter { return { _, _ in return true } }

    internal final class Repeater {
        weak var anchor: QLAnchor?
        init(_ anchor: QLAnchor) {
            self.anchor = anchor
        }
        func echo(value: Input?, filter: EchoFilter) {
            if let repeater = self.anchor,
                filter(value, repeater) {
                repeater.value = value
            }
        }
        func echo(error: Error) {
            anchor?.error = error
        }
    }

    lazy var inputQueue = DispatchQueue(label: "\(self).inputQueue",
                                        qos: .userInitiated)

    public required init(onChange: @escaping OnChange,
                         onError: @escaping OnError) {
        self.onChange = onChange
        self.onError = onError
    }

    public var onChange: OnChange

    public var onError: OnError

    public var inputSegment: AnySegment?

    public var repeaters: [QLAnchor] {
        get { return _repeaters.compactMap { $0.anchor } }
        set { self._repeaters = newValue.map { Repeater($0) } }
    }

    internal var _repeaters: [Repeater] = []

    public var echoFilter: EchoFilter = DefaultEchoFilter

    private var _value: Input?
    public var value: Input? {
        get {
            var safeInput: Input? = nil
            inputQueue.sync { safeInput = self._value }
            return safeInput
        }
        set {
            inputQueue.sync { self._value = newValue }

            if let err = getReroutableError(newValue) {
                self.error = err
            } else {
                dispatch(value: newValue)
                echo(value: newValue)
            }

            if (QLCommon.Config.Anchor.releaseValues) {
                inputQueue.sync { self._value = nil }
            }
        }
    }

    private var _error: Error?
    public var error: Error? {
        get {
            var safeError: Error? = nil
            inputQueue.sync { safeError = self._error }
            return safeError
        }
        set {
            let err: Error = newValue ?? QLCommon.Error.ThrownButNotSet
            inputQueue.sync { self._error = err }
            dispatch(error: err)
            echo(error: err)

            if (QLCommon.Config.Anchor.releaseValues) {
                inputQueue.sync { self._error = nil }
            }
        }
    }

    private func getReroutableError(_ newValue: Input?) -> Error? {
        guard QLCommon.Config.Anchor.autoThrowResultFailures,
            let errGettable = newValue as? ErrorGettable,
            let err = errGettable.getError()
            else { return nil }
        return err
    }

    private func dispatch(value: Input?) {
        DispatchQueue.main.async {
            self.onChange(value)
        }
    }

    private func dispatch(error: Error) {
        DispatchQueue.main.async {
            self.onError(error)
        }
    }

    private func echo(value: Input?) {
        for repeater in _repeaters {
            repeater.echo(value: value, filter: echoFilter)
        }
    }

    private func echo(error: Error) {
        for repeater in _repeaters {
            repeater.echo(error: error)
        }
    }
}
