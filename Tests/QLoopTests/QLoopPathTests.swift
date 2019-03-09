
import XCTest
import QLoop

class QLoopPathTests: XCTestCase {

    func test_givenTypeErasedLoopPathWithCompatibleSegments_objectReceivesFinalValue() {
        let mockComponent = MockPhoneComponent()

        mockComponent.phoneDataLoop.inputAnchor =
            QLoopPath.inputAnchor(
                QLoopLinearSegment(MockOp.VoidToStr("X")),
                QLoopLinearSegment(MockOp.AddToStr("Y")),
                QLoopLinearSegment(MockOp.AddToStr("Z"),
                                   mockComponent.phoneDataLoop.outputAnchor))

        mockComponent.userAction()

        XCTAssertEqual(mockComponent.userPhoneNumberField, "XYZ")
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

    func test_givenSeveralCompatibleSegments_whenTypelesslyLinked_returnsThemAllChained() {
        let seg1 = QLoopLinearSegment(MockOp.AddToStr("++"))
        let seg2 = QLoopLinearSegment(MockOp.AddToStr("--"))
        let seg3 = QLoopLinearSegment(MockOp.AddToStr("**"))
        let seg4 = QLoopLinearSegment(MockOp.AddToStr("//"))

        let path = QLoopPath.inputAnchor(seg1, seg2, seg3, seg4)

        XCTAssertNotNil(path)
        XCTAssert(seg1.outputAnchor === seg2.inputAnchor)
        XCTAssert(seg2.outputAnchor === seg3.inputAnchor)
        XCTAssert(seg3.outputAnchor === seg4.inputAnchor)
        seg1.inputAnchor.input = nil
        XCTAssertEqual(seg4.inputAnchor.input, "++--**")
    }

    func x_test_givenIncompatibleCompatibleSegment_whenTypelesslyLinked_throwsFatalError() {
        QLoopPath.inputAnchor(
            QLoopLinearSegment(MockOp.AddToStr("++")),
            QLoopLinearSegment(MockOp.AddToInt(9998)),
            QLoopLinearSegment(MockOp.AddToStr("**")))
    }
}
