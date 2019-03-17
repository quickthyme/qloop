
import XCTest
import QLoop

class QLPathTests: XCTestCase {

    func test_givenTypeErasedPathBoundToLoop_objectReceivesFinalValue() {
        let mockComponent = MockPhoneComponent()

        let loopPath = QLPath<Void, String>(
            QLSerialSegment(1, MockOp.VoidToInt(5)),
            QLSerialSegment(2, MockOp.AddToInt(5)),
            QLSerialSegment(3, MockOp.IntToStr()),
            QLSerialSegment(4, MockOp.AddToStr("Z")))!

        mockComponent.phoneDataLoop.bind(path: loopPath)

        mockComponent.userAction()

        XCTAssertEqual(mockComponent.userPhoneNumberField, "10Z")
    }

    func test_givenTwoCompatibleSegments_whenTypelesslyLinked_returnsFirst_linkedToSecond() {
        let seg1 = QLSerialSegment(1, MockOp.IntToStr())
        let seg2 = QLSerialSegment(2, MockOp.AddToStr("++"))

        XCTAssertNotNil(seg1.linked(to: seg2))
        XCTAssert(seg1.output === seg2.input)
    }

    func test_givenTwoIncompatibleSegments_whenTypelesslyLinked_returnsNil() {
        let seg1 = QLSerialSegment(1, MockOp.IntToStr())
        let seg2 = QLSerialSegment(2, MockOp.IntToStr())

        XCTAssertNil(seg1.linked(to: seg2))
    }

    func test_givenSeveralCompatibleSegments_whenConstructingPath_returnsThemAllLinkedUp() {
        let seg1 = QLSerialSegment(1, MockOp.AddToStr("++"))
        let seg2 = QLSerialSegment(2, MockOp.AddToStr("--"))
        let seg3 = QLSerialSegment(3, MockOp.AddToStr("**"))
        let seg4 = QLSerialSegment(4, MockOp.AddToStr("//"))

        let path = QLPath<String, String>(seg1, seg2, seg3, seg4)

        XCTAssertNotNil(path)
        XCTAssert(seg1.output === seg2.input)
        XCTAssert(seg2.output === seg3.input)
        XCTAssert(seg3.output === seg4.input)
        seg1.input.value = nil
        XCTAssertEqual(seg4.input.value, "++--**")
    }

    func test_givenIncompatibleCompatibleSegment_whenConstructingPath_returnsNil() {
        XCTAssertNil(QLPath<String, String>(
            QLSerialSegment(1, MockOp.AddToStr("++")),
            QLSerialSegment(2, MockOp.AddToInt(9998)),
            QLSerialSegment(3, MockOp.AddToStr("**"))))
    }

    func test_path_whenFindingSegmentsByOperationId_succeeds() {
        let seg1 = QLSerialSegment(1, MockOp.AddToStr("A"))
        let seg2 = QLSerialSegment(2, MockOp.AddToStr("B"))
        let seg3 = QLParallelSegment<String, String>(
            [3.1:MockOp.AddToStr("C"),
             3.2:MockOp.AddToStr("D")])
        let seg4 = QLSerialSegment(4, MockOp.AddToStr("E"))
        let path = QLPath<String, String>(seg1, seg2, seg3, seg4)!

        XCTAssertEqual(path.findSegments(with: 1).count, 1)
        XCTAssertEqual(path.findSegments(with: 2).count, 1)
        XCTAssertEqual(path.findSegments(with: 3.1).count, 1)
        XCTAssertEqual(path.findSegments(with: 3.2).count, 1)
        XCTAssertEqual(path.findSegments(with: 4).count, 1)
    }

    func test_operation_path() {
        let seg1 = QLSerialSegment("animal", MockOp.AddToStr("!"))
        let seg2 = QLSerialSegment("vegetable", MockOp.AddToStr("@"))
        let seg3 = QLSerialSegment("mineral", MockOp.AddToStr("#"))
        let path = QLPath<String, String>(seg1, seg2, seg3)!
        let opPath = path.operationPath()

        XCTAssertEqual(opPath.map {$0.0}, [["animal"],["vegetable"],["mineral"]])
        XCTAssertEqual(opPath.map {$0.1}, [false,false,false])
    }

    func test_describe_operation_path() {
        let seg1 = QLSerialSegment("animal", MockOp.AddToStr("!"))
        let seg2 = QLSerialSegment("vegetable", MockOp.AddToStr("@"))
        let seg3 = QLSerialSegment("mineral", MockOp.AddToStr("#"))
        let path = QLPath<String, String>(seg1, seg2, seg3)!
        let opPath = path.describeOperationPath()

        XCTAssertEqual(opPath, "{animal}-{vegetable}-{mineral}")
    }
}
