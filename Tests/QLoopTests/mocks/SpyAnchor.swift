
import QLoop
import XCTest
import Dispatch

class SpyAnchor<Input> {

    func CapturingAnchor(expect: XCTestExpectation? = nil) -> (Captured<Input>, Captured<Error>, QLAnchor<Input>) {
        let capturedCompletion = Captured<Input>.captureCompletion(expect: expect)
        let capturedError = Captured<Error>.captureCompletionNonOpt(expect: expect)
        let anchor = QLAnchor<Input>(onChange: capturedCompletion.1, onError: capturedError.1)
        return(capturedCompletion.0, capturedError.0, anchor)
    }
}
