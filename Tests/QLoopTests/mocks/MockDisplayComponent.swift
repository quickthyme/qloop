
import QLoop

class MockDisplayComponent {
    lazy var getPhoneData = QLoopAnchor<Void>()
    lazy var getPhoneDataOutput = QLoopAnchor<String>(
        onChange: { self.userPhoneNumberField = $0 ?? "" }
    )

    var userPhoneNumberField: String = ""

    func userAction() {
        getPhoneData.input = ()
    }
}
