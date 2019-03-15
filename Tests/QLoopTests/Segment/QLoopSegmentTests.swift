
import XCTest
import QLoop

class QLoopSegmentTests: XCTestCase {

    func test_operation_conformance() throws {
        let seg = QLoopLinearSegment(0x0F, MockOp.VoidToStr("a-ok"))
        var out: String?
        try seg.operation((), { out = $0 })
        XCTAssertEqual(out, "a-ok")
    }

    func test_any_anchors_are_correctly_assigned() {
        let seg = QLoopLinearSegment(0xA4, MockOp.IntToStr())
        XCTAssert(seg.anyInputAnchor as! QLoopAnchor<Int> === seg.inputAnchor)
        XCTAssert(seg.anyOutputAnchor as? QLoopAnchor<String> === seg.outputAnchor)
    }

    func test_segment_performs_operation_on_nil_input() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let seg = QLoopLinearSegment("numStr", MockOp.IntToStr(),
                                     outputAnchor: finalAnchor)

        seg.inputAnchor.value = nil

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "-1")
    }
}
