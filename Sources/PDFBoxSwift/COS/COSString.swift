//
//  COSString.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// A string object, which may be a text string, a `PDFDocEncoded` string,
/// ASCII string, or byte string.
///
/// Text strings are used for character strings that contain information
/// intended to be human-readable, such as text annotations, bookmark names,
/// article names, document information, and so forth.
///
/// PDFDocEncoded strings are used for characters that are represented in
/// a single byte.
///
/// ASCII strings are used for characters that are represented in a single byte
/// using ASCII encoding.
///
/// Byte strings are used for binary data represented as a series of bytes, but
/// the encoding is not known. The bytes of the string need not represent
/// characters.
public final class COSString: COSBase, Decodable {

  public struct ParseError: Error, CustomStringConvertible {
    public let description: String

    internal init(description: String) {
      self.description = description
    }
  }

  /// This will create a `COSString` from a string of hex characters.
  ///
  /// - Parameter hex: A hex string.
  /// - Returns: A `COSString` with the hex characters converted to their
  ///            actual bytes.
  /// - Throws: `COSString.ParseError` if could not parse the hex string.
  public static func parseHex(_ hex: String) throws -> COSString {

    var bytes = [UInt8]()
    let trimmed = hex.trimmingWhitespaces()
    let hexBuffer = trimmed.count % 2 == 0 ? trimmed : trimmed + "0"
    bytes.reserveCapacity(hexBuffer.count / 2)

    var i = hexBuffer.startIndex
    while i < hexBuffer.endIndex {
      let nextIndex = hexBuffer.index(i, offsetBy: 2)
      guard let byte = UInt8(hexBuffer[i..<nextIndex], radix: 16) else {
        throw ParseError(description: "Invalid hex string: \(hex)")
      }
      bytes.append(byte)
      i = nextIndex
    }

    return COSString(bytes: bytes)
  }

  /// The raw bytes of the string.
  public var bytes: [UInt8]

  /// Whether the string is to be written in hex form.
  public var forceHexForm: Bool = false

  public init(bytes: [UInt8]) {
    self.bytes = bytes
  }

  ///  Creates a new PDF *text string* from `String`.
  ///
  /// - Parameter text: The string value of the object.
  public init(text: String) {

    // check whether the string uses only characters available in PDFDocEncoding
    let isOnlyPDFDocEncoding = text.utf16
      .allSatisfy(PDFDocEncoding.containsChar)

    bytes = []

    super.init()

    if isOnlyPDFDocEncoding {
      let repaired = transcode(text.utf16.makeIterator(),
                               from: UTF16.self,
                               to: PDFDocEncoding.self,
                               stoppingOnError: false,
                               into: { bytes.append($0) })
      assert(!repaired)
    } else {
      // UTF-16BE encoded string with a leading byte order marker
      let utf16 = text.utf16BigEndian
      bytes.reserveCapacity(2 + utf16.count * 2)
      bytes.append(contentsOf: [0xFE, 0xFF]) // BOM
      bytes.append(contentsOf: utf16.flatMap {
        [UInt8(($0.bigEndian & 0xFF00) >> 8), UInt8($0.bigEndian & 0xFF)]
      })
    }
  }

  public convenience init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    try self.init(text: container.decode(String.self))
  }

  public override func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(string())
  }

  /// Returns the content of this string as a PDF *text string*.
  ///
  /// - Complexity: O(n)
  public func string() -> String {
    return String(utf16ParsingBOM: bytes)
      ?? String(decoding: bytes, as: PDFDocEncoding.self)
  }

  /// Returns the content of this string as a PDF *ASCII string*.
  public func ascii() -> String {
    return String(decoding: bytes, as: Unicode.ASCII.self)
  }

  /// This will take this string and create a hex representation of the bytes
  /// that make the string.
  ///
  /// - Returns: A hex string representing the bytes in this string.
  public func hexString() -> String {
    return String(hexRepresentationOf: bytes)
  }

  @discardableResult
  public override func accept(visitor: COSVisitorProtocol) throws -> Any? {
    return try visitor.visit(self)
  }

  public override func isEqual(_ other: COSBase) -> Bool {
    guard self !== other else { return true }
    guard let other = other as? COSString else { return false }
    return forceHexForm == other.forceHexForm && string() == other.string()
  }

  public override func hash(into hasher: inout Hasher) {
    hasher.combine(bytes)
    hasher.combine(forceHexForm)
  }

  public override var debugDescription: String {
    return "COSString{\(string())}"
  }
}
