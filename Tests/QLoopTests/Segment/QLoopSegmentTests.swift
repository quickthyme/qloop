
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

        seg.inputAnchor.input = nil

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "-1")
    }

    func test_find_segments_for_operation_succeeds_when_only() {
        let (_, finalAnchor) = SpyAnchor<String>().CapturingAnchor

        let _ = QLoopLinearSegment(1, MockOp.VoidToStr("One"),
                                   outputAnchor: finalAnchor)

        let last = finalAnchor.backwardOwner
        XCTAssertEqual(last?.findSegments(with: 1).count, 1)
    }

    func test_find_segments_for_operation_succeeds_when_mix() {
        let (_, finalAnchor) = SpyAnchor<String>().CapturingAnchor

        let _ = QLoopLinearSegment(
            0x0A, MockOp.VoidToStr("One"), output:
            QLoopLinearSegment(
                0x0B, MockOp.AddToStr("Two"), output:
                QLoopLinearSegment(
                    0x0C, MockOp.AddToStr("Three"), output:
                    QLoopLinearSegment(
                        0x0B, MockOp.AddToStr("Four"), outputAnchor:
                        finalAnchor))))

        let last = finalAnchor.backwardOwner
        XCTAssertEqual(last?.findSegments(with: 0x0A).count, 1)
        XCTAssertEqual(last?.findSegments(with: 0x0B).count, 2)
        XCTAssertEqual(last?.findSegments(with: 0x0C).count, 1)
    }

    func test_givenLinearSegment_withErrorHandlerSet_whenErrorThrown_itHandles() {
        let (captured, outputAnchor) = SpyAnchor<Int>().CapturingAnchor
        var err: Error? = nil
        let handler: QLoopLinearSegment<Int, Int>.ErrorHandler = {
            error, completion in
            err = error
            completion(0)
        }

        let seg1 = QLoopLinearSegment(1, MockOp.IntThrowsError(QLoopError.Unknown),
                                      errorHandler: handler,
                                      outputAnchor: outputAnchor)

        seg1.inputAnchor.input = 4
        XCTAssertNotNil(err)
        XCTAssertTrue(captured.didHappen)
    }

    func test_givenCompoundSegment_withErrorHandlerSet_whenErrorThrown_itHandles() {
        let (captured, outputAnchor) = SpyAnchor<Int>().CapturingAnchor
        var err: Error? = nil
        let handler: QLoopCompoundSegment<Int, Int>.ErrorHandler = {
            error, completion in
            err = error
            completion(0)
        }

        let seg1 = QLoopCompoundSegment.init(
            operations: [1:MockOp.IntThrowsError(QLoopError.Unknown)],
            reducer: nil,
            errorHandler: handler,
            outputAnchor: outputAnchor)

        seg1.inputAnchor.input = 4
        XCTAssertNotNil(err)
        XCTAssertTrue(captured.didHappen)
    }
}
