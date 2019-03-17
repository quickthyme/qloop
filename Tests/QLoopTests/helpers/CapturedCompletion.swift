
import XCTest
import QLoop

class Captured<T> {
    var timesHappened: Int = 0
    var valueStream: [T?] = []
    func capture(_ value: T?) {
        self.timesHappened += 1
        self.valueStream.append(value) }
    var didHappen: Bool { return timesHappened > 0 }
    var value: T? { return valueStream.last ?? nil }
}

extension Captured {

    static func captureCompletion() -> (Captured<T>, (T?)->()) {
        let captured = Captured<T>()
        let completion: (T?)->() = {
            captured.capture($0)
        }
        return(captured, completion)
    }
}
