
import XCTest
import QLoop

class QLoopLinearSegmentTests: XCTestCase {

    func test_basicSegmentWithOutputAnchor_whenInputSet_itCallsCompletionWithoutResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturedAnchor

        let subject = QLoopLinearSegment<Void, String>(MockOp.VoidToStr(), finalAnchor)

        subject.inputAnchor.input = nil
        XCTAssertTrue(captured.didHappen)
        XCTAssertNil(captured.value)
    }

    func test_givenIntToStringAndOutputAnchor_whenInputSet_itCallsCompletionWithResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturedAnchor

        let subject = QLoopLinearSegment<Int, String>(MockOp.IntToStr(), finalAnchor)

        subject.inputAnchor.input = 3
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "3")
    }

    func test_givenTwoSegments_whenInputSet_itCallsEndCompletionWithCorrectResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturedAnchor

        let subject = QLoopLinearSegment(MockOp.IntToStr(),
                                         QLoopLinearSegment(MockOp.AddToStr(" eleven"),
                                                            finalAnchor))

        subject.inputAnchor.input = 7
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "7 eleven")
    }
}
