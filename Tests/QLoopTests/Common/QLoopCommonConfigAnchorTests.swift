
import XCTest
import QLoop

class QLoopCommonConfigAnchorTests: XCTestCase {

    override func tearDown() {
        QLoopCommon.Config.Anchor.releaseValues = false
        super.tearDown()
    }

    func test_when_releaseValues_is_enable() {
        var received: Int = -1
        let subject = QLoopAnchor<Int>(onChange: { received = $0! })

        QLoopCommon.Config.Anchor.releaseValues = true
        subject.value = 99

        XCTAssertEqual(received, 99)
        XCTAssertNil(subject.value)
    }

    func test_when_releaseValues_is_disabled() {
        var received: Int = -1
        let subject = QLoopAnchor<Int>(onChange: { received = $0! })

        QLoopCommon.Config.Anchor.releaseValues = false
        subject.value = 99

        XCTAssertEqual(received, 99)
        XCTAssertEqual(subject.value, 99)
    }
}
