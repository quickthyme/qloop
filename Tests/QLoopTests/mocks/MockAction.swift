
import QLoop

class MockAction {

    static func IntToStr() -> QLoopSegment<Int, String>.Action {
        return { input, compl in compl("\(input ?? -1)") }
    }

    static func AddToStr(_ value: String) -> QLoopSegment<String, String>.Action {
        return { input, compl in compl((input ?? "") + value) }
    }

    static func VoidToString(_ value: String? = nil) -> QLoopSegment<Void, String>.Action {
        return { input, compl in compl(value) }
    }
}
