import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(LinkedListTests.allTests),
    testCase(BitSetTests.allTests),
  ]
}
#endif
