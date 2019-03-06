
import XCTest
import QLoop

class Captured<T> {
    var didHappen: Bool = false
    var value: T?
}

extension Captured {

    static func captureCompletionOptional() -> (Captured<T>, (T?)->()) {
        let captured = Captured<T>()
        let completion: (T?)->() = {
            captured.didHappen = true
            captured.value = $0
        }
        return(captured, completion)
    }
}
