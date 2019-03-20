
import QLoop
import XCTest

class MockPhoneComponent {
    init(_ expect: XCTestExpectation? = nil) {
        self.expect = expect
    }
    var expect: XCTestExpectation? = nil
    lazy var phoneDataLoop = QLoop<Void, String>(
        onChange: ({
            self.userPhoneNumberField = $0 ?? ""
            self.expect?.fulfill()
        })
    )
    var userPhoneNumberField: String = ""
    func userAction() {
        phoneDataLoop.perform()
    }
}

class MockProgressComponent {
    init(_ expect: XCTestExpectation? = nil) {
        self.expect = expect
    }
    var expect: XCTestExpectation? = nil
    lazy var progressDataLoop = QLoop<String, String>(
        iterator: QLoopIteratorContinueOutput(),
        onChange: ({
            self.progressField = $0 ?? ""
            self.expect?.fulfill()
        }),
        onError: ({ error in
            self.error = error
            self.expect?.fulfill()
        })
    )
    var progressField: String = ""
    var error: Error? = nil
    func userAction() {
        progressDataLoop.perform()
    }
}
