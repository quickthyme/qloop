
import XCTest
import QLoop

class QLoopCommonConfigAnchorTests: XCTestCase {

    override func tearDown() {
        QLoopCommon.Config.Anchor.releaseValues = false
        super.tearDown()
    }

    func test_when_releaseValues_is_enabled_it_remembers_value() {
        var received: Int = -1
        let subject = QLoopAnchor<Int>(onChange: { received = $0! })

        QLoopCommon.Config.Anchor.releaseValues = true
        subject.value = 99

        XCTAssertEqual(received, 99)
        XCTAssertNil(subject.value)
    }

    func test_when_releaseValues_is_enabled_it_remembers_error() {
        var received: Int? = nil
        var receivedError: Error? = nil
        let subject = QLoopAnchor<Int>(onChange: { received = $0 },
                                       onError: { receivedError = $0 })

        QLoopCommon.Config.Anchor.releaseValues = true
        subject.error = QLoopError.Unknown

        XCTAssertNil(received)
        XCTAssertEqual(receivedError as? QLoopError, QLoopError.Unknown)
        XCTAssertNil(subject.value)
        XCTAssertNil(subject.error)
    }

    func test_when_releaseValues_is_disabled_it_forgets_value() {
        var received: Int = -1
        let subject = QLoopAnchor<Int>(onChange: { received = $0! })

        QLoopCommon.Config.Anchor.releaseValues = false
        subject.value = 99

        XCTAssertEqual(received, 99)
        XCTAssertEqual(subject.value, 99)
    }

    func test_when_releaseValues_is_disabled_it_forgets_error() {
        var received: Int? = nil
        var receivedError: Error? = nil
        let subject = QLoopAnchor<Int>(onChange: { received = $0 },
                                       onError: { receivedError = $0 })

        QLoopCommon.Config.Anchor.releaseValues = false
        subject.error = QLoopError.Unknown

        XCTAssertNil(received)
        XCTAssertEqual(receivedError as? QLoopError, QLoopError.Unknown)
        XCTAssertEqual(subject.error as? QLoopError, QLoopError.Unknown)
    }
}
