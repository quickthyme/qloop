
import QLoop

class MockPhoneComponent {
    lazy var phoneDataLoop = QLoop<Void, String>(
        onChange: { self.userPhoneNumberField = $0 ?? "" }
    )
    var userPhoneNumberField: String = ""
    func userAction() {
        phoneDataLoop.perform()
    }
}

class MockProgressComponent {
    lazy var progressDataLoop = QLoop<String, String>(
        iterator: QLoopIteratorContinueOutput(),
        onChange: { self.progressField = $0 ?? "" }
    )
    var progressField: String = ""
    func userAction() {
        progressDataLoop.perform()
    }
}
