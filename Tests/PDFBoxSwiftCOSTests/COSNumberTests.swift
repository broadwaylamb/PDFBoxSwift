//
//  COSNumberTests.swift
//  PDFBoxSwiftCOSTests
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

import XCTest

import PDFBoxSwift

final class COSNumberTests: XCTestCase {

  static let allTests = [
    ("testGet", testGet),
  ]

  func testGet() throws {
    // Tests a static constructor for COSNumber classes.

    // Ensure the basic static numbers are recognized
    try XCTAssertEqual(COSInteger.zero,  COSNumber.parse("0"))
    try XCTAssertEqual(COSInteger.one,   COSNumber.parse("1"))
    try XCTAssertEqual(COSInteger.two,   COSNumber.parse("2"))
    try XCTAssertEqual(COSInteger.three, COSNumber.parse("3"))

    // Test some arbitrary ints
    try XCTAssertEqual(COSInteger.get(100),   COSNumber.parse("100"))
    try XCTAssertEqual(COSInteger.get(256),   COSNumber.parse("256"))
    try XCTAssertEqual(COSInteger.get(-1000), COSNumber.parse("-1000"))
    try XCTAssertEqual(COSInteger.get(2000),  COSNumber.parse("+2000"))

    // Some arbitrary floats
    try XCTAssertEqual(COSFloat(value: 1.1),      COSNumber.parse("1.1"))
    try XCTAssertEqual(COSFloat(value: 100),      COSNumber.parse("100.0"))
    try XCTAssertEqual(COSFloat(value: -100.001), COSNumber.parse("-100.001"))

    // according to the specs the exponential shall not be used
    // but obviously there are some
    XCTAssertNoThrow(try COSNumber.parse("-2e-006"))
    XCTAssertNoThrow(try COSNumber.parse("-8e+05"))
  }
}
