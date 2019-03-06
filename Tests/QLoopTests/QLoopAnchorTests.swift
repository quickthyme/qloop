
import XCTest
import QLoop

final class QLoopAnchorTests: XCTestCase {

    func test_using_default_constructor_can_still_set_onChange_later() {
        var received: Int = -1
        let subject = QLoopAnchor<Int>()
        subject.onChange = { received = $0 ?? 0 }
        subject.input = 99
        XCTAssertEqual(received, 99)
    }

    func test_when_input_set_then_it_invokes_onChange() {
        var received: Int = -1
        let subject = QLoopAnchor<Int>(onChange: { received = $0 ?? 0 })
        subject.input = 99
        XCTAssertEqual(received, 99)
    }

}
