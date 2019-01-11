import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(COSNumberTests.allTests),
    testCase(COSIntegerTests.allTests),
    testCase(COSFloatTests.allTests),
    testCase(COSNameTests.allTests),
    testCase(COSStringTests.allTests),
    testCase(PDFDocEncodingTests.allTests),
  ]
}
#endif
