
import XCTest
import QLoop

class QLSegmentTests: XCTestCase {

    func test_operation_conformance() throws {
        let seg = QLSerialSegment(0x0F, MockOp.VoidToStr("a-ok"))
        var out: String?
        try seg.operation((), { out = $0 })
        XCTAssertEqual(out, "a-ok")
    }

    func test_type_erased_anchors_return_correct_anchors() {
        let seg = QLSerialSegment(0xA4, MockOp.IntToStr())
        XCTAssert(seg.inputAnchor as! QLAnchor<Int> === seg.input)
        XCTAssert(seg.outputAnchor as? QLAnchor<String> === seg.output)
    }

    func test_segment_performs_operation_on_nil_input() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, output) = SpyAnchor<String>().CapturingAnchor(expect: expect)
        let seg = QLSerialSegment("numStr", MockOp.IntToStr(),
                                     output: output)

        seg.input.value = nil

        wait(for: [expect], timeout: 8.0)
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "-1")
    }
}
