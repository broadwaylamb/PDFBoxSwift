//
//  COSStandardOutputStream.swift
//  PDFBoxSwiftIO
//
//  Created by Sergej Jaskiewicz on 10/01/2019.
//

/// Simple output stream with some minor features for generating
/// "pretty" PDF files.
public final class COSStandardOutputStream: FilterOutputStream {

  /// To be used when 2 byte sequence is enforced.
  public static let crlf: [UInt8] = [0x0D, 0x0A]

  /// Line feed character.
  public static let lf: [UInt8] = [0x0A]

  /// Standard line separator.
  public static let eol: [UInt8] = [0x0A]

  /// Current byte position in the output stream.
  public private(set) var position: Int

  /// Flag to prevent generating two newlines in sequence.
  public var isOnNewLine: Bool = false

  /// Constructor.
  ///
  /// - Parameters:
  ///   - out: The underlying stream to write to.
  ///   - position: The current position of output stream.
  public init(out: OutputStream, position: Int = 0) {
    self.position = position
    super.init(out: out)
  }

  /// This will write some bytes to the stream.
  ///
  /// - Parameters:
  ///   - bytes: The source collection of bytes.
  ///   - offset: The offset into the collection to start writing.
  ///   - count: The number of bytes to write.
  /// - Throws: `IOError` If the underlying stream throws an error.
  public func write<Bytes>(bytes: Bytes, offset: Int, count: Int) throws
      where Bytes: Collection, Bytes.Element == UInt8 {
    isOnNewLine = false
    try out.write(bytes: bytes, offset: offset, count: count)
    position += count
  }

  /// This will write a single byte to the stream.
  ///
  /// - Parameter byte: The byte to write to the stream.
  /// - Throws: `IOError` If the underlying stream throws an error.
  public override func write(byte: UInt8) throws {
    isOnNewLine = false
    try out.write(byte: byte)
    position += 1
  }

  /// This will write a CRLF to the stream.
  ///
  /// - Throws: `IOError` If the underlying stream throws an error.
  public func writeCRLF() throws {
    try write(bytes: COSStandardOutputStream.crlf)
  }

  /// This will write an EOL to the stream.
  ///
  /// - Throws: `IOError` If the underlying stream throws an error.
  public func writeEOL() throws {
    if !isOnNewLine {
      try write(bytes: COSStandardOutputStream.eol)
      isOnNewLine = true
    }
  }

  /// This will write a line feed to the stream.
  ///
  /// - Throws: `IOError` If the underlying stream throws an error.
  public func writeLF() throws {
    try write(bytes: COSStandardOutputStream.lf)
  }
}
