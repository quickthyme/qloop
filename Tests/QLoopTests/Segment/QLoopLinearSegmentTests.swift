
import XCTest
import QLoop

class QLoopLinearSegmentTests: XCTestCase {

    func test_reveals_its_operation_ids() {
        let subject = QLoopLinearSegment<Void, String>(7, MockOp.VoidToStr())

        XCTAssertEqual(subject.operationIds, [7])
    }

    func test_basicSegmentWithOutputAnchor_whenInputSet_itCallsCompletionWithoutResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopLinearSegment<Void, String>(0, MockOp.VoidToStr(), outputAnchor: finalAnchor)

        subject.inputAnchor.input = nil

        XCTAssertTrue(captured.didHappen)
        XCTAssertNil(captured.value)
    }

    func test_givenIntToStringAndOutputAnchor_whenInputSet_itCallsCompletionWithResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopLinearSegment<Int, String>(0, MockOp.IntToStr(), outputAnchor: finalAnchor)

        subject.inputAnchor.input = 3

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "3")
    }

    func test_givenTwoSegments_whenInputSet_itCallsEndCompletionWithCorrectResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopLinearSegment(0, MockOp.IntToStr(),
                                         output: QLoopLinearSegment(0, MockOp.AddToStr(" eleven"),
                                                                    outputAnchor: finalAnchor))
        subject.inputAnchor.input = 7

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "7 eleven")
    }

    func test_whenErrorThrown_itPropagatesErrorToOutputAnchor() {
        let (captured, finalAnchor) = SpyAnchor<Int>().CapturingAnchor
        let subject = QLoopLinearSegment<Int, Int>(0, MockOp.IntThrowsError(QLoopError.Unknown), outputAnchor: finalAnchor)

        subject.inputAnchor.input = 404

        XCTAssert((finalAnchor.error as? QLoopError) == QLoopError.Unknown)
        XCTAssertNil(finalAnchor.input)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }

    func test_whenInputErrorIsReceived_itPropagatesErrorToOutputAnchor() {
        let (captured, finalAnchor) = SpyAnchor<Int>().CapturingAnchor
        let subject = QLoopLinearSegment<Int, Int>(0, MockOp.AddToInt(5), outputAnchor: finalAnchor)

        subject.inputAnchor.error = QLoopError.Unknown

        XCTAssert((finalAnchor.error as? QLoopError) == QLoopError.Unknown)
        XCTAssertNil(finalAnchor.input)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }

    func test_givenLinearSegment_withErrorHandlerSet_whenErrorThrown_itHandles() {
        let (captured, outputAnchor) = SpyAnchor<Int>().CapturingAnchor
        var err: Error? = nil
        let handler: QLoopLinearSegment<Int, Int>.ErrorHandler = {
            error, completion, _ in
            err = error
            completion(0)
        }

        let seg1 = QLoopLinearSegment(1, MockOp.IntThrowsError(QLoopError.Unknown),
                                      errorHandler: handler)
        seg1.outputAnchor = outputAnchor

        seg1.inputAnchor.input = 4
        XCTAssertNotNil(err)
        XCTAssertTrue(captured.didHappen)
    }

    func test_givenLinearSegment_withErrorHandler_whenChoosesErrorPath_outputAnchorGetsError() {
        let (captured, outputAnchor) = SpyAnchor<Int>().CapturingAnchor
        var err: Error? = nil
        let handler: QLoopLinearSegment<Int, Int>.ErrorHandler = {
            error, _, errCompletion in
            err = error
            errCompletion(error)
        }

        let seg1 = QLoopLinearSegment(1, MockOp.IntThrowsError(QLoopError.Unknown),
                                      errorHandler: handler,
                                      outputAnchor: outputAnchor)

        seg1.inputAnchor.input = 4
        XCTAssertNotNil(err)
        XCTAssertFalse(captured.didHappen)
        XCTAssertEqual(outputAnchor.error as! QLoopError, QLoopError.Unknown)
    }

    func test_find_segments_for_operation_succeeds_when_single() {
        let (_, finalAnchor) = SpyAnchor<String>().CapturingAnchor

        let _ = QLoopLinearSegment(1, MockOp.VoidToStr("One"),
                                   outputAnchor: finalAnchor)

        let last = finalAnchor.inputSegment
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

        let last = finalAnchor.inputSegment
        XCTAssertEqual(last?.findSegments(with: 0x0A).count, 1)
        XCTAssertEqual(last?.findSegments(with: 0x0B).count, 2)
        XCTAssertEqual(last?.findSegments(with: 0x0C).count, 1)
    }

    func test_operation_path_when_single() {
        let outputAnchor = QLoopAnchor<String>()
        let _ = QLoopLinearSegment(1, MockOp.VoidToStr("One"), outputAnchor: outputAnchor)

        let last = outputAnchor.inputSegment
        let opPath = last?.operationPath()

        XCTAssertEqual(opPath?[0].0, [1])
        XCTAssertEqual(opPath?[0].1, false)
    }

    func test_operation_path_when_multiple() {
        let outputAnchor = QLoopAnchor<String>()
        let _ = QLoopLinearSegment(
            0x0A, MockOp.VoidToStr("One"), output:
            QLoopLinearSegment(
                0x0B, MockOp.AddToStr("Two"), output:
                QLoopLinearSegment(
                    0x0C, MockOp.AddToStr("Three"), outputAnchor:
                    outputAnchor)))

        let last = outputAnchor.inputSegment
        let opPath = last?.operationPath()

        XCTAssertEqual(opPath?[0].0, [0x0A])
        XCTAssertEqual(opPath?[1].0, [0x0B])
        XCTAssertEqual(opPath?[2].0, [0x0C])
        XCTAssertEqual(opPath?[0].1, false)
        XCTAssertEqual(opPath?[1].1, false)
        XCTAssertEqual(opPath?[2].1, false)
    }

    func test_describe_operation_path_when_multiple() {
        let outputAnchor = QLoopAnchor<String>()
        let _ = QLoopLinearSegment(
            "open", MockOp.VoidToStr("One"), output:
            QLoopLinearSegment(
                "speak", MockOp.AddToStr("Two"), output:
                QLoopLinearSegment(
                    "close", MockOp.AddToStr("Three"), outputAnchor:
                    outputAnchor)))

        let last = outputAnchor.inputSegment
        let opPath = last?.describeOperationPath()

        XCTAssertEqual(opPath, "{open}-{speak}-{close}")
    }
}
