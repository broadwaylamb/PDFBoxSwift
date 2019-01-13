//
//  LinkedListTests.swift
//  PDFBoxSwiftUtilTests
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

import XCTest
@testable import PDFBoxSwift

final class LinkedListTests: XCTestCase {

  static let allTests = [
    ("testEmpty", testEmpty),
    ("testAppend", testAppend),
    ("testPrepend", testPrepend),
    ("testAppendPrepend", testAppendPrepend),
    ("testPopFirst", testPopFirst),
    ("testPopLast", testPopLast),
    ("testPopFirstPopLast", testPopFirstPopLast),
    ("testReversed", testReversed),
    ("testEqual", testEqual),
  ]

  func testEmpty() {
    let list = LinkedList<Int>()
    XCTAssertTrue(list.isEmpty)
    XCTAssertEqual(list.description, "[]")
    XCTAssertEqual(list.count, 0)
    XCTAssertEqual(list.underestimatedCount, 0)
  }

  func testAppend() {

    var list = LinkedList<Int>()
    list.append(1)
    list.append(2)
    list.append(3)
    list.append(4)

    XCTAssertFalse(list.isEmpty)
    XCTAssertEqual(list.description, "[1, 2, 3, 4]")
    XCTAssertEqual(list.count, 4)
    XCTAssertEqual(list.underestimatedCount, 4)
  }

  func testPrepend() {

    var list = LinkedList<Int>()
    list.prepend(1)
    list.prepend(2)
    list.prepend(3)
    list.prepend(4)

    XCTAssertFalse(list.isEmpty)
    XCTAssertEqual(list.description, "[4, 3, 2, 1]")
    XCTAssertEqual(list.count, 4)
    XCTAssertEqual(list.underestimatedCount, 4)
  }

  func testAppendPrepend() {

    var list = LinkedList<Int>()
    list.append(1)
    list.prepend(2)
    list.append(3)
    list.prepend(4)
    list.append(5)
    list.prepend(6)
    list.append(7)
    list.prepend(8)

    XCTAssertFalse(list.isEmpty)
    XCTAssertEqual(list.description, "[8, 6, 4, 2, 1, 3, 5, 7]")
    XCTAssertEqual(list.count, 8)
    XCTAssertEqual(list.underestimatedCount, 8)
  }

  func testPopFirst() {
    var list: LinkedList = [1, 2, 3, 4]
    XCTAssertEqual(list.popFirst(), 1)
    XCTAssertFalse(list.isEmpty)
    XCTAssertEqual(list.description, "[2, 3, 4]")
    XCTAssertEqual(list.count, 3)
    XCTAssertEqual(list.underestimatedCount, 3)
  }

  func testPopLast() {
    var list: LinkedList = [1, 2, 3, 4]
    XCTAssertEqual(list.popLast(), 4)
    XCTAssertFalse(list.isEmpty)
    XCTAssertEqual(list.description, "[1, 2, 3]")
    XCTAssertEqual(list.count, 3)
    XCTAssertEqual(list.underestimatedCount, 3)
  }

  func testPopFirstPopLast() {

    var list: LinkedList = [1, 2, 3, 4]
    XCTAssertEqual(list.popLast(), 4)
    XCTAssertEqual(list.popFirst(), 1)
    XCTAssertEqual(list.description, "[2, 3]")
    XCTAssertEqual(list.count, 2)
    XCTAssertEqual(list.underestimatedCount, 2)
    XCTAssertEqual(list.popFirst(), 2)
    XCTAssertEqual(list.popLast(), 3)
    XCTAssertNil(list.popFirst())
    XCTAssertNil(list.popLast())
    XCTAssertTrue(list.isEmpty)
    XCTAssertEqual(list.count, 0)
    XCTAssertEqual(list.underestimatedCount, 0)
  }

  func testReversed() {

    var list: LinkedList<Int> = [1, 2, 3, 4, 5, 6, 7, 8]
    var reversed: LinkedList = list.reversed()

    XCTAssertEqual(reversed.description, "[8, 7, 6, 5, 4, 3, 2, 1]")
    XCTAssertEqual(reversed.count, 8)
    XCTAssertEqual(reversed.underestimatedCount, 8)

    list.append(9)
    XCTAssertEqual(reversed.description, "[8, 7, 6, 5, 4, 3, 2, 1]")

    reversed.append(0)
    reversed.prepend(9)
    XCTAssertEqual(reversed.description, "[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]")
    XCTAssertEqual(reversed.count, 10)
    XCTAssertEqual(reversed.underestimatedCount, 10)
    XCTAssertEqual(list.count, 9)
    XCTAssertEqual(list.underestimatedCount, 9)

    reversed.popFirst()
    XCTAssertEqual(reversed.description, "[8, 7, 6, 5, 4, 3, 2, 1, 0]")
    reversed.popLast()
    XCTAssertEqual(reversed.description, "[8, 7, 6, 5, 4, 3, 2, 1]")
  }

  func testEqual() {

    let list: LinkedList<Int> = [1, 2, 3, 4]
    let reversed: LinkedList = list.reversed()

    XCTAssertEqual(list, list)
    XCTAssertEqual(reversed, reversed)
    XCTAssertNotEqual(list, reversed)

    var newList = list
    newList.append(5)
    XCTAssertNotEqual(list, newList)
    newList.popLast()
    XCTAssertEqual(list, newList)
  }
}
