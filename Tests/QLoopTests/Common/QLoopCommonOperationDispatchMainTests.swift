
import XCTest
import QLoop

class QLoopCommonOperationDispatchMainTests: XCTestCase {
    typealias Completion = (Int?) -> ()
    typealias ErrCompletion = (Error) -> ()
    typealias Operation = (Int?, @escaping Completion) -> ()
    typealias Handler = (Error, @escaping Completion, @escaping ErrCompletion) -> ()

    var subject: QLoopCommon.Operation.DispatchMain<Int>!

    override func setUp() {
        subject = QLoopCommon.Operation.DispatchMain()
    }

    func test_has_id() {
        XCTAssertEqual(subject.id, "main_thread")
    }

    func test_calling_operation_calls_completion_on_main_thread() throws {
        let expectDispatchMain = expectation(description: "expectDispatchMain")
        var thread: Thread? = nil
        let completion: Completion = { _ in
            thread = Thread.current;
            expectDispatchMain.fulfill()
        }

        subject.op(1, completion)

        wait(for: [expectDispatchMain], timeout: 3.0)
        XCTAssertNotNil(thread)
        XCTAssertTrue(thread?.isMainThread ?? false)
    }

    func test_calling_handler_calls_error_completion_on_main_thread() throws {
        let expectDispatchMain = expectation(description: "expectDispatchMain")
        var thread: Thread? = nil
        let completion: Completion = { _ in }
        let errCompletion: ErrCompletion = { _ in
            thread = Thread.current;
            expectDispatchMain.fulfill()
        }

        subject.err(QLoopError.Unknown, completion, errCompletion)

        wait(for: [expectDispatchMain], timeout: 3.0)
        XCTAssertNotNil(thread)
        XCTAssertTrue(thread?.isMainThread ?? false)
    }
}
