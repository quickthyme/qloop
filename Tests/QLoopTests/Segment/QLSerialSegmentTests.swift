
import XCTest
import QLoop

class QLSerialSegmentTests: XCTestCase {

    func test_reveals_its_operation_ids() {
        let subject = QLSerialSegment<Void, String>(7, MockOp.VoidToStr())

        XCTAssertEqual(subject.operationIds, [7])
    }

    func test_basicSegmentWithOutputAnchor_whenInputSet_itCallsCompletionWithoutResult() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, finalAnchor) = SpyAnchor<String>().CapturingAnchor(expect: expect)
        let subject = QLSerialSegment<Void, String>(0, MockOp.VoidToStr(), output: finalAnchor)

        subject.input.value = nil

        wait(for: [expect], timeout: 8.0)
        XCTAssertTrue(captured.didHappen)
        XCTAssertNil(captured.value)
    }

    func test_givenIntToStringAndOutputAnchor_whenInputSet_itCallsCompletionWithResult() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, finalAnchor) = SpyAnchor<String>().CapturingAnchor(expect: expect)
        let subject = QLSerialSegment<Int, String>(0, MockOp.IntToStr(), output: finalAnchor)

        subject.input.value = 3

        wait(for: [expect], timeout: 8.0)
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "3")
    }

    func test_givenTwoSegments_whenInputSetNil_itShouldTriggerOperationChain() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, finalAnchor) = SpyAnchor<String>().CapturingAnchor(expect: expect)
        let subject = QLSerialSegment(0, MockOp.IntToStr(),
                                      errorHandler: nil,
                                      outputSegment: QLSerialSegment(0, MockOp.AddToStr(" eleven"),
                                                                     output: finalAnchor))
        subject.input.value = nil

        wait(for: [expect], timeout: 8.0)
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "-1 eleven")
    }

    func test_givenTwoSegments_whenInputSet_itShouldCallEndCompletionWithCorrectResult() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, finalAnchor) = SpyAnchor<String>().CapturingAnchor(expect: expect)
        let subject = QLSerialSegment(0, MockOp.IntToStr(),
                                      outputSegment: QLSerialSegment(0, MockOp.AddToStr(" eleven"),
                                                                     output: finalAnchor))
        subject.input.value = 7

        wait(for: [expect], timeout: 8.0)
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "7 eleven")
    }

    func test_whenErrorThrown_itPropagatesErrorToOutputAnchor() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, finalAnchor) = SpyAnchor<Int>().CapturingAnchor(expect: expect)
        let subject = QLSerialSegment<Int, Int>(0, MockOp.IntThrowsError(QLCommon.Error.Unknown), output: finalAnchor)

        subject.input.value = 404

        wait(for: [expect], timeout: 8.0)
        XCTAssert((finalAnchor.error as? QLCommon.Error) == QLCommon.Error.Unknown)
        XCTAssertNil(finalAnchor.value)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }

    func test_whenInputErrorIsReceived_itPropagatesErrorToOutputAnchor() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, finalAnchor) = SpyAnchor<Int>().CapturingAnchor(expect: expect)
        let subject = QLSerialSegment<Int, Int>(0, MockOp.AddToInt(5), output: finalAnchor)

        subject.input.error = QLCommon.Error.Unknown

        wait(for: [expect], timeout: 8.0)
        XCTAssert((finalAnchor.error as? QLCommon.Error) == QLCommon.Error.Unknown)
        XCTAssertNil(finalAnchor.value)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }

    func test_givenSerialSegment_withErrorHandlerSet_whenErrorThrown_itHandles() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, output) = SpyAnchor<Int>().CapturingAnchor(expect: expect)
        var err: Error? = nil
        let handler: QLSerialSegment<Int, Int>.ErrorHandler = {
            error, completion, _ in
            err = error
            completion(0)
        }

        let seg1 = QLSerialSegment(1, MockOp.IntThrowsError(QLCommon.Error.Unknown),
                                      errorHandler: handler,
                                      output: output)
        seg1.input.value = 4

        wait(for: [expect], timeout: 8.0)
        XCTAssertNotNil(err)
        XCTAssertTrue(captured.didHappen)
    }

    func test_givenSerialSegment_withErrorHandler_whenChoosesErrorPath_outputGetsError() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, output) = SpyAnchor<Int>().CapturingAnchor(expect: expect)
        var err: Error? = nil
        let handler: QLSerialSegment<Int, Int>.ErrorHandler = {
            error, _, errCompletion in
            err = error
            errCompletion(error)
        }

        let seg1 = QLSerialSegment(1, MockOp.IntThrowsError(QLCommon.Error.Unknown),
                                      errorHandler: handler,
                                      output: output)
        seg1.input.value = 4

        wait(for: [expect], timeout: 8.0)
        XCTAssertNotNil(err)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotNil(output.error)
        XCTAssertEqual(output.error as? QLCommon.Error, QLCommon.Error.Unknown)
    }

    func test_find_segments_for_operation_succeeds_when_single() {
        let (_, _, output) = SpyAnchor<String>().CapturingAnchor()

        let _ = QLSerialSegment(1, MockOp.VoidToStr("One"),
                                   output: output)
        let last = output.inputSegment

        XCTAssertEqual(last?.findSegments(with: 1).count, 1)
    }

    func test_find_segments_for_operation_succeeds_when_mix() {
        let (_, _, output) = SpyAnchor<String>().CapturingAnchor()

        let _ = QLSerialSegment(
            0x0A, MockOp.VoidToStr("One"), outputSegment:
            QLSerialSegment(
                0x0B, MockOp.AddToStr("Two"), outputSegment:
                QLSerialSegment(
                    0x0C, MockOp.AddToStr("Three"), outputSegment:
                    QLSerialSegment(
                        0x0B, MockOp.AddToStr("Four"),
                        output: output))))
        let last = output.inputSegment

        XCTAssertEqual(last?.findSegments(with: 0x0A).count, 1)
        XCTAssertEqual(last?.findSegments(with: 0x0B).count, 2)
        XCTAssertEqual(last?.findSegments(with: 0x0C).count, 1)
    }

    func test_operation_path_when_single() {
        let output = QLAnchor<String>()
        let _ = QLSerialSegment(1, MockOp.VoidToStr("One"), output: output)

        let last = output.inputSegment
        let opPath = last?.operationPath()

        XCTAssertEqual(opPath?[0].0, [1])
        XCTAssertEqual(opPath?[0].1, false)
    }

    func test_operation_path_when_multiple() {
        let output = QLAnchor<String>()
        let _ = QLSerialSegment(
            0x0A, MockOp.VoidToStr("One"), outputSegment:
            QLSerialSegment(
                0x0B, MockOp.AddToStr("Two"), outputSegment:
                QLSerialSegment(
                    0x0C, MockOp.AddToStr("Three"),
                    output: output)))

        let last = output.inputSegment
        let opPath = last?.operationPath()

        XCTAssertEqual(opPath?[0].0, [0x0A])
        XCTAssertEqual(opPath?[1].0, [0x0B])
        XCTAssertEqual(opPath?[2].0, [0x0C])
        XCTAssertEqual(opPath?[0].1, false)
        XCTAssertEqual(opPath?[1].1, false)
        XCTAssertEqual(opPath?[2].1, false)
    }

    func test_describe_operation_path_when_multiple() {
        let output = QLAnchor<String>()
        let _ = QLSerialSegment(
            "open", MockOp.VoidToStr("One"), outputSegment:
            QLSerialSegment(
                "speak", MockOp.AddToStr("Two"), outputSegment:
                QLSerialSegment(
                    "close", MockOp.AddToStr("Three"),
                    output: output)))

        let last = output.inputSegment
        let opPath = last?.describeOperationPath()

        XCTAssertEqual(opPath, "{open}-{speak}-{close}")
    }
}
