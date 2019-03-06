
import XCTest
import QLoop

class QLoopSegmentTests: XCTestCase {

    func test_basicLoopWithSingleSegmentWithOutputAnchor_whenInputSet_itCallsCompletionWithoutResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturedAnchor

        let subject = QLoopSegment<Void, String>(MockAction.VoidToString(), finalAnchor)

        subject.inputAnchor.input = nil
        XCTAssertTrue(captured.didHappen)
        XCTAssertNil(captured.value)
    }

    func test_givenIntToStringAndOutputAnchor_whenInputSet_itCallsCompletionWithResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturedAnchor

        let subject = QLoopSegment<Int, String>(MockAction.IntToStr(), finalAnchor)

        subject.inputAnchor.input = 3
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "3")
    }

    func test_givenTwoSegmentsInLoop_whenInputSet_itCallsEndCompletionWithCorrectResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturedAnchor

        let subject = QLoopSegment(MockAction.IntToStr(),
                             QLoopSegment(MockAction.AddToStr(" eleven"),
                                    finalAnchor))

        subject.inputAnchor.input = 7
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "7 eleven")
    }

    func test_givenLoopAttachedToObjectWithInputAnchor_whenInputSet_objectReceivesFinalValue() {
        let mockComponent = MockDisplayComponent()

        mockComponent.getPhoneData =
            QLoopSegment(MockAction.VoidToString("(210) "),
                         QLoopSegment(MockAction.AddToStr("555-"),
                                      QLoopSegment(MockAction.AddToStr("1212"),
                                                   mockComponent.getPhoneDataOutput))).inputAnchor
        mockComponent.userAction()
        XCTAssertEqual(mockComponent.userPhoneNumberField, "(210) 555-1212")
    }
}
