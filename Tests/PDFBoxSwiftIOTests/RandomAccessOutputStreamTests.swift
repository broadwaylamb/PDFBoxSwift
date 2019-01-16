//
//  RandomAccessOutputStreamTests.swift
//  PDFBoxSwiftUtilTests
//
//  Created by Sergej Jaskiewicz on 16/01/2019.
//

import XCTest
import PDFBoxSwift

final class RandomAccessOutputStreamTests: XCTestCase {

  static let allTests = [
    ("testWrite", testWrite),
  ]

  override func setUp() {
    super.setUp()
  }

  private func createDataSequence(size: Int, firstByteValue: UInt8) -> [UInt8] {
    return Array(
      sequence(first: firstByteValue, next: { $0 &+ 1 }).prefix(size)
    )
  }

  func testWrite() throws {

    let raf = try POSIXFileSystem.default.createTemporaryFile(
      prefix: "PDFBoxTests",
      suffix: "RandomAccessOutputStreamTests.testWrite.bin",
      directory: POSIXFileSystem.default.temporaryDirectory
    )

    defer {
      do {
        try raf.close()
        try POSIXFileSystem.default.deleteFile(path: raf.path)
      } catch {
        assertionFailure(String(describing: error))
      }
    }

    // Test single byte writes
    var buffer = createDataSequence(size: 16, firstByteValue: 10)
    var out = RandomAccessOutputStream(writer: raf)
    for byte in buffer {
      try out.write(byte: byte)
    }

    XCTAssertEqual(try raf.count(), 16)
    XCTAssertEqual(try raf.position(), 16)

    // Test no write
    out = RandomAccessOutputStream(writer: raf)
    XCTAssertEqual(try raf.count(), 16)
    XCTAssertEqual(try raf.position(), 16)

    // Test buffer write
    buffer = createDataSequence(size: 8, firstByteValue: 30)
    out = RandomAccessOutputStream(writer: raf)
    try out.write(bytes: buffer)
    XCTAssertEqual(try raf.count(), 24)
    XCTAssertEqual(try raf.position(), 24)

    // Test partial buffer writes
    buffer = createDataSequence(size: 16, firstByteValue: 50)
    out = RandomAccessOutputStream(writer: raf)
    try out.write(bytes: buffer, offset: 8, count: 4)
    try out.write(bytes: buffer, offset: 4, count: 2)
    XCTAssertEqual(try raf.count(), 30)
    XCTAssertEqual(try raf.position(), 30)

    try out.close()

    // Verify written data
    buffer = try Array(repeating: 0, count: Int(raf.count()))
    try raf.seek(position: 0)

    let readBytes = try buffer.withUnsafeMutableBufferPointer { buf in
      try raf.read(into: buf)
    }

    XCTAssertEqual(buffer.count, readBytes)
    XCTAssertEqual(buffer[0], 10)
    XCTAssertEqual(buffer[1], 11)
    XCTAssertEqual(buffer[15], 25)
    XCTAssertEqual(buffer[16], 30)
    XCTAssertEqual(buffer[17], 31)
    XCTAssertEqual(buffer[23], 37)
    XCTAssertEqual(buffer[24], 58)
    XCTAssertEqual(buffer[25], 59)
    XCTAssertEqual(buffer[26], 60)
    XCTAssertEqual(buffer[27], 61)
    XCTAssertEqual(buffer[28], 54)
    XCTAssertEqual(buffer[29], 55)
  }
}
