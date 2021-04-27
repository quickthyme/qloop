import Dispatch

public protocol AnyAnchor: AnyObject {
    var inputSegment: AnySegment? { get }
}

public final class QLAnchor<Input>: AnyAnchor {
    public typealias OnChange = (Input?)->()
    public typealias OnError = (Error)->()

    public typealias EchoFilter = (Input?, QLAnchor<Input>) -> (Bool)
    internal static var DefaultEchoFilter: EchoFilter { return { _, _ in return true } }

    public enum Timing {
        case early, late
    }

    internal final class Repeater {

        weak var anchor: QLAnchor?

        let timing: Timing

        init(_ anchor: QLAnchor, timing: Timing) {
            self.timing = timing
            self.anchor = anchor
        }

        func echo(value: Input?, filter: EchoFilter, timing: Timing) {
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

    public func addRepeaters(_ repeaters: [QLAnchor], timing: Timing) {
        let repeaters = repeaters.map { Repeater($0, timing: timing) }
        self._repeaters.append(contentsOf: repeaters)
    }

    public func getRepeaters(timing: Timing) -> [QLAnchor] {
        return _repeaters.compactMap { ($0.timing == timing) ? $0.anchor : nil }
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
                echo(value: newValue, timing: .early)
                dispatch(value: newValue)
                echo(value: newValue, timing: .late)
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

    private func echo(value: Input?, timing: Timing) {
        for repeater in _repeaters {
            guard repeater.timing == timing else { continue }
            repeater.echo(value: value, filter: echoFilter, timing: timing)
        }
    }

    private func echo(error: Error) {
        for repeater in _repeaters {
            repeater.echo(error: error)
        }
    }
}
