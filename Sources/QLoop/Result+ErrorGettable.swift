internal protocol ErrorGettable {
    func getError() -> Error?
}

extension Result: ErrorGettable {
    func getError() -> Error? {
        if case let .failure(err) = self {
            return err
        }
        return nil
    }
}
