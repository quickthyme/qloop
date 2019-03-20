
public extension QLoop {
    public convenience init() {
        self.init(iterator: QLoopIteratorSingle(), onFinal: {_ in}, onChange: {_ in}, onError: {_ in})
    }

    public convenience init(iterator: QLoopIterating) {
        self.init(iterator: iterator, onFinal: {_ in}, onChange: {_ in}, onError: {_ in})
    }

    public convenience init(onChange: @escaping OnChange) {
        self.init(iterator: QLoopIteratorSingle(), onFinal: {_ in}, onChange: onChange, onError: {_ in})
    }

    public convenience init(onChange: @escaping OnChange,
                            onError: @escaping OnError) {
        self.init(iterator: QLoopIteratorSingle(), onFinal: {_ in}, onChange: onChange, onError: onError)
    }

    public convenience init(iterator: QLoopIterating,
                            onChange: @escaping OnChange) {
        self.init(iterator: iterator, onFinal: {_ in}, onChange: onChange, onError: {_ in})
    }

    public convenience init(iterator: QLoopIterating,
                            onError: @escaping OnError) {
        self.init(iterator: iterator, onFinal: {_ in}, onChange: {_ in}, onError: onError)
    }

    public convenience init(iterator: QLoopIterating,
                            onChange: @escaping OnChange,
                            onError: @escaping OnError) {
        self.init(iterator: iterator, onFinal: {_ in}, onChange: onChange, onError: onError)
    }

    public convenience init(onFinal: @escaping OnChange) {
        self.init(iterator: QLoopIteratorSingle(), onFinal: onFinal, onChange: {_ in}, onError: {_ in})
    }

    public convenience init(iterator: QLoopIterating,
                            onFinal: @escaping OnChange) {
        self.init(iterator: iterator, onFinal: onFinal, onChange: {_ in}, onError: {_ in})
    }

    public convenience init(iterator: QLoopIterating,
                            onFinal: @escaping OnChange,
                            onChange: @escaping OnChange) {
        self.init(iterator: iterator, onFinal: onFinal, onChange: onChange, onError: {_ in})
    }

    public convenience init(iterator: QLoopIterating,
                            onFinal: @escaping OnChange,
                            onError: @escaping OnError) {
        self.init(iterator: iterator, onFinal: onFinal, onChange: {_ in}, onError: onError)
    }
}
