//
//  BitSetTests.swift
//  PDFBoxSwiftUtilTests
//
//  Created by Sergej Jaskiewicz on 15/01/2019.
//

import XCTest
@testable import PDFBoxSwift

final class BitSetTests: XCTestCase {

  static let allTests = [
    ("testEmpty", testEmpty),
    ("testSubscript", testSubscript),
    ("testSetRange", testSetRange),
  ]

  func testEmpty() {

    let set = BitSet()

    XCTAssertEqual(set.count, 0)
    XCTAssertTrue(set.isEmpty)

    for i in 0..<10000 {
      XCTAssertFalse(set[i])
    }
  }

  func testSubscript() {

    var set = BitSet()

    set[10] = true

    XCTAssertTrue(set[10])
    XCTAssertEqual(set.count, 11)
    XCTAssertFalse(set.isEmpty)

    set[5] = true
    set[1234] = true

    XCTAssertTrue(set[10])
    XCTAssertTrue(set[5])
    XCTAssertTrue(set[1234])
    XCTAssertEqual(set.count, 1235)
    XCTAssertFalse(set.isEmpty)

    var numberOfTrueBits = 0
    for i in 0..<set.count * 2 where set[i] {
      numberOfTrueBits += 1
    }

    XCTAssertEqual(numberOfTrueBits, 3)

    set[5] = false
    XCTAssertTrue(set[10])
    XCTAssertFalse(set[5])
    XCTAssertTrue(set[1234])
    XCTAssertEqual(set.count, 1235)
    XCTAssertFalse(set.isEmpty)

    numberOfTrueBits = 0
    for i in 0..<set.count * 2 where set[i] {
      numberOfTrueBits += 1
    }

    XCTAssertEqual(numberOfTrueBits, 2)

    set[1234] = false

    XCTAssertEqual(set.count, 11)
  }

  func testSetRange() {

    var set = BitSet()
    let range = 26..<27361
    set.set(range)

    XCTAssertEqual(set.count, 27361)

    var numberOfTrueBits = 0
    for i in 0..<set.count * 2 where set[i] {
      numberOfTrueBits += 1
    }

    XCTAssertEqual(numberOfTrueBits, range.count)

    set.set(2..<1000)

    XCTAssertEqual(set.count, 27361)

    numberOfTrueBits = 0
    for i in 0..<set.count * 2 where set[i] {
      numberOfTrueBits += 1
    }

    XCTAssertEqual(numberOfTrueBits, 27359)

    set.clear()

    XCTAssertEqual(set.count, 0)

    set.set(20..<30)

    XCTAssertEqual(set.count, 30)

    numberOfTrueBits = 0
    for i in 0..<set.count * 2 where set[i] {
      numberOfTrueBits += 1
    }

    XCTAssertEqual(numberOfTrueBits, 10)
  }
}
