
import QLoop

class MockComponent {

    lazy var phoneDataLoop = QLoop<Void, String>(
        onChange: { self.userPhoneNumberField = $0 ?? "" }
    )
    
    var userPhoneNumberField: String = ""

    func userAction() {
        phoneDataLoop.perform()
    }
}
