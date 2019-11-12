
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

    func test_when_input_set_is_result_error_then_it_invokes_onError_and_not_onChange() {
        var receivedInput: Result<Int, Error>? = nil
        var receivedError: Error? = nil
        let expect = expectation(description: "should error")
        let subject = QLAnchor<Result<Int, Error>>(onChange: { receivedInput = $0; expect.fulfill() },
                                                   onError: { receivedError = $0; expect.fulfill() })

        subject.value = .failure(QLCommon.Error.Unknown)

        wait(for: [expect], timeout: 8.0)
        XCTAssertNil(receivedInput)
        XCTAssertNotNil(receivedError)
    }

    func test_when_input_set_is_result_value_then_it_invokes_onChange_and_not_onError_like_normal() {
        var receivedInput: Result<Int, Error>? = nil
        var receivedError: Error? = nil
        let expect = expectation(description: "should value")
        let subject = QLAnchor<Result<Int, Error>>(onChange: { receivedInput = $0; expect.fulfill() },
                                                   onError: { receivedError = $0; expect.fulfill() })

        subject.value = .success(11)

        wait(for: [expect], timeout: 8.0)
        XCTAssertNotNil(receivedInput)
        XCTAssertNil(receivedError)
    }

    func test_when_error_set_then_it_invokes_onError() {
        var receivedError: Error? = nil
        let expect = expectation(description: "should set")
        let subject = QLAnchor<Int>(onChange: { _ in },
                                    onError: { receivedError = $0; expect.fulfill() })

        subject.error = QLCommon.Error.Unknown

        wait(for: [expect], timeout: 8.0)
        XCTAssert((receivedError as? QLCommon.Error) == QLCommon.Error.Unknown)
    }

    func test_when_error_set_nil_then_it_invokes_onError_with_ErrorThrownButNotSet() {
        var receivedError: Error? = nil
        let expect = expectation(description: "should set")
        let subject = QLAnchor<Int>(onChange: { _ in },
                                    onError: { receivedError = $0; expect.fulfill() })

        subject.error = nil

        wait(for: [expect], timeout: 8.0)
        XCTAssert((receivedError as? QLCommon.Error) == QLCommon.Error.ThrownButNotSet)
    }

    func test_given_it_has_early_repeaters_with_default_filter_when_input_set_then_it_echoes_to_them_as_well() {
        var receivedVal0: Int = -1
        var receivedVal1: Int = -1
        var receivedVal2: Int = -1
        let expectOriginal0 = expectation(description: "should dispatch value")
        let expectRepeater1 = expectation(description: "should echo value to repeater1")
        let expectRepeater2 = expectation(description: "should echo value to repeater2")
        let repeater1 = QLAnchor<Int>(onChange: { receivedVal1 = $0!; expectRepeater1.fulfill() })
        let repeater2 = QLAnchor<Int>(onChange: { receivedVal2 = $0!; expectRepeater2.fulfill() })
        let subject = QLAnchor<Int>(earlyRepeaters: repeater1, repeater2)
        XCTAssertEqual(subject.getRepeaters(timing: .early).count, 2)

        subject.onChange = { receivedVal0 = $0!; expectOriginal0.fulfill() }

        subject.value = 99

        wait(for: [expectOriginal0, expectRepeater1, expectRepeater2], timeout: 8.0)
        XCTAssertEqual(receivedVal0, 99)
        XCTAssertEqual(receivedVal1, 99)
        XCTAssertEqual(receivedVal2, 99)
    }

    func test_given_it_has_late_repeaters_with_default_filter_when_input_set_then_it_echoes_to_them_as_well() {
        var receivedVal0: Int = -1
        var receivedVal1: Int = -1
        var receivedVal2: Int = -1
        let expectOriginal0 = expectation(description: "should dispatch value")
        let expectRepeater1 = expectation(description: "should echo value to repeater1")
        let expectRepeater2 = expectation(description: "should echo value to repeater2")
        let repeater1 = QLAnchor<Int>(onChange: { receivedVal1 = $0!; expectRepeater1.fulfill() })
        let repeater2 = QLAnchor<Int>(onChange: { receivedVal2 = $0!; expectRepeater2.fulfill() })
        let subject = QLAnchor<Int>(lateRepeaters: repeater1, repeater2)
        XCTAssertEqual(subject.getRepeaters(timing: .late).count, 2)

        subject.onChange = { receivedVal0 = $0!; expectOriginal0.fulfill() }

        subject.value = 99

        wait(for: [expectOriginal0, expectRepeater1, expectRepeater2], timeout: 8.0)
        XCTAssertEqual(receivedVal0, 99)
        XCTAssertEqual(receivedVal1, 99)
        XCTAssertEqual(receivedVal2, 99)
    }

    func test_given_it_has_repeaters_with_default_filter_when_error_set_then_it_echoes_to_them_as_well() {
        var receivedErr0: Error? = nil
        var receivedErr1: Error? = nil
        var receivedErr2: Error? = nil
        let expectOriginal0 = expectation(description: "should dispatch error")
        let expectRepeater1 = expectation(description: "should echo error to repeater1")
        let expectRepeater2 = expectation(description: "should echo error to repeater2")
        let repeater1 = QLAnchor<Int>(onChange: { _ in },
                                      onError: { receivedErr1 = $0; expectRepeater1.fulfill() })
        let repeater2 = QLAnchor<Int>(onChange: { _ in },
                                      onError: { receivedErr2 = $0; expectRepeater2.fulfill() })
        let subject = QLAnchor<Int>(earlyRepeaters: [repeater1], lateRepeaters: [repeater2])
        XCTAssertEqual(subject.getRepeaters(timing: .early).count, 1)
        XCTAssertEqual(subject.getRepeaters(timing: .late).count, 1)

        subject.onError = { receivedErr0 = $0; expectOriginal0.fulfill() }

        subject.error = QLCommon.Error.Unknown

        wait(for: [expectOriginal0, expectRepeater1, expectRepeater2], timeout: 8.0)
        XCTAssertNotNil(receivedErr0)
        XCTAssertNotNil(receivedErr1)
        XCTAssertNotNil(receivedErr2)
    }

    func test_given_it_has_earlyRepeaters_with_custom_filter_when_input_set_then_it_dispatches_then_echoes_to_them_conditionally() {
        var receivedVal0: Int = -1
        var receivedVal1: Int = -1
        var receivedVal2: Int = -1
        let expectOriginal0 = expectation(description: "should dispatch value")
        let expectRepeater2 = expectation(description: "should echo value to repeater2")
        let repeater1 = QLAnchor<Int>(onChange: { receivedVal1 = $0! })
        let repeater2 = QLAnchor<Int>(onChange: { receivedVal2 = $0!; expectRepeater2.fulfill() })

        let subject = QLAnchor<Int>(
            echoFilter: ({ val, repeater in
                return (val == 11 && repeater === repeater1)
                    || (val == 22 && repeater === repeater2)
            }),
            earlyRepeaters: repeater1, repeater2
        )

        subject.onChange = { receivedVal0 = $0!; expectOriginal0.fulfill() }

        subject.value = 22

        wait(for: [expectOriginal0, expectRepeater2], timeout: 8.0)
        XCTAssertEqual(receivedVal0, 22)
        XCTAssertEqual(receivedVal1, -1)
        XCTAssertEqual(receivedVal2, 22)
    }

    func test_given_it_has_lateRepeaters_with_custom_filter_when_input_set_then_it_dispatches_then_echoes_to_them_conditionally() {
        var receivedVal0: Int = -1
        var receivedVal1: Int = -1
        var receivedVal2: Int = -1
        let expectOriginal0 = expectation(description: "should dispatch value")
        let expectRepeater2 = expectation(description: "should echo value to repeater2")
        let repeater1 = QLAnchor<Int>(onChange: { receivedVal1 = $0! })
        let repeater2 = QLAnchor<Int>(onChange: { receivedVal2 = $0!; expectRepeater2.fulfill() })

        let subject = QLAnchor<Int>(
            echoFilter: ({ val, repeater in
                return (val == 11 && repeater === repeater1)
                    || (val == 22 && repeater === repeater2)
            }),
            lateRepeaters: repeater1, repeater2
        )

        subject.onChange = { receivedVal0 = $0!; expectOriginal0.fulfill() }

        subject.value = 22

        wait(for: [expectOriginal0, expectRepeater2], timeout: 8.0)
        XCTAssertEqual(receivedVal0, 22)
        XCTAssertEqual(receivedVal1, -1)
        XCTAssertEqual(receivedVal2, 22)
    }
}
