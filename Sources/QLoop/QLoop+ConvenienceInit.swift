public extension QLoop {
    private static func emptyOut(_ o: Output?)->() {/**/}
    private static func emptyErr(_ e: Error)->() {/**/}

    convenience init() {
        self.init(iterator: QLoopIteratorSingle(),
                  onFinal: QLoop.emptyOut,
                  onChange: QLoop.emptyOut,
                  onError: QLoop.emptyErr)
    }

    convenience init(iterator: QLoopIterating) {
        self.init(iterator: iterator,
                  onFinal: QLoop.emptyOut,
                  onChange: QLoop.emptyOut,
                  onError: QLoop.emptyErr)
    }

    convenience init(onChange: @escaping OnChange) {
        self.init(iterator: QLoopIteratorSingle(),
                  onFinal: QLoop.emptyOut,
                  onChange: onChange,
                  onError: QLoop.emptyErr)
    }

    convenience init(onChange: @escaping OnChange,
                     onError: @escaping OnError) {
        self.init(iterator: QLoopIteratorSingle(),
                  onFinal: QLoop.emptyOut,
                  onChange: onChange,
                  onError: onError)
    }

    convenience init(iterator: QLoopIterating,
                     onChange: @escaping OnChange) {
        self.init(iterator: iterator,
                  onFinal: QLoop.emptyOut,
                  onChange: onChange,
                  onError: QLoop.emptyErr)
    }

    convenience init(iterator: QLoopIterating,
                     onError: @escaping OnError) {
        self.init(iterator: iterator,
                  onFinal: QLoop.emptyOut,
                  onChange: QLoop.emptyOut,
                  onError: onError)
    }

    convenience init(iterator: QLoopIterating,
                     onChange: @escaping OnChange,
                     onError: @escaping OnError) {
        self.init(iterator: iterator,
                  onFinal: QLoop.emptyOut,
                  onChange: onChange,
                  onError: onError)
    }

    convenience init(onFinal: @escaping OnChange) {
        self.init(iterator: QLoopIteratorSingle(),
                  onFinal: onFinal,
                  onChange: QLoop.emptyOut,
                  onError: QLoop.emptyErr)
    }

    convenience init(iterator: QLoopIterating,
                     onFinal: @escaping OnChange) {
        self.init(iterator: iterator,
                  onFinal: onFinal,
                  onChange: QLoop.emptyOut,
                  onError: QLoop.emptyErr)
    }

    convenience init(iterator: QLoopIterating,
                     onFinal: @escaping OnChange,
                     onChange: @escaping OnChange) {
        self.init(iterator: iterator,
                  onFinal: onFinal,
                  onChange: onChange,
                  onError: QLoop.emptyErr)
    }

    convenience init(iterator: QLoopIterating,
                     onFinal: @escaping OnChange,
                     onError: @escaping OnError) {
        self.init(iterator: iterator,
                  onFinal: onFinal,
                  onChange: QLoop.emptyOut,
                  onError: onError)
    }
}
