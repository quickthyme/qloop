
import XCTest
import QLoop

class QLoopLinearSegmentTests: XCTestCase {

    func test_basicSegmentWithOutputAnchor_whenInputSet_itCallsCompletionWithoutResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopLinearSegment<Void, String>(0, MockOp.VoidToStr(), finalAnchor)

        subject.inputAnchor.input = nil

        XCTAssertTrue(captured.didHappen)
        XCTAssertNil(captured.value)
    }

    func test_givenIntToStringAndOutputAnchor_whenInputSet_itCallsCompletionWithResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopLinearSegment<Int, String>(0, MockOp.IntToStr(), finalAnchor)

        subject.inputAnchor.input = 3

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "3")
    }

    func test_givenTwoSegments_whenInputSet_itCallsEndCompletionWithCorrectResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopLinearSegment(0, MockOp.IntToStr(),
                                         QLoopLinearSegment(0, MockOp.AddToStr(" eleven"),
                                                            finalAnchor))
        subject.inputAnchor.input = 7

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "7 eleven")
    }

    func test_whenErrorThrown_itPropagatesErrorToOutputAnchor() {
        let (captured, finalAnchor) = SpyAnchor<Int>().CapturingAnchor
        let subject = QLoopLinearSegment<Int, Int>(0, MockOp.IntThrowsError(QLoopError.Unknown), finalAnchor)

        subject.inputAnchor.input = 404

        XCTAssert((finalAnchor.error as? QLoopError) == QLoopError.Unknown)
        XCTAssertNil(finalAnchor.input)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }

    func test_whenInputErrorIsReceived_itPropagatesErrorToOutputAnchor() {
        let (captured, finalAnchor) = SpyAnchor<Int>().CapturingAnchor
        let subject = QLoopLinearSegment<Int, Int>(0, MockOp.AddToInt(5), finalAnchor)

        subject.inputAnchor.error = QLoopError.Unknown

        XCTAssert((finalAnchor.error as? QLoopError) == QLoopError.Unknown)
        XCTAssertNil(finalAnchor.input)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }
}
