
import QLoop

class MockOp {

    static func IntToStr() -> QLoopSegment<Int, String>.Operation {
        return { input, compl in compl("\(input ?? -1)") }
    }

    static func AddToInt(_ value: Int) -> QLoopSegment<Int, Int>.Operation {
        return { input, compl in
            compl((input ?? 0) + value) }
    }

    static func AddToStr(_ value: String) -> QLoopSegment<String, String>.Operation {
        return { input, compl in
            compl((input ?? "") + value) }
    }

    static func VoidToStr(_ value: String? = nil) -> QLoopSegment<Void, String>.Operation {
        return { input, compl in compl(value) }
    }

    static func VoidToInt(_ value: Int? = nil) -> QLoopSegment<Void, Int>.Operation {
        return { input, compl in compl(value) }
    }

    static func IntThrowsError(_ err: QLoopError) -> QLoopSegment<Int, Int>.Operation {
        return { input, compl in throw err }
    }

    static func StrThrowsError(_ err: QLoopError) -> QLoopSegment<String, String>.Operation {
        return { input, compl in throw err }
    }
}
