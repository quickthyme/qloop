
import XCTest
import QLoop

class QLoopPathTests: XCTestCase {

    func test_givenTypeErasedPathBoundToLoop_objectReceivesFinalValue() {
        let mockComponent = MockPhoneComponent()

        let loopPath = QLoopPath<Void, String>(
            QLoopLinearSegment(1, MockOp.VoidToInt(5)),
            QLoopLinearSegment(2, MockOp.AddToInt(5)),
            QLoopLinearSegment(3, MockOp.IntToStr()),
            QLoopLinearSegment(4, MockOp.AddToStr("Z")))!

        mockComponent.phoneDataLoop.bind(path: loopPath)

        mockComponent.userAction()

        XCTAssertEqual(mockComponent.userPhoneNumberField, "10Z")
    }

    func test_givenTwoCompatibleSegments_whenTypelesslyLinked_returnsFirst_linkedToSecond() {
        let seg1 = QLoopLinearSegment(1, MockOp.IntToStr())
        let seg2 = QLoopLinearSegment(2, MockOp.AddToStr("++"))

        XCTAssertNotNil(seg1.linked(to: seg2))
        XCTAssert(seg1.outputAnchor === seg2.inputAnchor)
    }

    func test_givenTwoIncompatibleSegments_whenTypelesslyLinked_returnsNil() {
        let seg1 = QLoopLinearSegment(1, MockOp.IntToStr())
        let seg2 = QLoopLinearSegment(2, MockOp.IntToStr())

        XCTAssertNil(seg1.linked(to: seg2))
    }

    func test_givenSeveralCompatibleSegments_whenConstructingPath_returnsThemAllLinkedUp() {
        let seg1 = QLoopLinearSegment(1, MockOp.AddToStr("++"))
        let seg2 = QLoopLinearSegment(2, MockOp.AddToStr("--"))
        let seg3 = QLoopLinearSegment(3, MockOp.AddToStr("**"))
        let seg4 = QLoopLinearSegment(4, MockOp.AddToStr("//"))

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
            QLoopLinearSegment(1, MockOp.AddToStr("++")),
            QLoopLinearSegment(2, MockOp.AddToInt(9998)),
            QLoopLinearSegment(3, MockOp.AddToStr("**"))))
    }

    func test_path_whenFindingSegmentsByOperationId_succeeds() {
        let seg1 = QLoopLinearSegment(1, MockOp.AddToStr("A"))
        let seg2 = QLoopLinearSegment(2, MockOp.AddToStr("B"))
        let seg3 = QLoopCompoundSegment(operations: [3:MockOp.AddToStr("C")])
        let seg4 = QLoopLinearSegment(4, MockOp.AddToStr("D"))
        let path = QLoopPath<String, String>(seg1, seg2, seg3, seg4)!

        XCTAssertEqual(path.findSegments(with: 1).count, 1)
        XCTAssertEqual(path.findSegments(with: 2).count, 1)
        XCTAssertEqual(path.findSegments(with: 3).count, 1)
        XCTAssertEqual(path.findSegments(with: 4).count, 1)
    }

    func test_operation_path() {
        let seg1 = QLoopLinearSegment("animal", MockOp.AddToStr("!"))
        let seg2 = QLoopLinearSegment("vegetable", MockOp.AddToStr("@"))
        let seg3 = QLoopLinearSegment("mineral", MockOp.AddToStr("#"))
        let path = QLoopPath<String, String>(seg1, seg2, seg3)!
        let opPath = path.operationPath()

        XCTAssertEqual(opPath, [["animal"],["vegetable"],["mineral"]])
    }

    func test_describe_operation_path() {
        let seg1 = QLoopLinearSegment("animal", MockOp.AddToStr("!"))
        let seg2 = QLoopLinearSegment("vegetable", MockOp.AddToStr("@"))
        let seg3 = QLoopLinearSegment("mineral", MockOp.AddToStr("#"))
        let path = QLoopPath<String, String>(seg1, seg2, seg3)!
        let opPath = path.describeOperationPath()

        XCTAssertEqual(opPath, "{animal}-{vegetable}-{mineral}")
    }
}
