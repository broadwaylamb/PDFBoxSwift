import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(PDFAffineTransform2DTests.allTests),
  ]
}
#endif
