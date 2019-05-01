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
}
