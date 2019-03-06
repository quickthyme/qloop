
import XCTest
import QLoop

class QLoopTests: XCTestCase {

    func test_givenLoopWithSegments_whenInputSet_objectReceivesFinalValue() {
        let mockComponent = MockComponent()

        mockComponent.phoneDataLoop.inputAnchor =
            QLoopSegment(MockOp.VoidToString("(210) "),
                         QLoopSegment(MockOp.AddToStr("555-"),
                                      QLoopSegment(MockOp.AddToStr("1212"),
                                                   mockComponent.phoneDataLoop.outputAnchor))).inputAnchor
        mockComponent.userAction()
        XCTAssertEqual(mockComponent.userPhoneNumberField, "(210) 555-1212")
    }
}
