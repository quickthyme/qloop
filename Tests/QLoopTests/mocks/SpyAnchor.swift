
import QLoop
import XCTest

class SpyAnchor<Input> {

    var CapturingAnchor: (Captured<Input>, QLAnchor<Input>) {
        let capturedCompletion = Captured<Input>.captureCompletion()
        let anchor = QLAnchor<Input>(onChange: capturedCompletion.1)
        return(capturedCompletion.0, anchor)
    }
}
