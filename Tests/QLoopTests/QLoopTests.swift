
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
                1, MockOp.VoidToStr("(210) "),
                QLoopLinearSegment(
                    2, MockOp.AddToStr("555-"),
                    QLoopLinearSegment(
                        3, MockOp.AddToStr("1212"),
                        mockComponent.phoneDataLoop.outputAnchor))).inputAnchor

        mockComponent.userAction()

        XCTAssertEqual(mockComponent.userPhoneNumberField, "(210) 555-1212")
    }

    func test_givenLoopWithSegments_withIteratorCountNil_losesValueBetweenIterations() {
        let mockComponent = MockProgressComponent()
        let finalAnchor = mockComponent.progressDataLoop.outputAnchor

        mockComponent.progressDataLoop.inputAnchor =
            QLoopLinearSegment(
                1, MockOp.AddToStr("#"),
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
                finalAnchor).inputAnchor
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
                finalAnchor).inputAnchor

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
                finalAnchor).inputAnchor

        mockComponent.userAction()

        XCTAssert((finalAnchor.error as? QLoopError) == QLoopError.Unknown)
        XCTAssertNil(finalAnchor.input)
        XCTAssertFalse(mockComponent.progressDataLoop.discontinue)
    }
}
