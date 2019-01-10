import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(COSNumberTests.allTests),
    testCase(COSIntegerTests.allTests),
    testCase(COSFloatTests.allTests),
    testCase(PDFDocEncodingTests.allTests),
  ]
}
#endif
