
import XCTest
import QLoop

final class QLAnchorTests: XCTestCase {

    func test_using_default_constructor_can_still_set_onChange_later() {
        var received: Int = -1
        let expect = expectation(description: "should set")

        let subject = QLAnchor<Int>()
        subject.onChange(nil)
        subject.onError(QLCommon.Error.Unknown)
        subject.onChange = { received = $0!; expect.fulfill() }
        subject.value = 99

        wait(for: [expect], timeout: 8.0)
        XCTAssertEqual(received, 99)
    }

    func test_when_input_set_then_it_invokes_onChange() {
        var received: Int = -1
        let expect = expectation(description: "should set")

        let subject = QLAnchor<Int>(onChange: { received = $0!; expect.fulfill() })
        subject.value = 99

        wait(for: [expect], timeout: 8.0)
        XCTAssertEqual(received, 99)
    }

    func test_when_error_set_then_it_invokes_onError() {
        var receivedError: Error? = nil
        let expect = expectation(description: "should set")

        let subject = QLAnchor<Int>(onChange: { _ in },
                                    onError: { receivedError = $0; expect.fulfill() })
        subject.onChange(nil)
        subject.error = QLCommon.Error.Unknown

        wait(for: [expect], timeout: 8.0)
        XCTAssert((receivedError as? QLCommon.Error) == QLCommon.Error.Unknown)
    }

    func test_when_error_set_nil_then_it_invokes_onError_with_ErrorThrownButNotSet() {
        var receivedError: Error? = nil
        let expect = expectation(description: "should set")

        let subject = QLAnchor<Int>(onChange: { _ in },
                                    onError: { receivedError = $0; expect.fulfill() })
        subject.onChange(nil)
        subject.error = nil

        wait(for: [expect], timeout: 8.0)
        XCTAssert((receivedError as? QLCommon.Error) == QLCommon.Error.ThrownButNotSet)
    }
}
