public extension QLAnchor {
    private static func emptyIn(_ o: Input?)->() {/**/}
    private static func emptyErr(_ e: Error)->() {/**/}

    convenience init() {
        self.init(onChange: QLAnchor.emptyIn,
                  onError: QLAnchor.emptyErr)
    }

    convenience init(onChange: @escaping OnChange) {
        self.init(onChange: onChange,
                  onError: QLAnchor.emptyErr)
    }

    convenience init(repeaters: QLAnchor...) {
        self.init(echoFilter: QLAnchor.DefaultEchoFilter,
                  repeaters: repeaters)
    }

    convenience init(echoFilter: @escaping EchoFilter,
                     repeaters: QLAnchor...) {
        self.init(echoFilter: echoFilter,
                  repeaters: repeaters)
    }

    convenience init(echoFilter: @escaping EchoFilter,
                     repeaters: [QLAnchor]) {
        self.init(onChange: QLAnchor.emptyIn,
                  onError: QLAnchor.emptyErr)
        self.repeaters = repeaters
        self.echoFilter = echoFilter
    }
}
