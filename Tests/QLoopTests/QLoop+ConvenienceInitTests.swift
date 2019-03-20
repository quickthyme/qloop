
import XCTest
import QLoop

class QLoop_ConvenienceInitTests: XCTestCase {

    func test_qloop_constructor() {
        let loop = QLoop<Void, Void>()
        XCTAssert(loop.iterator is QLoopIteratorSingle)
        XCTAssertFalse(loop.discontinue)
    }

    func test_qloop_constructor_iterator() {
        let loop = QLoop<Void, Void>(iterator: QLoopIteratorContinueNil())
        XCTAssert(loop.iterator is QLoopIteratorContinueNil)
        XCTAssertFalse(loop.discontinue)
    }

    func test_qloop_constructor_onChange() {
        var onChangeCorrect: Bool = false
        let loop = QLoop<Void, Void>(onChange: ({ _ in onChangeCorrect = true }))
        XCTAssert(loop.iterator is QLoopIteratorSingle)
        XCTAssertFalse(loop.discontinue)
        loop.onChange(nil)
        XCTAssertTrue(onChangeCorrect)
    }

    func test_qloop_constructor_onChange_onError() {
        var onChangeCorrect: Bool = false
        var onErrorCorrect: Bool = false
        let loop = QLoop<Void, Void>(
            onChange: ({ _ in onChangeCorrect = true }),
            onError:  ({ _ in onErrorCorrect = true })
        )
        XCTAssert(loop.iterator is QLoopIteratorSingle)
        XCTAssertFalse(loop.discontinue)
        loop.onChange(nil)
        loop.onError(QLCommon.Error.ThrownButNotSet)
        XCTAssertTrue(onChangeCorrect)
        XCTAssertTrue(onErrorCorrect)
    }

    func test_qloop_constructor_iterator_onChange() {
        var onChangeCorrect: Bool = false
        let loop = QLoop<Void, Void>(
            iterator: QLoopIteratorContinueNil(),
            onChange: ({ _ in onChangeCorrect = true })
        )
        XCTAssert(loop.iterator is QLoopIteratorContinueNil)
        XCTAssertFalse(loop.discontinue)
        loop.onChange(nil)
        XCTAssertTrue(onChangeCorrect)
    }

    func test_qloop_constructor_iterator_onError() {
        var onErrorCorrect: Bool = false
        let loop = QLoop<Void, Void>(
            iterator: QLoopIteratorContinueOutputMax(1),
            onError:  ({ _ in onErrorCorrect = true })
        )
        XCTAssert(loop.iterator is QLoopIteratorContinueOutputMax)
        XCTAssertFalse(loop.discontinue)
        loop.onError(QLCommon.Error.ThrownButNotSet)
        XCTAssertTrue(onErrorCorrect)
    }

    func test_qloop_constructor_iterator_onChange_onError() {
        var onChangeCorrect: Bool = false
        var onErrorCorrect: Bool = false
        let loop = QLoop<Void, Void>(
            iterator: QLoopIteratorContinueOutputMax(1),
            onChange: ({ _ in onChangeCorrect = true }),
            onError:  ({ _ in onErrorCorrect = true })
        )
        XCTAssert(loop.iterator is QLoopIteratorContinueOutputMax)
        XCTAssertFalse(loop.discontinue)
        loop.onChange(nil)
        loop.onError(QLCommon.Error.ThrownButNotSet)
        XCTAssertTrue(onChangeCorrect)
        XCTAssertTrue(onErrorCorrect)
    }

    func test_qloop_constructor_onFinal() {
        var onFinalCorrect: Bool = false
        let loop = QLoop<Void, Void>(
            onFinal: ({ _ in onFinalCorrect = true })
        )
        XCTAssert(loop.iterator is QLoopIteratorSingle)
        XCTAssertFalse(loop.discontinue)
        loop.onFinal(nil)
        XCTAssertTrue(onFinalCorrect)
    }

    func test_qloop_constructor_iterator_onFinal() {
        var onFinalCorrect: Bool = false
        let loop = QLoop<Void, Void>(
            iterator: QLoopIteratorContinueOutput(),
            onFinal: ({ _ in onFinalCorrect = true })
            )
        XCTAssert(loop.iterator is QLoopIteratorContinueOutput)
        XCTAssertFalse(loop.discontinue)
        loop.onFinal(nil)
        XCTAssertTrue(onFinalCorrect)
    }

    func test_qloop_constructor_iterator_onFinal_onChange() {
        var onFinalCorrect: Bool = false
        var onChangeCorrect: Bool = false
        let loop = QLoop<Void, Void>(
            iterator: QLoopIteratorContinueOutput(),
            onFinal: ({ _ in onFinalCorrect = true }),
            onChange: ({ _ in onChangeCorrect = true })
        )
        XCTAssert(loop.iterator is QLoopIteratorContinueOutput)
        XCTAssertFalse(loop.discontinue)
        loop.onFinal(nil)
        loop.onChange(nil)
        XCTAssertTrue(onFinalCorrect)
        XCTAssertTrue(onChangeCorrect)
    }

    func test_qloop_constructor_iterator_onFinal_onError() {
        var onFinalCorrect: Bool = false
        var onErrorCorrect: Bool = false
        let loop = QLoop<Void, Void>(
            iterator: QLoopIteratorContinueOutput(),
            onFinal: ({ _ in onFinalCorrect = true }),
            onError:  ({ _ in onErrorCorrect = true })
        )
        XCTAssert(loop.iterator is QLoopIteratorContinueOutput)
        XCTAssertFalse(loop.discontinue)
        loop.onFinal(nil)
        loop.onError(QLCommon.Error.ThrownButNotSet)
        XCTAssertTrue(onFinalCorrect)
        XCTAssertTrue(onErrorCorrect)
    }

    func test_qloop_constructor_iterator_onFinal_onChange_onError() {
        var onFinalCorrect: Bool = false
        var onChangeCorrect: Bool = false
        var onErrorCorrect: Bool = false
        let loop = QLoop<Void, Void>(
            iterator: QLoopIteratorContinueOutput(),
            onFinal: ({ _ in onFinalCorrect = true }),
            onChange: ({ _ in onChangeCorrect = true }),
            onError:  ({ _ in onErrorCorrect = true })
        )
        XCTAssert(loop.iterator is QLoopIteratorContinueOutput)
        XCTAssertFalse(loop.discontinue)
        loop.onFinal(nil)
        loop.onChange(nil)
        loop.onError(QLCommon.Error.ThrownButNotSet)
        XCTAssertTrue(onFinalCorrect)
        XCTAssertTrue(onChangeCorrect)
        XCTAssertTrue(onErrorCorrect)
    }
}
