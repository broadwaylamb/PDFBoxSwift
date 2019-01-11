//
//  PDFDocEncodingTest.swift
//  PDFBoxSwiftCOSTests
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

import XCTest

import PDFBoxSwiftCOS

final class PDFDocEncodingTests: XCTestCase {

  static let allTests = [
    ("testDeviations", testDeviations),
    ("testPDFBox3864", testPDFBox3864),
  ]

  private static let deviations = [
    "\u{02D8}", // BREVE
    "\u{02C7}", // CARON
    "\u{02C6}", // MODIFIER LETTER CIRCUMFLEX ACCENT
    "\u{02D9}", // DOT ABOVE
    "\u{02DD}", // DOUBLE ACUTE ACCENT
    "\u{02DB}", // OGONEK
    "\u{02DA}", // RING ABOVE
    "\u{02DC}", // SMALL TILDE
    "\u{2022}", // BULLET
    "\u{2020}", // DAGGER
    "\u{2021}", // DOUBLE DAGGER
    "\u{2026}", // HORIZONTAL ELLIPSIS
    "\u{2014}", // EM DASH
    "\u{2013}", // EN DASH
    "\u{0192}", // LATIN SMALL LETTER SCRIPT F
    "\u{2044}", // FRACTION SLASH (solidus)
    "\u{2039}", // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    "\u{203A}", // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    "\u{2212}", // MINUS SIGN
    "\u{2030}", // PER MILLE SIGN
    "\u{201E}", // DOUBLE LOW-9 QUOTATION MARK (quotedblbase)
    "\u{201C}", // LEFT DOUBLE QUOTATION MARK (quotedblleft)
    "\u{201D}", // RIGHT DOUBLE QUOTATION MARK (quotedblright)
    "\u{2018}", // LEFT SINGLE QUOTATION MARK (quoteleft)
    "\u{2019}", // RIGHT SINGLE QUOTATION MARK (quoteright)
    "\u{201A}", // SINGLE LOW-9 QUOTATION MARK (quotesinglbase)
    "\u{2122}", // TRADE MARK SIGN
    "\u{FB01}", // LATIN SMALL LIGATURE FI
    "\u{FB02}", // LATIN SMALL LIGATURE FL
    "\u{0141}", // LATIN CAPITAL LETTER L WITH STROKE
    "\u{0152}", // LATIN CAPITAL LIGATURE OE
    "\u{0160}", // LATIN CAPITAL LETTER S WITH CARON
    "\u{0178}", // LATIN CAPITAL LETTER Y WITH DIAERESIS
    "\u{017D}", // LATIN CAPITAL LETTER Z WITH CARON
    "\u{0131}", // LATIN SMALL LETTER DOTLESS I
    "\u{0142}", // LATIN SMALL LETTER L WITH STROKE
    "\u{0153}", // LATIN SMALL LIGATURE OE
    "\u{0161}", // LATIN SMALL LETTER S WITH CARON
    "\u{017E}", // LATIN SMALL LETTER Z WITH CARON
    "\u{20AC}"  // EURO SIGN
  ]

  func testDeviations() {
    for deviation in PDFDocEncodingTests.deviations {
      let cosString = COSString(text: deviation)
      XCTAssertEqual(cosString.string(), deviation)
    }
  }

  func testPDFBox3864() throws {
    // https://issues.apache.org/jira/browse/PDFBOX-3864
    // Test that chars smaller than 256 which are NOT part of PDFDocEncoding are
    // handled correctly.

    for i in 0..<256 {
      let hex = String(format: "FEFF%04X", i)
      let cs1 = try COSString.parseHex(hex)
      let cs2 = COSString(text: cs1.string())
      XCTAssertEqual(cs1, cs2)
    }
  }
}
