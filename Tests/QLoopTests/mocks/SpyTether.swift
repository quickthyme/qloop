
import QLoop

class SpyAnchor<Input> {

    var CapturedAnchor: (Captured<Input>, QLoopAnchor<Input>) {
        let captured = Captured<Input>.captureCompletionOptional()
        let port = QLoopAnchor<Input>(onChange: captured.1)
        return(captured.0, port)
    }
}
