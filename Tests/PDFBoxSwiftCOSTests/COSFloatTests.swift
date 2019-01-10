//
//  COSFloatTests.swift
//  PDFBoxSwiftCOSTests
//
//  Created by Sergej Jaskiewicz on 10/01/2019.
//

import XCTest

import PDFBoxSwiftCOS
import PDFBoxSwiftPDFWriter
import PDFBoxSwiftIO

final class COSFloatTests: XCTestCase {

  static let allTests = [
    ("testFloatValue", testFloatValue),
    ("testDoubleNegative", testDoubleNegative),
    ("testWritePDF", testWritePDF),
    ("testAccept", testAccept),
    ("testIntValue", testIntValue),
    ("testEquals", testEquals),
    ("testDoubleValue", testDoubleValue),
  ]

  // MARK: - Test helpers

  /// Base class to run looped tests with float numbers. To use it, derive
  /// a class and just implement `runTest()`. Then either call `runTests` for
  /// a series of random and pseudorandom tests, or `runTest` to test with
  /// corner values.
  class BaseTester {

    private let low: Int
    private let high: Int
    private let step: Int
    private let testRun: XCTestRun

    init(testRun: XCTestRun,
         low: Int = -100_000,
         high: Int = 300_000,
         step: Int = 20_000) {
      self.testRun = testRun
      self.low = low
      self.high = high
      self.step = step
    }

    final func runTests() throws {
      // deterministic test
      var lcprng = LinearCongruentialRandomNumberGenerator(seed: 123456)
      try loop(rng: &lcprng)

      // non-deterministic test
      var sprng = SystemRandomNumberGenerator()
      try loop(rng: &sprng)
    }

    private func loop<RNG: RandomNumberGenerator>(rng: inout RNG) throws {
      for i in stride(from: low, to: high, by: step) {
        let num = Float(i) * Float.random(in: 0..<1, using: &rng)
        let failureCountBefore = testRun.failureCount
        try runTest(num)
        if testRun.failureCount > failureCountBefore {
          let bitPattern = String(num.bitPattern, radix: 16, uppercase: true)
          XCTFail("random number: \(num) (bit pattern: 0x\(bitPattern))")
        }
      }
    }

    func runTest(_ num: Float) throws {
      fatalError("Must be overriden")
    }
  }

  final class EqualityTester: BaseTester {
    override func runTest(_ num: Float) throws {
      let test1 = COSFloat(value: num)
      let test2 = COSFloat(value: num)
      let test3 = COSFloat(value: num)

      // Reflexivity (x == x)
      XCTAssertEqual(test1, test1)

      // Symmetry (x == y implies y == x)
      XCTAssertEqual(test2, test3)
      XCTAssertEqual(test3, test2)

      // Transitivity (if x == y && y == z then x == z)
      XCTAssertEqual(test1, test2)
      XCTAssertEqual(test2, test3)
      XCTAssertEqual(test1, test3)

      let newFloat = Float(bitPattern: num.bitPattern + 1)
      let test4 = COSFloat(value: newFloat)
      XCTAssertNotEqual(test4, test1)
    }
  }

  final class FloatValueTester: BaseTester {
    override func runTest(_ num: Float) throws {
      let testFloat = COSFloat(value: num)
      XCTAssertEqual(num, testFloat.floatValue)
    }
  }

  final class DoubleValueTester: BaseTester {
    override func runTest(_ num: Float) throws {
      let testFloat = COSFloat(value: num)
      // compare the string representation instead of the numeric values
      // as the cast from float to double adds some more fraction digits
      XCTAssertEqual(String(num), String(testFloat.doubleValue))
    }
  }

  final class IntValueTester: BaseTester {
    override func runTest(_ num: Float) throws {
      let testFloat = COSFloat(value: num)
      XCTAssertEqual(Int(num), testFloat.intValue)
    }
  }

  final class AcceptTester: BaseTester {

    private let outStream = ByteArrayOutputStream()
    private lazy var visitor = COSWriter(outputStream: outStream)

    override func runTest(_ num: Float) throws {

      let cosFloat = COSFloat(value: num)
      try cosFloat.accept(visitor: visitor)

      XCTAssertEqual(String(cosFloat.floatValue),
                     String(decoding: outStream, as: UTF8.self))
      XCTAssertEqual(Array(String(num).utf8), outStream.bytes)
      outStream.reset()
    }
  }

  final class WritePDFTester: BaseTester {

    private let outStream = ByteArrayOutputStream()

    init(testRun: XCTestRun) {
      super.init(testRun: testRun, low: -1000, high: 3000, step: 200)
    }

    // TODO: Implement as soon as COSWriter is implemented
    override func runTest(_ num: Float) throws {

      let cosFloat = COSFloat(value: num)
      try cosFloat.writePDF(outStream)
      let decoded = String(decoding: outStream, as: UTF8.self)

      XCTAssertEqual(String(cosFloat.floatValue), decoded)
      XCTAssertEqual(String(num), decoded)
      XCTAssertEqual(Array(String(num).utf8), outStream.bytes)
      outStream.reset()
    }
  }

  // MARK: - Tests

  func testFloatValue() throws {
    try FloatValueTester(testRun: testRun!).runTests()
  }

  func testDoubleNegative() throws {
    // https://issues.apache.org/jira/browse/PDFBOX-4289
    let cosFloat = try COSFloat(string: "--16.33")
    XCTAssertEqual(-16.33, cosFloat.floatValue)
  }

  func testWritePDF() throws {
    try WritePDFTester(testRun: testRun!).runTests()
  }

  func testAccept() throws {
    try AcceptTester(testRun: testRun!).runTests()
  }

  func testIntValue() throws {
    try IntValueTester(testRun: testRun!).runTests()
  }

  func testEquals() throws {
    try EqualityTester(testRun: testRun!).runTests()
  }

  func testDoubleValue() throws {
    try DoubleValueTester(testRun: testRun!).runTests()
  }
}
