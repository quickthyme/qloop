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

    convenience init(earlyRepeaters: QLAnchor...) {
        self.init(echoFilter: QLAnchor.DefaultEchoFilter,
                  earlyRepeaters: earlyRepeaters,
                  lateRepeaters: [])
    }

    convenience init(lateRepeaters: QLAnchor...) {
        self.init(echoFilter: QLAnchor.DefaultEchoFilter,
                  earlyRepeaters: [],
                  lateRepeaters: lateRepeaters)
    }

    convenience init(earlyRepeaters: [QLAnchor],
                     lateRepeaters: [QLAnchor]) {
        self.init(echoFilter: QLAnchor.DefaultEchoFilter,
                  earlyRepeaters: earlyRepeaters,
                  lateRepeaters: lateRepeaters)
    }

    convenience init(echoFilter: @escaping EchoFilter,
                     earlyRepeaters: QLAnchor...) {
        self.init(echoFilter: echoFilter,
                  earlyRepeaters: earlyRepeaters,
                  lateRepeaters: [])
    }

    convenience init(echoFilter: @escaping EchoFilter,
                     lateRepeaters: QLAnchor...) {
        self.init(echoFilter: echoFilter,
                  earlyRepeaters: [],
                  lateRepeaters: lateRepeaters)
    }

    convenience init(echoFilter: @escaping EchoFilter,
                     earlyRepeaters: [QLAnchor],
                     lateRepeaters: [QLAnchor]) {
        self.init(onChange: QLAnchor.emptyIn,
                  onError: QLAnchor.emptyErr)
        self.addRepeaters(earlyRepeaters, timing: .early)
        self.addRepeaters(lateRepeaters, timing: .late)
        self.echoFilter = echoFilter
    }
}
