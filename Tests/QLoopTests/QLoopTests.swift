
import XCTest
import QLoop

class QLoopTests: XCTestCase {

    func test_calling_perform_resets_the_iterator() {
        let mockIterator = MockLoopIterator()
        let loop = QLoop<Void, Void>(iterator: mockIterator)
        loop.perform()
        XCTAssertTrue(mockIterator.didCall_reset)
    }

    func test_calling_perform_with_input_resets_the_iterator() {
        let mockIterator = MockLoopIterator()
        let loop = QLoop<Int, Void>(iterator: mockIterator)
        loop.perform(6)
        XCTAssertTrue(mockIterator.didCall_reset)
    }

    func test_givenLoopWithSegments_outputtingNil_objectReceivesFinalNil() {
        let expect = expectation(description: "shouldComplete receive final nil")
        let mockComponent = MockPhoneComponent(expect)
        mockComponent.userPhoneNumberField = "...and then"
        mockComponent.phoneDataLoop.input =
            QLSerialSegment(
                1, MockOp.VoidToStr(nil),
                output: mockComponent.phoneDataLoop.output)
                .input

        mockComponent.userAction()

        wait(for: [expect], timeout: 8.0)
        XCTAssertEqual(mockComponent.userPhoneNumberField, "")
    }

    func test_givenLoopWithSegments_objectReceivesFinalValue() {
        let expect = expectation(description: "shouldComplete receive final value")
        let mockComponent = MockPhoneComponent(expect)

        mockComponent.phoneDataLoop.input =
            QLSerialSegment(
                1, MockOp.VoidToStr("(210) "), outputSegment:
                QLSerialSegment(
                    2, MockOp.AddToStr("555-"), outputSegment:
                    QLSerialSegment(
                        3, MockOp.AddToStr("1212"), output:
                        mockComponent.phoneDataLoop.output))).input

        mockComponent.userAction()

        wait(for: [expect], timeout: 8.0)
        XCTAssertEqual(mockComponent.userPhoneNumberField, "(210) 555-1212")
    }

    func test_loop_whenFindingSegmentsByOperationId_succeeds() {
        let seg1 = QLSerialSegment(1, MockOp.AddToStr("A"))
        let seg2 = QLSerialSegment(2, MockOp.AddToStr("B"))
        let seg3 = QLParallelSegment<String, String>(
            [3:MockOp.AddToStr("C")])
        let path = QLPath<String, String>(seg1, seg2, seg3)!
        let loop = QLoop<String, String>()
        loop.bind(path: path)

        XCTAssertEqual(loop.findSegments(with: 1).count, 1)
        XCTAssertEqual(loop.findSegments(with: 2).count, 1)
        XCTAssertEqual(loop.findSegments(with: 3).count, 1)
    }

    func test_givenLoopWithSegments_withIteratorCountNil_losesValueBetweenIterations() {
        let expect = expectation(description: "shouldComplete loses value")
        let mockComponent = MockProgressComponent()
        mockComponent.progressDataLoop.input =
            QLSerialSegment(
                1, MockOp.AddToStr("#"),
                output: mockComponent.progressDataLoop.output).input
        mockComponent.progressDataLoop.iterator = QLoopIteratorContinueNilMax(2)
        mockComponent.progressDataLoop.onFinal = ({ _ in
            expect.fulfill()
        })

        mockComponent.userAction()

        wait(for: [expect], timeout: 8.0)
        XCTAssertEqual(mockComponent.progressField, "#")
    }

    func test_givenLoopWithSegments_withIteratorCountOutput_accumulatesValueBetweenIterations() {
        let expect = expectation(description: "shouldComplete accumulates value")
        let mockComponent = MockProgressComponent()
        mockComponent.progressDataLoop.input =
            QLSerialSegment(
                1, MockOp.AddToStr("#"),
                output: mockComponent.progressDataLoop.output).input
        mockComponent.progressDataLoop.iterator = QLoopIteratorContinueOutputMax(3)
        mockComponent.progressDataLoop.onFinal = ({ _ in
            expect.fulfill()
        })

        mockComponent.userAction()

        wait(for: [expect], timeout: 8.0)
        XCTAssertEqual(mockComponent.progressField, "###")
    }

    func test_givenShouldResumeFalse_whenErrorIsReceived_itPropagatesErrorToOutputAnchor_itDiscontinues() {
        let expect = expectation(description: "shouldComplete it propagates error and discontinues")
        let mockComponent = MockProgressComponent(expect)
        mockComponent.progressDataLoop.iterator = MockLoopIterator()
        mockComponent.progressDataLoop.input =
            QLSerialSegment(
                1, MockOp.StrThrowsError(QLCommon.Error.Unknown),
                output: mockComponent.progressDataLoop.output).input

        mockComponent.userAction()

        wait(for: [expect], timeout: 8.0)
        XCTAssert((mockComponent.progressDataLoop.output.error as? QLCommon.Error) == QLCommon.Error.Unknown)
        XCTAssertNil(mockComponent.progressDataLoop.output.value)
        XCTAssertTrue(mockComponent.progressDataLoop.discontinue)
    }

    func test_givenShouldResumeTrue_whenInputErrorIsReceived_itPropagatesErrorToOutput_itContinues() {
        let expect = expectation(description: "shouldComplete it continues")
        let mockComponent = MockProgressComponent(expect)
        mockComponent.progressDataLoop.iterator = MockLoopIterator()
        mockComponent.progressDataLoop.shouldResume = true
        mockComponent.progressDataLoop.input =
            QLss(1, MockOp.StrThrowsError(QLCommon.Error.Unknown),
                 output: mockComponent.progressDataLoop.output).input

        mockComponent.userAction()

        wait(for: [expect], timeout: 8.0)
        XCTAssert((mockComponent.progressDataLoop.output.error as? QLCommon.Error) == QLCommon.Error.Unknown)
        XCTAssertNotNil(mockComponent.progressDataLoop.output.error)
        XCTAssertFalse(mockComponent.progressDataLoop.discontinue)
    }

    func test_operation_path() {
        let seg1 = QLSerialSegment("animal", MockOp.AddToStr("!"))
        let seg2 = QLSerialSegment("vegetable", MockOp.AddToStr("@"))
        let seg3 = QLSerialSegment("mineral", MockOp.AddToStr("#"))
        let loop = QLoop<String, String>()
        loop.bind(path: QLPath<String, String>(seg1, seg2, seg3)!)
        let opPath = loop.operationPath()

        XCTAssertEqual(opPath.map {$0.0}, [["animal"],["vegetable"],["mineral"]])
        XCTAssertEqual(opPath.map {$0.1}, [false,false,false])
    }

    func test_describe_operation_path() {
        let seg1 = QLSerialSegment("animal", MockOp.AddToStr("!"))
        let seg2 = QLSerialSegment("vegetable", MockOp.AddToStr("@"))
        let seg3 = QLSerialSegment("mineral", MockOp.AddToStr("#"))
        let loop = QLoop<String, String>()
        loop.bind(path: QLPath<String, String>(seg1, seg2, seg3)!)
        let opPath = loop.describeOperationPath()

        XCTAssertEqual(opPath, "{animal}-{vegetable}-{mineral}")
    }

    func test_describe_operation_path_with_error_handler() {
        let seg1 = QLSerialSegment("animal", MockOp.AddToStr("!"))
        let seg2 = QLSerialSegment("vegetable", MockOp.AddToStr("@"),
                                   errorHandler: MockOp.StrErrorHandler(false))
        let seg3 = QLSerialSegment("mineral", MockOp.AddToStr("#"))
        let loop = QLoop<String, String>()
        loop.bind(path: QLPath<String, String>(seg1, seg2, seg3)!)
        let opPath = loop.describeOperationPath()

        XCTAssertEqual(opPath, "{animal}-{vegetable*}-{mineral}")
    }

    func test_when_destroy_is_called_then_it_should_have_no_path() {
        let loop = QLoop<String, String>()
        loop.bind(path: QLPath<String, String>(
            QLSerialSegment("who", MockOp.AddToStr("me")),
            QLSerialSegment("why", MockOp.AddToStr("yes")),
            QLSerialSegment("wrd", MockOp.AddToStr("huh")))!)
        XCTAssertEqual(loop.describeOperationPath(), "{who}-{why}-{wrd}")
        loop.destroy()
        XCTAssertEqual(loop.describeOperationPath(), "")
    }
}

