
import XCTest
import QLoop

class QLoopTests: XCTestCase {

    func test_defaultConstruction_hasCorrectDefaultSettings() {
        let loop = QLoop<Void, Void>()
        XCTAssertEqual(loop.mode, QLoopIterationMode.single)
        XCTAssertFalse(loop.discontinue)
    }

    func test_givenLoopWithSegments_withModeSingle_whenInputSet_objectReceivesFinalValue() {
        let mockComponent = MockPhoneComponent()

        mockComponent.phoneDataLoop.inputAnchor =
            QLoopSegment(MockOp.VoidToStr("(210) "),
                         QLoopSegment(MockOp.AddToStr("555-"),
                                      QLoopSegment(MockOp.AddToStr("1212"),
                                                   mockComponent.phoneDataLoop.outputAnchor))).inputAnchor
        mockComponent.userAction()
        XCTAssertEqual(mockComponent.userPhoneNumberField, "(210) 555-1212")
    }

    func test_givenLoopWithSegments_withModeCountNil_losesValueBetweenIterations() {
        let mockComponent = MockProgressComponent()

        mockComponent.progressDataLoop.inputAnchor =
            QLoopSegment(MockOp.AddToStr("#"),
                         mockComponent.progressDataLoop.outputAnchor)
                .inputAnchor

        mockComponent.progressDataLoop.mode = .countNil(2)

        mockComponent.userAction()
        XCTAssertEqual(mockComponent.progressField, "#")
    }

    func test_givenLoopWithSegments_withModeCountVal_accumulatesValueBetweenIterations() {
        let mockComponent = MockProgressComponent()

        mockComponent.progressDataLoop.inputAnchor =
            QLoopSegment(MockOp.AddToStr("#"),
                         mockComponent.progressDataLoop.outputAnchor)
                .inputAnchor

        mockComponent.progressDataLoop.mode = .countVal(3)

        mockComponent.userAction()
        XCTAssertEqual(mockComponent.progressField, "###")
    }
}

