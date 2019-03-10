
import XCTest
import QLoop

class QLoopPathTests: XCTestCase {

    func test_givenTypeErasedPathBoundToLoop_objectReceivesFinalValue() {
        let mockComponent = MockPhoneComponent()

        let loopPath = QLoopPath<Void, String>(
            QLoopLinearSegment(MockOp.VoidToInt(5)),
            QLoopLinearSegment(MockOp.AddToInt(5)),
            QLoopLinearSegment(MockOp.IntToStr()),
            QLoopLinearSegment(MockOp.AddToStr("Z")))!

        mockComponent.phoneDataLoop.bind(path: loopPath)

        mockComponent.userAction()

        XCTAssertEqual(mockComponent.userPhoneNumberField, "10Z")
    }

    func test_givenTwoCompatibleSegments_whenTypelesslyLinked_returnsFirst_linkedToSecond() {
        let seg1 = QLoopLinearSegment(MockOp.IntToStr())
        let seg2 = QLoopLinearSegment(MockOp.AddToStr("++"))

        XCTAssertNotNil(seg1.linked(to: seg2))
        XCTAssert(seg1.outputAnchor === seg2.inputAnchor)
    }

    func test_givenTwoIncompatibleSegments_whenTypelesslyLinked_returnsNil() {
        let seg1 = QLoopLinearSegment(MockOp.IntToStr())
        let seg2 = QLoopLinearSegment(MockOp.IntToStr())

        XCTAssertNil(seg1.linked(to: seg2))
    }

    func test_givenSeveralCompatibleSegments_whenConstructingPath_returnsThemAllLinkedUp() {
        let seg1 = QLoopLinearSegment(MockOp.AddToStr("++"))
        let seg2 = QLoopLinearSegment(MockOp.AddToStr("--"))
        let seg3 = QLoopLinearSegment(MockOp.AddToStr("**"))
        let seg4 = QLoopLinearSegment(MockOp.AddToStr("//"))

        let path = QLoopPath<String, String>(seg1, seg2, seg3, seg4)

        XCTAssertNotNil(path)
        XCTAssert(seg1.outputAnchor === seg2.inputAnchor)
        XCTAssert(seg2.outputAnchor === seg3.inputAnchor)
        XCTAssert(seg3.outputAnchor === seg4.inputAnchor)
        seg1.inputAnchor.input = nil
        XCTAssertEqual(seg4.inputAnchor.input, "++--**")
    }

    func test_givenIncompatibleCompatibleSegment_whenConstructingPath_returnsNil() {
        XCTAssertNil(QLoopPath<String, String>(
            QLoopLinearSegment(MockOp.AddToStr("++")),
            QLoopLinearSegment(MockOp.AddToInt(9998)),
            QLoopLinearSegment(MockOp.AddToStr("**"))))
    }
}
