import XCTest

import PDFBoxSwiftCOSTests
import PDFBoxSwiftUtilTests

var tests = [XCTestCaseEntry]()
tests += PDFBoxSwiftCOSTests.allTests()
tests += PDFBoxSwiftUtilTests.allTests()

XCTMain(tests)
