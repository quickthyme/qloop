
import XCTest
import QLoop

class QLoopCompoundSegmentTests: XCTestCase {

    func test_basicSegmentWithOutputAnchor_whenInputSet_itCallsCompletionWithoutResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopCompoundSegment<Void, String>(
            operations: ["genStr":MockOp.VoidToStr()],
            reducer: nil,
            outputAnchor: finalAnchor)

        subject.inputAnchor.input = nil

        XCTAssertTrue(captured.didHappen)
        XCTAssertNil(captured.value)
    }

    func test_givenIntToStringAndOutputAnchor_whenInputSet_itCallsCompletionWithResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopCompoundSegment<Int, String>(
            operations: ["numStr":MockOp.IntToStr()],
            reducer: nil,
            outputAnchor: finalAnchor)

        subject.inputAnchor.input = 3

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "3")
    }

    func test_givenTwoSegments_whenInputSet_itCallsEndCompletionWithCorrectResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopCompoundSegment<Int, String>(
            operations: ["numStr":MockOp.IntToStr()],
            reducer: nil,
            QLoopCompoundSegment(
                operations: ["addStr":MockOp.AddToStr(" eleven")],
                reducer: nil,
                outputAnchor: finalAnchor))

        subject.inputAnchor.input = 7

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "7 eleven")
    }

    func test_givenTwoSegments_oneWithCompoundOperationsAndReducer_whenInputSet_itReduces_andCallsEndCompletionWithCorrectResult() {
        let (captured, finalAnchor) = SpyAnchor<Int>().CapturingAnchor
        let subject = QLoopCompoundSegment<Int, Int>(
            operations: ["add5":MockOp.AddToInt(5),
                         "add4":MockOp.AddToInt(4)],
            reducer: (0, { $0 + ($1.1 ?? 0) }),
            QLoopLinearSegment(MockOp.AddToInt(10), finalAnchor))

        subject.inputAnchor.input = 10

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, 39)
    }

    func test_whenErrorThrown_itPropagatesErrorToOutputAnchor() {
        let (captured, finalAnchor) = SpyAnchor<Int>().CapturingAnchor
        let subject = QLoopCompoundSegment<Int, Int>(
            operations: ["numNum":MockOp.IntThrowsError(QLoopError.Unknown)],
            reducer: nil,
            outputAnchor: finalAnchor)

        subject.inputAnchor.input = 404

        XCTAssert((finalAnchor.error as? QLoopError) == QLoopError.Unknown)
        XCTAssertNil(finalAnchor.input)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }

    func test_whenInputErrorIsReceived_itPropagatesErrorToOutputAnchor() {
        let (captured, finalAnchor) = SpyAnchor<Int>().CapturingAnchor
        let subject = QLoopCompoundSegment<Int, Int>(
            operations: ["numNum":MockOp.AddToInt(5)],
            reducer: nil,
            outputAnchor: finalAnchor)

        subject.inputAnchor.error = QLoopError.Unknown

        XCTAssert((finalAnchor.error as? QLoopError) == QLoopError.Unknown)
        XCTAssertNil(finalAnchor.input)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }
}
