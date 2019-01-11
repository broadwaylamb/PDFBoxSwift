//
//  COSWriter.swift
//  PDFBoxSwiftPDFWriter
//
//  Created by Sergej Jaskiewicz on 10/01/2019.
//

/// This class acts on an in-memory representation of a PDF document.
public final class COSWriter: COSVisitorProtocol {

  // MARK: - Tokens

  /// The dictionary open token.
  internal static let dictOpen: [UInt8] = Array("<<".utf8)

  /// The dictionary close token.
  internal static let dictClose: [UInt8] = Array(">>".utf8)

  /// Space character.
  internal static let space: [UInt8] = Array(" ".utf8)

  /// The start to a PDF comment.
  internal static let comment: [UInt8] = Array("%".utf8)

  /// The output version of the PDF.
  internal static let version: [UInt8] = Array("PDF-1.4".utf8)

  /// Garbage bytes used to create the PDF header.
  internal static let garbage: [UInt8] = [0xF6, 0xE4, 0xFC, 0xDF]

  /// The EOF constant.
  internal static let eof: [UInt8] = Array("%%EOF".utf8)

  /// The reference token.
  internal static let reference: [UInt8] = Array("R".utf8)

  /// The XREF token.
  internal static let xref: [UInt8] = Array("xref".utf8)

  /// The xref free token.
  internal static let xrefFree: [UInt8] = Array("f".utf8)

  /// The xref used token.
  internal static let xrefUsed: [UInt8] = Array("n".utf8)

  /// The trailer token.
  internal static let trailer: [UInt8] = Array("trailer".utf8)

  /// The start xref token.
  internal static let startXref: [UInt8] = Array("startxref".utf8)

  /// The start object token.
  internal static let obj: [UInt8] = Array("obj".utf8)

  /// The end object token.
  internal static let endobj: [UInt8] = Array("endobj".utf8)

  /// The array open token.
  internal static let arrayOpen: [UInt8] = Array("[".utf8)

  /// The array close token.
  internal static let arrayClose: [UInt8] = Array("]".utf8)

  /// The open stream token.
  internal static let stream: [UInt8] = Array("stream".utf8)

  /// The close stream token.
  internal static let endstream: [UInt8] = Array("endstream".utf8)

  // MARK: -

  /// The stream where we create the PDF output.
  private let output: OutputStream

  /// The stream used to write standard COS data.
  private let standardOuput: COSStandardOutputStream

  /// The start position of the x ref section
  private var startxref = 0

  /// The current object number.
  private var number = 0

  // TODO: Add more field from the Java implementaion

  private var willEncrypt = false

  // Signing
  private var reachedSignature = false

  private var signatureOffset = 0
  private var signatureLength = 0
  private var byteRangeOffset = 0
  private var byteRangeLength = 0

  private struct Incremental {
    var update = false
    var input: RandomAccessRead
    var output: OutputStream
    var part: [UInt8]
  }

  private var incremental: Incremental?
  private var byteRangeArray = COSArray()

  /// `COSWriter` constructor.
  ///
  /// - Parameter outputStream: The output stream to write the PDF.
  ///                           It will be closed when this object is closed.
  ///                           or deallocated.
  public init(outputStream: OutputStream) {
    self.output = outputStream
    self.standardOuput = COSStandardOutputStream(out: outputStream)
  }

  /// `COSWriter` constructor for incremental updates.
  ///
  /// - Parameters:
  ///   - outputStream: output stream where the new PDF data will be written.
  ///                   It will be closed when this object is closed
  ///                   or deallocated.
  ///   - inputData: Random access read containing source PDF data.
  /// - Throws: `IOError` if something went wrong.
  public init(outputStream: OutputStream, inputData: RandomAccessRead) throws {

    // write to buffer instead of output
    output = ByteArrayOutputStream()
    standardOuput = try COSStandardOutputStream(out: output,
                                                position: inputData.count())

    incremental = Incremental(update: true,
                              input: inputData,
                              output: outputStream,
                              part: [])
  }

  deinit {
    close()
  }

  public func visit(_ array: COSArray) throws -> Any? {
    // TODO
    return nil
  }

  public func visit(_ bool: COSBoolean) throws -> Any? {
    try bool.writePDF(standardOuput)
    return nil
  }

  public func visit(_ float: COSFloat) throws -> Any? {
    try float.writePDF(standardOuput)
    return nil
  }

  public func visit(_ int: COSInteger) throws -> Any? {
    try int.writePDF(standardOuput)
    return nil
  }

  public func visit(_ name: COSName) throws -> Any? {
    try name.writePDF(standardOuput)
    return nil
  }

  public func visit(_ null: COSNull) throws -> Any? {
    try null.writePDF(standardOuput)
    return nil
  }

  public func visit(_ string: COSString) throws -> Any? {
    // TODO
    return nil
  }

  /// This will close the stream.
  func close() {
    standardOuput.close()
    incremental?.output.close()
  }

  /// This will output the given string as a PDF object.
  ///
  /// - Parameters:
  ///   - string: `COSString` to be written
  ///   - output: The stream to write to.
  /// - Throws: `IOError` If there is an error writing to the stream.
  public static func writeString(_ string: COSString,
                                 output: OutputStream) throws {
    try writeString(bytes: string.bytes,
                    forceHex: string.forceHexForm,
                    output: output)
  }

  /// This will output the given text/byte string as a PDF object.
  ///
  /// - Parameters:
  ///   - bytes: The byte representation of a string to be written
  ///   - output: The stream to write to.
  /// - Throws: `IOError` If there is an error writing to the stream.
  public static func writeString<Bytes: Collection>(
    bytes: Bytes,
    output: OutputStream
  ) throws where Bytes.Element == UInt8 {
    try writeString(bytes: bytes, forceHex: false, output: output)
  }

  private static func writeString<Bytes: Collection>(
    bytes: Bytes,
    forceHex: Bool,
    output: OutputStream
  ) throws where Bytes.Element == UInt8 {

    // check for non-ASCII characters
    // https://issues.apache.org/jira/browse/PDFBOX-3107
    // EOL markers within a string are troublesome
    let isAscii = forceHex
      ? true
      : bytes.allSatisfy { $0 <= 127 && $0 != 0x0D && $0 != 0x0A }

    if isAscii && !forceHex {
      try output.write(byte: 0x28) // '('
      for byte in bytes {
        switch byte {
        case 0x28, 0x29, 0x5C:
          try output.write(byte: 0x5C) // '\'
          try output.write(byte: byte)
        default:
          try output.write(byte: byte)
        }
      }
      try output.write(byte: 0x29) // ')'
    } else {
      // write hex string
      try output.write(byte: 0x3C) // '<'
      try output.writeAsHex(numbers: bytes)
      try output.write(byte: 0x3E) // '>'
    }
  }
}
