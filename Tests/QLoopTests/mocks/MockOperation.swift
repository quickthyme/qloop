
class MockOp {

    typealias VoidToIntOp = (Void?, @escaping (Int?) -> ()) throws -> ()
    typealias VoidToStrOp = (Void?, @escaping (String?) -> ()) throws -> ()

    typealias IntToIntOp = (Int?, @escaping (Int?) -> ()) throws -> ()
    typealias IntToStrOp = (Int?, @escaping (String?) -> ()) throws -> ()

    typealias StrToStrOp = (String?, @escaping (String?) -> ()) throws -> ()
    typealias StrToStrEr = (Error, @escaping (String?) -> (), @escaping (Error) -> ()) -> ()


    static func IntToStr() -> IntToStrOp {
        return { input, compl in compl("\(input ?? -1)") }
    }

    static func AddToInt(_ value: Int) -> IntToIntOp {
        return { input, compl in
            compl((input ?? 0) + value) }
    }

    static func AddToStr(_ value: String) -> StrToStrOp {
        return { input, compl in
            compl((input ?? "") + value) }
    }

    static func VoidToStr(_ value: String? = nil) -> VoidToStrOp {
        return { input, compl in compl(value) }
    }

    static func VoidToInt(_ value: Int? = nil) -> VoidToIntOp {
        return { input, compl in compl(value) }
    }

    static func IntThrowsError(_ err: Error) -> IntToIntOp {
        return { input, compl in throw err }
    }

    static func StrThrowsError(_ err: Error) -> StrToStrOp {
        return { input, compl in throw err }
    }

    static func StrErrorHandler(_ shouldRetry: Bool) -> StrToStrEr {
        return { err, compl, errCompl in
            if shouldRetry { compl("") }
            else { errCompl(err) }
        }
    }
}
