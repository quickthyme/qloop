
import XCTest
import QLoop

final class QLAnchorTests: XCTestCase {

    func test_using_default_constructor_can_still_set_onChange_later() {
        var received: Int = -1

        let subject = QLAnchor<Int>()
        subject.onChange(nil)
        subject.onError(QLCommon.Error.Unknown)
        subject.onChange = { received = $0! }
        subject.value = 99

        XCTAssertEqual(received, 99)
    }

    func test_when_input_set_then_it_invokes_onChange() {
        var received: Int = -1

        let subject = QLAnchor<Int>(onChange: { received = $0! })
        subject.value = 99

        XCTAssertEqual(received, 99)
    }

    func test_when_error_set_then_it_invokes_onError() {
        var receivedError: Error? = nil

        let subject = QLAnchor<Int>(onChange: { _ in },
                                       onError: { receivedError = $0 })
        subject.onChange(nil)
        subject.error = QLCommon.Error.Unknown

        XCTAssert((receivedError as? QLCommon.Error) == QLCommon.Error.Unknown)
    }

    func test_when_error_set_nil_then_it_invokes_onError_with_ErrorThrownButNotSet() {
        var receivedError: Error? = nil

        let subject = QLAnchor<Int>(onChange: { _ in },
                                       onError: { receivedError = $0 })
        subject.onChange(nil)
        subject.error = nil

        XCTAssert((receivedError as? QLCommon.Error) == QLCommon.Error.ThrownButNotSet)
    }
}
