
import QLoop
import XCTest

class SpyAnchor<Input> {

    var CapturingAnchor: (Captured<Input>, QLoopAnchor<Input>) {
        let captured = Captured<Input>.captureCompletionOptional()
        let port = QLoopAnchor<Input>(onChange: captured.1)
        return(captured.0, port)
    }
}
