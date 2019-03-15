
import XCTest
import QLoop

class QLoopCompoundSegmentTests: XCTestCase {

    func test_reveals_its_operation_ids() {
        let subject = QLoopCompoundSegment<Void, Int>(
            [0xAB:MockOp.VoidToInt(),
             0xCD:MockOp.VoidToInt()],
            reducer: nil)

        XCTAssert(subject.operationIds.contains(0xAB))
        XCTAssert(subject.operationIds.contains(0xCD))
    }

    func test_basicSegmentWithOutputAnchor_whenInputSet_itCallsCompletionWithoutResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopCompoundSegment<Void, String>(
            ["genStr":MockOp.VoidToStr()],
            reducer: nil,
            outputAnchor: finalAnchor)

        subject.inputAnchor.value = nil

        XCTAssertTrue(captured.didHappen)
        XCTAssertNil(captured.value)
    }

    func test_givenIntToStringAndOutputAnchor_whenInputSet_itCallsCompletionWithResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopCompoundSegment<Int, String>(
            ["numStr":MockOp.IntToStr()],
            reducer: nil,
            outputAnchor: finalAnchor)

        subject.inputAnchor.value = 3

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "3")
    }

    func test_givenTwoSegments_whenInputSet_itCallsEndCompletionWithCorrectResult() {
        let (captured, finalAnchor) = SpyAnchor<String>().CapturingAnchor
        let subject = QLoopCompoundSegment<Int, String>(
            ["numStr":MockOp.IntToStr()],
            reducer: nil,
            output: QLoopCompoundSegment(
                ["addStr":MockOp.AddToStr(" eleven")],
                reducer: nil,
                outputAnchor: finalAnchor))

        subject.inputAnchor.value = 7

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "7 eleven")
    }

    func test_givenTwoSegments_oneWithCompoundOperationsAndReducer_whenInputSet_itReduces_andCallsEndCompletionWithCorrectResult() {
        let (captured, finalAnchor) = SpyAnchor<Int>().CapturingAnchor
        let subject = QLoopCompoundSegment<Int, Int>(
            ["add5":MockOp.AddToInt(5),
             "add4":MockOp.AddToInt(4)],
            reducer: (0, { $0 + ($1.1 ?? 0) }),
            output: QLoopLinearSegment("add10", MockOp.AddToInt(10),
                                       outputAnchor: finalAnchor))

        subject.inputAnchor.value = 10

        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, 39)
    }

    func test_whenErrorThrown_itPropagatesErrorToOutputAnchor() {
        let (captured, finalAnchor) = SpyAnchor<Int>().CapturingAnchor
        let subject = QLoopCompoundSegment<Int, Int>(
            ["numNum":MockOp.IntThrowsError(QLoopError.Unknown)],
            reducer: nil,
            outputAnchor: finalAnchor)

        subject.inputAnchor.value = 404

        XCTAssert((finalAnchor.error as? QLoopError) == QLoopError.Unknown)
        XCTAssertNil(finalAnchor.value)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }

    func test_whenInputErrorIsReceived_itPropagatesErrorToOutputAnchor() {
        let (captured, finalAnchor) = SpyAnchor<Int>().CapturingAnchor
        let subject = QLoopCompoundSegment<Int, Int>(
            ["numNum":MockOp.AddToInt(5)],
            reducer: nil,
            outputAnchor: finalAnchor)

        subject.inputAnchor.error = QLoopError.Unknown

        XCTAssert((finalAnchor.error as? QLoopError) == QLoopError.Unknown)
        XCTAssertNil(finalAnchor.value)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }

    func test_givenCompoundSegment_withErrorHandlerSet_whenErrorThrown_itHandles() {
        let (captured, outputAnchor) = SpyAnchor<Int>().CapturingAnchor
        var err: Error? = nil
        let handler: QLoopCompoundSegment<Int, Int>.ErrorHandler = {
            error, completion, errCompletion in
            err = error
            completion(0)
        }

        let seg1 = QLoopCompoundSegment(
            [1:MockOp.IntThrowsError(QLoopError.Unknown)],
            errorHandler: handler)
        seg1.outputAnchor = outputAnchor

        seg1.inputAnchor.value = 4
        XCTAssertNotNil(err)
        XCTAssertTrue(captured.didHappen)
    }

    func test_givenCompoundSegment_withErrorHandler_whenChoosesErrorPath_outputAnchorGetsError() {
        let (captured, outputAnchor) = SpyAnchor<Int>().CapturingAnchor
        var err: Error? = nil
        let handler: QLoopCompoundSegment<Int, Int>.ErrorHandler = {
            error, _, errCompletion in
            err = error
            errCompletion(error)
        }

        let seg1 = QLoopCompoundSegment(
            [1:MockOp.IntThrowsError(QLoopError.Unknown)],
            reducer: nil,
            errorHandler: handler,
            outputAnchor: outputAnchor)

        seg1.inputAnchor.value = 4
        XCTAssertNotNil(err)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotNil(outputAnchor.error)
        XCTAssertEqual(outputAnchor.error as? QLoopError, QLoopError.Unknown)
    }

    func test_operation_path_when_single() {
        let outputAnchor = QLoopAnchor<String>()
        let _ = QLoopCompoundSegment<String, String>(
            ["plus":MockOp.AddToStr("plus"),
             "minus":MockOp.AddToStr("minus")],
            reducer: nil,
            outputAnchor: outputAnchor)

        let last = outputAnchor.inputSegment
        let opPath = last?.operationPath()

        XCTAssertNotNil(opPath?.first?.0.first {$0 as? String == "plus"})
        XCTAssertNotNil(opPath?.first?.0.first {$0 as? String == "minus"})
    }

    func test_operation_path_when_multiple() {
        let outputAnchor = QLoopAnchor<String>()
        let _ = QLoopLinearSegment(
            10, MockOp.VoidToStr("One"), output:
            QLoopCompoundSegment<String, String>(
                ["plus":MockOp.AddToStr("plus"),
                 "minus":MockOp.AddToStr("minus")],
                reducer: nil,
                output:
                QLoopLinearSegment(
                    12, MockOp.AddToStr("Three"), outputAnchor:
                    outputAnchor)))

        let last = outputAnchor.inputSegment
        let opPath = last?.operationPath()

        XCTAssertEqual(opPath?[0].0, [10])
        XCTAssertNotNil(opPath?[1].0.first {$0 as? String == "plus"})
        XCTAssertNotNil(opPath?[1].0.first {$0 as? String == "minus"})
        XCTAssertEqual(opPath?[2].0, [12])
    }

    func test_describe_operation_path_when_multiple() {
        let outputAnchor = QLoopAnchor<String>()
        let _ = QLoopLinearSegment(
            0x0A, MockOp.VoidToStr("One"), output:
            QLoopCompoundSegment<String, String>(
                ["plus":MockOp.AddToStr("plus"),
                 "minus":MockOp.AddToStr("minus")],
                reducer: nil,
                output:
                QLoopLinearSegment(
                    0x0C, MockOp.AddToStr("Three"), outputAnchor:
                    outputAnchor)))

        let last = outputAnchor.inputSegment
        let opPath = last?.describeOperationPath()

        XCTAssertEqual(opPath, "{10}-{minus:plus}-{12}")
    }
}
