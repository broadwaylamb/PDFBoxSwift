//
//  PDFDocEncoding.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// The "PDFDocEncoding" encoding. Note that this is *not* a Type 1 font
/// encoding, it is used only within PDF "text strings".
internal enum PDFDocEncoding {

  private static let replacementCharacter: UInt16 = 0xFFFD

  fileprivate static let codeToUTF16: [UInt16] = {

    var arr = [UInt16](repeating: 0, count: 256)

    // initialize with basically ISO-8859-1
    for i in 0..<256 {

      // skip entries not in Unicode column
      if i > 0x17 && i < 0x20 {
        continue
      }
      if i > 0x7E && i < 0xA1 {
        continue
      }
      if i == 0xAD {
        continue
      }

      arr[i] = UInt16(i)
    }

    // then do all deviations (based on the table in ISO 32000-1:2008)

    // block 1
    arr[0x18] = 0x02D8 // BREVE
    arr[0x19] = 0x02C7 // CARON
    arr[0x1A] = 0x02C6 // MODIFIER LETTER CIRCUMFLEX ACCENT
    arr[0x1B] = 0x02D9 // DOT ABOVE
    arr[0x1C] = 0x02DD // DOUBLE ACUTE ACCENT
    arr[0x1D] = 0x02DB // OGONEK
    arr[0x1E] = 0x02DA // RING ABOVE
    arr[0x1F] = 0x02DC // SMALL TILDE

    // block 2
    arr[0x7F] = replacementCharacter // undefined
    arr[0x80] = 0x2022 // BULLET
    arr[0x81] = 0x2020 // DAGGER
    arr[0x82] = 0x2021 // DOUBLE DAGGER
    arr[0x83] = 0x2026 // HORIZONTAL ELLIPSIS
    arr[0x84] = 0x2014 // EM DASH
    arr[0x85] = 0x2013 // EN DASH
    arr[0x86] = 0x0192 // LATIN SMALL LETTER SCRIPT F
    arr[0x87] = 0x2044 // FRACTION SLASH (solidus)
    arr[0x88] = 0x2039 // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    arr[0x89] = 0x203A // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    arr[0x8A] = 0x2212 // MINUS SIGN
    arr[0x8B] = 0x2030 // PER MILLE SIGN
    arr[0x8C] = 0x201E // DOUBLE LOW-9 QUOTATION MARK (quotedblbase)
    arr[0x8D] = 0x201C // LEFT DOUBLE QUOTATION MARK (quotedblleft)
    arr[0x8E] = 0x201D // RIGHT DOUBLE QUOTATION MARK (quotedblright)
    arr[0x8F] = 0x2018 // LEFT SINGLE QUOTATION MARK (quoteleft)
    arr[0x90] = 0x2019 // RIGHT SINGLE QUOTATION MARK (quoteright)
    arr[0x91] = 0x201A // SINGLE LOW-9 QUOTATION MARK (quotesinglbase)
    arr[0x92] = 0x2122 // TRADE MARK SIGN
    arr[0x93] = 0xFB01 // LATIN SMALL LIGATURE FI
    arr[0x94] = 0xFB02 // LATIN SMALL LIGATURE FL
    arr[0x95] = 0x0141 // LATIN CAPITAL LETTER L WITH STROKE
    arr[0x96] = 0x0152 // LATIN CAPITAL LIGATURE OE
    arr[0x97] = 0x0160 // LATIN CAPITAL LETTER S WITH CARON
    arr[0x98] = 0x0178 // LATIN CAPITAL LETTER Y WITH DIAERESIS
    arr[0x99] = 0x017D // LATIN CAPITAL LETTER Z WITH CARON
    arr[0x9A] = 0x0131 // LATIN SMALL LETTER DOTLESS I
    arr[0x9B] = 0x0142 // LATIN SMALL LETTER L WITH STROKE
    arr[0x9C] = 0x0153 // LATIN SMALL LIGATURE OE
    arr[0x9D] = 0x0161 // LATIN SMALL LETTER S WITH CARON
    arr[0x9E] = 0x017E // LATIN SMALL LETTER Z WITH CARON
    arr[0x9F] = replacementCharacter // undefined
    arr[0xA0] = 0x20AC // EURO SIGN

    return arr
  }()

  fileprivate static let utf16ToCode: [UInt16 : UInt8] = {
    var dict = [UInt16 : UInt8](minimumCapacity: 256)
    for (code, utf16) in codeToUTF16.enumerated() {
      dict[utf16] = UInt8(code)
    }
    return dict
  }()

  /// Returns `true` if the given character is available in `PDFDocEncoding`.
  ///
  /// - Parameter char: UTF-16 character
  /// - Returns: `true` if the given character is available in `PDFDocEncoding`.
  internal static func containsChar(_ char: UInt16) -> Bool {
    return utf16ToCode[char] != nil
  }
}

extension PDFDocEncoding: Unicode.Encoding {

  typealias ForwardParser = Parser

  typealias ReverseParser = Parser

  typealias CodeUnit = UInt8

  typealias EncodedScalar = CollectionOfOne<CodeUnit>

  static let encodedReplacementCharacter = EncodedScalar(0x3F)

  static func decode(_ content: EncodedScalar) -> UnicodeScalar {
    return UnicodeScalar(codeToUTF16[Int(content[content.startIndex])])!
  }

  static func encode(_ content: UnicodeScalar) -> EncodedScalar? {

    let utf16 = content.utf16

    guard utf16.count == 1 else {
      return nil
    }

    return utf16ToCode[utf16.first!].map(EncodedScalar.init)
  }

  struct Parser: Unicode.Parser {

    typealias Encoding = PDFDocEncoding

    init() {}

    mutating func parseScalar<I>(
      from input: inout I
    ) -> Unicode.ParseResult<EncodedScalar>
        where I : IteratorProtocol, I.Element == UInt8 {
          return input
            .next()
            .map(EncodedScalar.init)
            .map(Unicode.ParseResult.valid) ?? .emptyInput
    }
  }
}
