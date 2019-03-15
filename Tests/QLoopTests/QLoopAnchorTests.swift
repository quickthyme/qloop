
import XCTest
import QLoop

final class QLoopAnchorTests: XCTestCase {

    func test_using_default_constructor_can_still_set_onChange_later() {
        var received: Int = -1

        let subject = QLoopAnchor<Int>()
        subject.onChange(nil)
        subject.onError(QLoopError.Unknown)
        subject.onChange = { received = $0! }
        subject.value = 99

        XCTAssertEqual(received, 99)
    }

    func test_when_input_set_then_it_invokes_onChange() {
        var received: Int = -1

        let subject = QLoopAnchor<Int>(onChange: { received = $0! })
        subject.value = 99

        XCTAssertEqual(received, 99)
    }

    func test_when_error_set_then_it_invokes_onError() {
        var receivedError: Error? = nil

        let subject = QLoopAnchor<Int>(onChange: { _ in },
                                       onError: { receivedError = $0 })
        subject.onChange(nil)
        subject.error = QLoopError.Unknown

        XCTAssert((receivedError as? QLoopError) == QLoopError.Unknown)
    }

    func test_when_error_set_nil_then_it_invokes_onError_with_ErrorThrownButNotSet() {
        var receivedError: Error? = nil

        let subject = QLoopAnchor<Int>(onChange: { _ in },
                                       onError: { receivedError = $0 })
        subject.onChange(nil)
        subject.error = nil

        XCTAssert((receivedError as? QLoopError) == QLoopError.ErrorThrownButNotSet)
    }
}
