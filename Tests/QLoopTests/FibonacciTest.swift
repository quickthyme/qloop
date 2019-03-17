
import QLoop
import XCTest

class FibonacciTest: XCTestCase {

    func makeFibonacciLoop(iterations: Int) -> QLoop<(Int, Int), (Int, Int)> {
        let loop = QLoop<(Int, Int), (Int, Int)>(
            iterator: QLoopIteratorContinueOutputMax(iterations),
            onChange: ({ print("-- \($0!.0)") })
        )
        loop.bind(path: QLPath(makeFibonacciSegment())! )
        return loop
    }

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
        let iterations: Int = 64
        let loop = makeFibonacciLoop(iterations: iterations)
        print("fibonacci sequence (depth \(iterations)...")

        loop.perform((1,0))

        let finalValue = loop.output.value!.0
        XCTAssertEqual(finalValue , 17167680177565)
    }
}
