import XCTest

import PDFBoxSwiftCOSTests
import PDFBoxSwiftIOTests
import PDFBoxSwiftUtilTests

var tests = [XCTestCaseEntry]()
tests += PDFBoxSwiftCOSTests.allTests()
tests += PDFBoxSwiftIOTests.allTests()
tests += PDFBoxSwiftUtilTests.allTests()

XCTMain(tests)
