//
//  COSIntegerTests.swift
//  PDFBoxSwiftCOSTests
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

import XCTest
import PDFBoxSwiftCOS
import PDFBoxSwiftIO

final class COSIntegerTests: XCTestCase {

  static let allTests = [
    ("testEquals", testEquals),
    ("testHash", testHash),
    ("testFloatValue", testFloatValue),
    ("testDoubleValue", testDoubleValue),
    ("testIntValue", testIntValue),
    ("testAccept", testAccept),
    ("testWritePDF", testWritePDF)
  ]

  func testEquals() {

    for i in stride(from: -1000, to: 3000, by: 200) {
      let test1 = COSInteger.get(i)
      let test2 = COSInteger.get(i)
      let test3 = COSInteger.get(i)

      // Reflexivity (x == x)
      XCTAssertEqual(test1, test1)

      // Symmetry is preserved (x == y implies y == x)
      XCTAssertEqual(test2, test1)
      XCTAssertEqual(test1, test2)

      // Transitivity (if x == y && y == z then x == z)
      XCTAssertEqual(test1, test2)
      XCTAssertEqual(test2, test3)
      XCTAssertEqual(test1, test3)

      let test4 = COSInteger.get(i + 1)
      XCTAssertNotEqual(test4, test1)
    }
  }

  func testHash() {
    for i in stride(from: -1000, to: 3000, by: 200) {
      let test1 = COSInteger.get(i)
      let test2 = COSInteger.get(i)
      XCTAssertEqual(test1.hashValue, test2.hashValue)

      let test3 = COSInteger.get(i + 1)
      XCTAssertNotEqual(test3.hashValue, test1.hashValue)
    }
  }

  func testFloatValue() {
    for i in stride(from: -1000, to: 3000, by: 200) {
      XCTAssertEqual(Float(i), COSInteger.get(i).floatValue)
    }
  }

  func testDoubleValue() {
    for i in stride(from: -1000, to: 3000, by: 200) {
      XCTAssertEqual(Double(i), COSInteger.get(i).doubleValue)
    }
  }

  func testIntValue() {
    for i in stride(from: -1000, to: 3000, by: 200) {
      XCTAssertEqual(i, COSInteger.get(i).intValue)
    }
  }

  func testAccept() {
    // TODO: Waiting for COSWriter
  }

  func testWritePDF() throws {

    let outStream = ByteArrayOutputStream()

    for i in stride(from: -1000, to: 3000, by: 200) {
      let cosInt = COSInteger.get(i)
      try cosInt.writePDF(outStream)
      XCTAssertEqual(Array(String(i).utf8), outStream.bytes)
      outStream.reset()
    }
  }
}
