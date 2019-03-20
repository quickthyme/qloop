
import QLoop
import XCTest

class FibonacciTest: XCTestCase {

    func makeFibonacciSegment() -> QLSegment<(Int, Int), (Int, Int)> {
        return QLSerialSegment(
            "fibonacci",
            ({
                guard let (current, prev) = $0 else { throw QLCommon.Error.Unknown }
                let new = current + prev
                $1( (new, current) )
            }))
    }

    func test_using_loop_to_generate_fibonacci_sequence() {
        let expectComplete = expectation(description: "shouldComplete")
        let iterator = QLoopIteratorContinueOutputMax(64)
        let loop = QLoop<(Int, Int), (Int, Int)>(
            iterator: iterator,
            onFinal: ({ _ in
                expectComplete.fulfill()
            }),

            onChange: ({
                print("-- \($0!.0)")
            }))

        loop.bind(path: QLPath(makeFibonacciSegment())! )

        print("fibonacci sequence depth 64...")
        loop.perform((1,0))

        wait(for: [expectComplete], timeout: 8.0)
        let finalValue = loop.output.value!.0
        XCTAssertEqual(finalValue , 17167680177565)
    }
}
