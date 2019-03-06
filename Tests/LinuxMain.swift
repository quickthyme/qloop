import XCTest

import QLoopTests

var tests = [XCTestCaseEntry]()
tests += QLoopTests.allTests()
XCTMain(tests)
