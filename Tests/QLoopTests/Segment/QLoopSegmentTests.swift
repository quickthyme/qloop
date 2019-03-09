
import XCTest
import QLoop

class QLoopSegmentTests: XCTestCase {

    func test_operation_conformance() throws {
        let seg = QLoopLinearSegment(MockOp.VoidToStr("a-ok"))
        var out: String?
        try seg.operation((), { out = $0 })
        XCTAssertEqual(out, "a-ok")
    }

    func test_any_anchors_are_correctly_assigned() {
        let seg = QLoopLinearSegment(MockOp.IntToStr())
        XCTAssert(seg.anyInputAnchor as! QLoopAnchor<Int> === seg.inputAnchor)
        XCTAssert(seg.anyOutputAnchor as! QLoopAnchor<String> === seg.outputAnchor)
    }

    func test_segment_performs_operation_on_nil_input() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let seg = QLoopLinearSegment(MockOp.IntToStr(), finalAnchor)

        seg.inputAnchor.input = nil

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "-1")
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

        let path = QLoopPath(seg1, seg2, seg3, seg4)

        XCTAssertNotNil(path)
        XCTAssert(seg1.outputAnchor === seg2.inputAnchor)
        XCTAssert(seg2.outputAnchor === seg3.inputAnchor)
        XCTAssert(seg3.outputAnchor === seg4.inputAnchor)
        seg1.inputAnchor.input = nil
        XCTAssertEqual(seg4.inputAnchor.input, "++--**")
    }

    func test_givenIncompatibleCompatibleSegment_whenTypelesslyLinked_returnsBrokenPath() {
        let seg1 = QLoopLinearSegment(MockOp.AddToStr("++"))
        let seg2 = QLoopLinearSegment(MockOp.AddToInt(9998))
        let seg3 = QLoopLinearSegment(MockOp.AddToStr("**"))

        XCTAssert(QLoopPath(seg1, seg2, seg3) is QLoopBrokenPath)
    }
}
