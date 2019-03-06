
import XCTest
import QLoop

class QLoopSegmentTests: XCTestCase {

    func test_basicSegmentWithOutputAnchor_whenInputSet_itCallsCompletionWithoutResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturedAnchor

        let subject = QLoopSegment<Void, String>(MockOp.VoidToStr(), finalAnchor)

        subject.inputAnchor.input = nil
        XCTAssertTrue(captured.didHappen)
        XCTAssertNil(captured.value)
    }

    func test_givenIntToStringAndOutputAnchor_whenInputSet_itCallsCompletionWithResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturedAnchor

        let subject = QLoopSegment<Int, String>(MockOp.IntToStr(), finalAnchor)

        subject.inputAnchor.input = 3
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "3")
    }

    func test_givenTwoSegments_whenInputSet_itCallsEndCompletionWithCorrectResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturedAnchor

        let subject = QLoopSegment(MockOp.IntToStr(),
                             QLoopSegment(MockOp.AddToStr(" eleven"),
                                    finalAnchor))

        subject.inputAnchor.input = 7
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "7 eleven")
    }
}
