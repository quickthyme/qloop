
import QLoop
import XCTest

class FibonacciTest: XCTestCase {

    func test_using_loop_to_generate_fibonacci_sequence() {
        let expect = expectation(description: "should cycle 64 times")
        let loop = QLoop<(Int, Int), (Int, Int)>(
            iterator: QLoopIteratorContinueOutputMax(64),
            onFinal: ({ _ in expect.fulfill() }))

        loop.bind(segment:
            QLss("fibonacci", ({
                let (cur, pre) = $0!
                $1( (cur + pre, cur) )
            })))
        loop.perform((1,0))

        wait(for: [expect], timeout: 6.0)
        let finalValue = loop.output.value!.0
        XCTAssertEqual(finalValue , 17167680177565)
    }
}
