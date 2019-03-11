
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
                                      errorHandler: handler,
                                      outputAnchor: outputAnchor)

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
}
