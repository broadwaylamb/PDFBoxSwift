//
//  COSStringTests.swift
//  PDFBoxSwiftCOSTests
//
//  Created by Sergej Jaskiewicz on 10/01/2019.
//

import XCTest

@testable import PDFBoxSwiftCOS
import PDFBoxSwiftIO
import PDFBoxSwiftPDFWriter

final class COSStringTests: XCTestCase {

  static let allTests = [
    ("testGetBytes", testGetBytes),
    ("testWritePDF", testWritePDF),
    ("testFromHex", testFromHex),
    ("testUnicode", testUnicode),
    ("testEmptyStringWithBOM", testEmptyStringWithBOM),
    ("testCompareFromHexString", testCompareFromHexString),
    ("testAccept", testAccept),
    ("testEquals", testEquals),
    ("testGetHex", testGetHex),
    ("testGetString", testGetString),
    ("testSetForceHexLiteralForm", testSetForceHexLiteralForm),
  ]

  private typealias ASCII = Unicode.ASCII

  private static let escCharString = "( test#some) escaped< \\chars>!~1239857 "

  private static let escCharStringPDFFormat =
      "\\( test#some\\) escaped< \\\\chars>!~1239857 "

  private func writePDFTests(expected: String, sut: COSString) throws {
    let outStream = ByteArrayOutputStream()
    try COSWriter.writeString(sut, output: outStream)
    XCTAssertEqual(expected, String(decoding: outStream, as: UTF8.self))
  }

  func testGetBytes() throws {
    let str = COSString(text: COSStringTests.escCharString)
    XCTAssertEqual(Array(COSStringTests.escCharString.utf8), str.bytes)
  }

  func testWritePDF() throws {
    let sut = COSString(text: COSStringTests.escCharString)
    try writePDFTests(expected: "(\(COSStringTests.escCharStringPDFFormat))",
                      sut: sut)

    let textString = "This is just an arbitrary piece of text for testing"
    let sut2 = COSString(text: textString)
    try writePDFTests(expected: "(\(textString))", sut: sut2)
  }

  func testFromHex() throws {
    let expected = "Quick and simple test"
    let hexForm = String(hex: expected, encodedAs: ASCII.self)

    let test1 = try COSString.parseHex(hexForm)
    try writePDFTests(expected: "(\(expected))", sut: test1)

    let test2 = try COSString
      .parseHex(String(hex: COSStringTests.escCharString,
                       encodedAs: ASCII.self))
    try writePDFTests(expected: "(\(COSStringTests.escCharStringPDFFormat))",
                      sut: test2)

    XCTAssertThrowsError(try COSString.parseHex("\(hexForm)xx"))
  }

  func testUnicode() throws {

    let theString = "世"
    let string = COSString(text: theString)
    XCTAssertEqual(string.string(), theString)

    let textASCII =
        "This is some regular text. It should all be expressable in ASCII"
    let text8Bit = "En français où les choses sont accentués. En español, así"
    let textHighBits = "をクリックしてく"

    let stringASCII = COSString(text: textASCII)
    XCTAssertEqual(stringASCII.string(), textASCII)

    let string8Bit = COSString(text: text8Bit)
    XCTAssertEqual(string8Bit.string(), text8Bit)

    let stringHighBits = COSString(text: textHighBits)
    XCTAssertEqual(stringHighBits.string(), textHighBits)

    // The first two strings should be stored as ISO-8859-1 because they only
    // contain chars in the range 0..<256
    XCTAssertEqual(textASCII,
                   String(decoding: stringASCII.bytes, as: PDFDocEncoding.self))
    // likewise for the 8bit characters.
    XCTAssertEqual(text8Bit,
                   String(decoding: string8Bit.bytes, as: PDFDocEncoding.self))

    // The japanese text contains high bits so must be stored as
    // big endian UTF-16
    if let stringHighBitsUTF16 = String(utf16ParsingBOM: stringHighBits.bytes) {
      XCTAssertEqual(textHighBits, stringHighBitsUTF16)
    } else {
      XCTFail("Could not parse stringHighBits as UTF16")
    }

    // Test the writeString method to ensure that the Strings are correct when
    // written into PDF.
    let out = ByteArrayOutputStream()
    try COSWriter.writeString(stringASCII, output: out)
    XCTAssertEqual("(\(textASCII))",
      String(decoding: out, as: Unicode.ASCII.self))

    out.reset()

    try COSWriter.writeString(string8Bit, output: out)
    XCTAssertEqual(
      "<\(String(hex: text8Bit, encodedAs: PDFDocEncoding.self))>",
      String(decoding: out, as: ASCII.self)
    )

    out.reset()

    try COSWriter.writeString(stringHighBits, output: out)
    let hexHighBits = """
    <FEFF\(String(hex: textHighBits, encodedAs: UTF16.self, endianness: .big))>
    """
    XCTAssertEqual(hexHighBits, String(decoding: out, as: ASCII.self) )
  }

  func testEmptyStringWithBOM() throws {
    try XCTAssertTrue(COSString.parseHex("FEFF").string().isEmpty)
    try XCTAssertTrue(COSString.parseHex("FFFE").string().isEmpty)
  }

  func testCompareFromHexString() throws {
    let test1 = try COSString.parseHex("000000FF000000")
    let test2 = try COSString.parseHex("000000FF00FFFF")
    XCTAssertNotEqual(test1.hexString(), test2.hexString())
    XCTAssertNotEqual(test1.bytes, test2.bytes)
    XCTAssertNotEqual(test1, test2)
    XCTAssertNotEqual(test2, test1)
    XCTAssertNotEqual(test1.string(), test2.string())
  }

  func testAccept() throws {
    // TODO: AS soon as COSWriter.visit(_:) is implemented for COSString
  }

  func testEquals() throws {

    // Reflexivity (x == x)
    let x1 = COSString(text: "Test")
    XCTAssertEqual(x1, x1)

    // Symmetry is preserved (x == y implies y == x)
    let y1 = COSString(text: "Test")
    XCTAssertEqual(x1, y1)
    let x2 = COSString(text: "Test")
    x2.forceHexForm = true
    XCTAssertNotEqual(x1, x2)
    XCTAssertNotEqual(x2, x1)

    // Transitivity (if x == y && y == z then x == z)
    let z1 = COSString(text: "Test")
    XCTAssertEqual(x1, y1)
    XCTAssertEqual(y1, z1)
    XCTAssertEqual(x1, z1)
    XCTAssertNotEqual(y1, x2)
  }

  func testGetHex() throws {
    let expected = "Test subject for testing hexString()"
    let test1 = COSString(text: expected)
    XCTAssertEqual(String(hex: expected, encodedAs: ASCII.self),
                   test1.hexString())

    let escCS = COSString(text: COSStringTests.escCharString)
    XCTAssertEqual(String(hex: COSStringTests.escCharString,
                          encodedAs: ASCII.self),
                   escCS.hexString())
  }

  func testGetString() throws {
    let testStr = "Test subject for string()"
    let test1 = COSString(text: testStr)
    XCTAssertEqual(testStr, test1.string())

    let hexStr = try COSString
      .parseHex(String(hex: COSStringTests.escCharString,
                       encodedAs: ASCII.self))
    XCTAssertEqual(COSStringTests.escCharString, hexStr.string())

    let escapedString = COSString(text: COSStringTests.escCharString)
    XCTAssertEqual(COSStringTests.escCharString, escapedString.string())

    let testStr2 = "Line1\nLine2\nLine3\n"
    let lineFeedString = COSString(text: testStr2)
    XCTAssertEqual(testStr2, lineFeedString.string())
  }

  func testSetForceHexLiteralForm() throws {
    let inputString = "Test with a text and a few numbers 1, 2 and 3"
    let pdfHex = "<\(String(hex: inputString, encodedAs: ASCII.self))>"
    let cosStr = COSString(text: inputString)
    cosStr.forceHexForm = true
    try writePDFTests(expected: pdfHex, sut: cosStr)
  }
}
