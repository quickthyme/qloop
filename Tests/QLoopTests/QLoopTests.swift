
import XCTest
import QLoop

class QLoopTests: XCTestCase {

    func test_defaultConstruction_hasCorrectDefaultSettings() {
        let loop = QLoop<Void, Void>()
        XCTAssert(loop.iterator is QLoopIteratorSingle)
        XCTAssertFalse(loop.discontinue)
    }

    func test_givenLoopWithSegments_objectReceivesFinalValue() {
        let mockComponent = MockPhoneComponent()

        mockComponent.phoneDataLoop.inputAnchor =
            QLoopLinearSegment(
                1, MockOp.VoidToStr("(210) "), output:
                QLoopLinearSegment(
                    2, MockOp.AddToStr("555-"), output:
                    QLoopLinearSegment(
                        3, MockOp.AddToStr("1212"), outputAnchor:
                        mockComponent.phoneDataLoop.outputAnchor))).inputAnchor

        mockComponent.userAction()

        XCTAssertEqual(mockComponent.userPhoneNumberField, "(210) 555-1212")
    }

    func test_loop_whenFindingSegmentsByOperationId_succeeds() {
        let seg1 = QLoopLinearSegment(1, MockOp.AddToStr("A"))
        let seg2 = QLoopLinearSegment(2, MockOp.AddToStr("B"))
        let seg3 = QLoopCompoundSegment(operations: [3:MockOp.AddToStr("C")])
        let path = QLoopPath<String, String>(seg1, seg2, seg3)!
        let loop = QLoop<String, String>()
        loop.bind(path: path)

        XCTAssertEqual(loop.findSegments(with: 1).count, 1)
        XCTAssertEqual(loop.findSegments(with: 2).count, 1)
        XCTAssertEqual(loop.findSegments(with: 3).count, 1)
    }

    func test_givenLoopWithSegments_withIteratorCountNil_losesValueBetweenIterations() {
        let mockComponent = MockProgressComponent()
        let finalAnchor = mockComponent.progressDataLoop.outputAnchor

        mockComponent.progressDataLoop.inputAnchor =
            QLoopLinearSegment(
                1, MockOp.AddToStr("#"), outputAnchor:
                finalAnchor).inputAnchor
        mockComponent.progressDataLoop.iterator = QLoopIteratorContinueNilMax(2)

        mockComponent.userAction()

        XCTAssertEqual(mockComponent.progressField, "#")
    }

    func test_givenLoopWithSegments_withIteratorCountOutput_accumulatesValueBetweenIterations() {
        let mockComponent = MockProgressComponent()
        let finalAnchor = mockComponent.progressDataLoop.outputAnchor

        mockComponent.progressDataLoop.inputAnchor =
            QLoopLinearSegment(
                1, MockOp.AddToStr("#"),
                outputAnchor: finalAnchor).inputAnchor
        mockComponent.progressDataLoop.iterator = QLoopIteratorContinueOutputMax(3)

        mockComponent.userAction()

        XCTAssertEqual(mockComponent.progressField, "###")
    }

    func test_givenShouldResumeFalse_whenInputErrorIsReceived_itPropagatesErrorToOutputAnchor_itDiscontinues() {
        let mockComponent = MockProgressComponent()
        let finalAnchor = mockComponent.progressDataLoop.outputAnchor
        mockComponent.progressDataLoop.iterator = MockLoopIterator()

        mockComponent.progressDataLoop.inputAnchor =
            QLoopLinearSegment(
                1, MockOp.StrThrowsError(QLoopError.Unknown),
                outputAnchor: finalAnchor).inputAnchor

        mockComponent.userAction()

        XCTAssert((finalAnchor.error as? QLoopError) == QLoopError.Unknown)
        XCTAssertNil(finalAnchor.input)
        XCTAssertTrue(mockComponent.progressDataLoop.discontinue)
    }

    func test_givenShouldResumeTrue_whenInputErrorIsReceived_itPropagatesErrorToOutputAnchor_itContinues() {
        let mockComponent = MockProgressComponent()
        let finalAnchor = mockComponent.progressDataLoop.outputAnchor
        mockComponent.progressDataLoop.iterator = MockLoopIterator()
        mockComponent.progressDataLoop.shouldResume = true

        mockComponent.progressDataLoop.inputAnchor =
            QLoopLinearSegment(
                1, MockOp.StrThrowsError(QLoopError.Unknown),
                outputAnchor: finalAnchor).inputAnchor

        mockComponent.userAction()

        XCTAssert((finalAnchor.error as? QLoopError) == QLoopError.Unknown)
        XCTAssertNil(finalAnchor.input)
        XCTAssertFalse(mockComponent.progressDataLoop.discontinue)
    }
}
