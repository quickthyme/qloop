
import XCTest
import QLoop
import Dispatch

class QLParallelSegmentTests: XCTestCase {

    func test_reveals_its_operation_ids() {

        let subject = QLParallelSegment<Void, String>(
            [0xAB:MockOp.VoidToInt(),
             0xCD:MockOp.VoidToInt()],
            combiner: nil)

        XCTAssert(subject.operationIds.contains(0xAB))
        XCTAssert(subject.operationIds.contains(0xCD))
    }

    func test_basicSegmentWithOutputAnchor_whenInputSet_itCallsCompletionWithoutResult() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, finalAnchor) = SpyAnchor<String>().CapturingAnchor(expect: expect)
        let subject = QLParallelSegment<Void, String>(
            ["genStr":MockOp.VoidToStr()],
            combiner: nil,
            output: finalAnchor)

        subject.input.value = nil

        wait(for: [expect], timeout: 8.0)
        XCTAssertTrue(captured.didHappen)
        XCTAssertNil(captured.value)
    }

    func test_givenIntToStringAndOutputAnchor_whenInputSet_itCallsCompletionWithResult() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, finalAnchor) = SpyAnchor<[String]>().CapturingAnchor(expect: expect)
        let subject = QLParallelSegment<Int, [String]>(
            ["numStr":MockOp.IntToStr()],
            combiner: (([] as [String]),
                         { r,n in r! + [n.1 as? String ?? ""] }),
            output: finalAnchor)

        subject.input.value = 3

        wait(for: [expect], timeout: 8.0)
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, ["3"])
    }

    func test_whenInputSet_repeatedly_itShouldStillOutputResults() {
        let expect = expectation(description: "shouldComplete")
        let captured = Captured<String>()
        let iterationsExpected: Int = 32
        var iterationsCounted: Int = 0
        let finalAnchor = QLAnchor<String>(onChange: ({
            captured.capture($0)
            iterationsCounted += 1
            if (iterationsCounted == iterationsExpected) {
                expect.fulfill()
            }
        }))

        let subject = QLParallelSegment<Int, String>(
            [1:MockOp.AddToInt(32),
             2:MockOp.AddToInt(24)],
            combiner: ("", { r, n in r! + "\(n.1 as? Int ?? 0)" }),
            errorHandler: nil)
        subject.output = finalAnchor

        for i in 0..<iterationsExpected {
            subject.input.value = 2 * i
        }

        wait(for: [expect], timeout: 8.0)
        XCTAssertEqual(captured.valueStream.count, 32)
        XCTAssert(captured.valueStream[0] == "2432"
            || captured.valueStream[0] == "3224")
    }

    func test_givenTwoSegments_whenInputSet_itCallsEndCompletionWithCorrectResult() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, finalAnchor) = SpyAnchor<String>().CapturingAnchor(expect: expect)
        let subject = QLParallelSegment<Int, String>(
            ["numStr":MockOp.IntToStr()],
            combiner: nil,
            outputSegment:
            QLParallelSegment<String, String>(
                ["addStr":MockOp.AddToStr(" eleven")],
                combiner: nil,
                output: finalAnchor))

        subject.input.value = 7

        wait(for: [expect], timeout: 8.0)
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, "7 eleven")
    }

    func test_givenTwoSegments_oneWithParallelOperationsAndCombiner_whenInputSet_itReduces_andCallsEndCompletionWithCorrectResult() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, finalAnchor) = SpyAnchor<Int>().CapturingAnchor(expect: expect)
        let subject = QLParallelSegment<Int, Int>(
            ["add5":MockOp.AddToInt(5),
             "add4":MockOp.AddToInt(4)],
            combiner: (0, { $0! + ($1.1 as? Int ?? 0) }),
            outputSegment: QLSerialSegment("add10", MockOp.AddToInt(10),
                                           output: finalAnchor))

        subject.input.value = 10

        wait(for: [expect], timeout: 8.0)
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value, 39)
    }

    func test_givenTwoSegments_oneWithParallelOperationsAndCombiner_withAdditionalType_whenInputSet_itReduces_andCallsEndCompletionWithCorrectResult() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, finalAnchor) = SpyAnchor<[Int]>().CapturingAnchor(expect: expect)
        let subject = QLParallelSegment<Int, [Int]>(
            ["add8":MockOp.AddToInt(8),
             "add4":MockOp.AddToInt(4)],
            combiner: ([] as [Int], { $0! + ([$1.1 as? Int ?? 0]) }),
            output: finalAnchor)

        subject.input.value = 10

        wait(for: [expect], timeout: 8.0)
        XCTAssertTrue(captured.didHappen)
        XCTAssertEqual(captured.value?.sorted(), [14,18])
    }

    func test_whenErrorThrown_itPropagatesErrorToOutputAnchor() {
        let expect = expectation(description: "shouldComplete")
        let (captured, capturedError, finalAnchor) = SpyAnchor<Int>().CapturingAnchor(expect: expect)
        let subject = QLParallelSegment<Int, Int>(
            ["numNum":MockOp.IntThrowsError(QLCommon.Error.Unknown)],
            combiner: nil,
            output: finalAnchor)

        subject.input.value = 404

        wait(for: [expect], timeout: 8.0)
        XCTAssert((capturedError.value as? QLCommon.Error) == QLCommon.Error.Unknown)
        XCTAssertNil(finalAnchor.value)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }

    func test_whenInputErrorIsReceived_itPropagatesErrorToOutputAnchor() {
        let expect = expectation(description: "shouldComplete")
        let (captured, capturedError, finalAnchor) = SpyAnchor<Int>().CapturingAnchor(expect: expect)
        let subject = QLParallelSegment<Int, Int>(
            ["numNum":MockOp.AddToInt(5)],
            combiner: nil,
            output: finalAnchor)

        subject.input.error = QLCommon.Error.Unknown

        wait(for: [expect], timeout: 8.0)
        XCTAssert((capturedError.value as? QLCommon.Error) == QLCommon.Error.Unknown)
        XCTAssertNil(finalAnchor.value)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotEqual(captured.value, 404)
    }

    func test_givenParallelSegment_withErrorHandlerSet_whenErrorThrown_itHandles() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, output) = SpyAnchor<Int>().CapturingAnchor(expect: expect)
        var err: Error? = nil
        let handler: QLParallelSegment<Int, Int>.ErrorHandler = {
            error, completion, errCompletion in
            err = error
            completion(0)
        }

        let seg1 = QLParallelSegment<Int, Int>(
            [1:MockOp.IntThrowsError(QLCommon.Error.Unknown)],
            errorHandler: handler)
        seg1.output = output

        seg1.input.value = 4

        wait(for: [expect], timeout: 8.0)
        XCTAssertNotNil(err)
        XCTAssertTrue(captured.didHappen)
    }

    func test_givenParallelSegment_withErrorHandler_whenChoosesErrorPath_outputGetsError() {
        let expect = expectation(description: "shouldComplete")
        let (captured, _, output) = SpyAnchor<Int>().CapturingAnchor(expect: expect)
        var err: Error? = nil
        let handler: QLParallelSegment<Int, Int>.ErrorHandler = {
            error, _, errCompletion in
            err = error
            errCompletion(error)
        }

        let seg1 = QLParallelSegment<Int, Int>(
            [1:MockOp.IntThrowsError(QLCommon.Error.Unknown)],
            combiner: nil,
            errorHandler: handler,
            output: output)

        seg1.input.value = 4

        wait(for: [expect], timeout: 8.0)
        XCTAssertNotNil(err)
        XCTAssertFalse(captured.didHappen)
        XCTAssertNotNil(output.error)
        XCTAssertEqual(output.error as? QLCommon.Error, QLCommon.Error.Unknown)
    }

    func test_operation_path_when_single() {
        let output = QLAnchor<String>()
        let _ = QLParallelSegment<String, String>(
            ["plus":MockOp.AddToStr("plus"),
             "minus":MockOp.AddToStr("minus")],
            combiner: nil,
            output: output)

        let last = output.inputSegment
        let opPath = last?.operationPath()

        XCTAssertNotNil(opPath?.first?.0.first {$0 as? String == "plus"})
        XCTAssertNotNil(opPath?.first?.0.first {$0 as? String == "minus"})
    }

    func test_operation_path_when_multiple() {
        let output = QLAnchor<String>()
        let _ = QLSerialSegment(
            10, MockOp.VoidToStr("One"), outputSegment:
            QLParallelSegment<String, String>(
                ["plus":MockOp.AddToStr("plus"),
                 "minus":MockOp.AddToStr("minus")],
                combiner: nil,
                outputSegment:
                QLSerialSegment(
                    12, MockOp.AddToStr("Three"),
                    output: output)))

        let last = output.inputSegment
        let opPath = last?.operationPath()

        XCTAssertEqual(opPath?[0].0, [10])
        XCTAssertNotNil(opPath?[1].0.first {$0 as? String == "plus"})
        XCTAssertNotNil(opPath?[1].0.first {$0 as? String == "minus"})
        XCTAssertEqual(opPath?[2].0, [12])
    }

    func test_describe_operation_path_when_multiple() {
        let output = QLAnchor<String>()
        let _ = QLSerialSegment(
            0x0A, MockOp.VoidToStr("One"), outputSegment:

            QLParallelSegment<String, String>(
                ["plus":MockOp.AddToStr("plus"),
                 "minus":MockOp.AddToStr("minus")],
                combiner: nil, errorHandler: nil,
                outputSegment: QLSerialSegment(
                    0x0C, MockOp.AddToStr("Three"),

                    output: output)))

        let last = output.inputSegment
        let opPath = last?.describeOperationPath()

        XCTAssertEqual(opPath, "{10}-{minus:plus}-{12}")
    }

    func test_when_starting_with_multiple_operation_queues_it_should_launch_operations_accordingly() {
        let expect = expectation(description: "expect all operations completed using correct queues")
        let utilQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        let mainQueue = DispatchQueue.main
        let output = QLAnchor<[AnyHashable:Bool]>(
            onChange: ({ _ in
                expect.fulfill()
            })
        )

        let subject = QLParallelSegment<Void, [AnyHashable:Bool]>(
            ["main":GetIsMainThread("main"),
             "util":GetIsMainThread("util")],
            combiner: ([:], { var d = $0; d?[$1.0] = ($1.1 as? Bool ?? false); return d }),
            errorHandler: nil,
            output: output)

        subject.operationQueues["main"] = mainQueue
        subject.operationQueues["util"] = utilQueue

        subject.input.value = ()

        wait(for: [expect], timeout: 8.0)
        XCTAssertEqual(output.value, ["main":true,"util":false])
    }

    private func GetIsMainThread(_ id: AnyHashable) -> QLSegment<Void, Bool>.Operation {
        return { input, completion in
            completion( Thread.current.isMainThread )
        }
    }
}

