//
//  OutputStream.swift
//  PDFBoxSwiftIO
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// This protocol representing an output stream of bytes. An output stream
/// accepts output bytes and sends them to some sink.
///
/// Applications that implement `OutputStream` must always provide at least
/// a method that writes one byte of output.
public protocol OutputStream: Closeable, Flushable {

  /// Writes `count` bytes from the specified collection of bytes starting
  /// at `offset` to this output stream. The general contract for
  /// `write(bytes:offset:count:)` is that some of the bytes in the collection
  /// are written to the output stream in order; element `bytes[offset]`
  /// is the first byte written and bytes[offset + count - 1] is the last byte
  /// written by this operation.
  ///
  /// The default implementation calls the `write(bytes:)` method on each of
  /// the bytes to be written out. You can override
  /// this method to provide a more efficient implementation.
  ///
  /// If `offset` is negative, or `count` is negative, or `offset + count` is
  /// greater than `bytes.count`, then a runtime error occurs.
  ///
  /// **Required**. Default implementation provided.
  ///
  /// - Parameters:
  ///   - bytes: The data.
  ///   - offset: The start offset in the data.
  ///   - count: The number of bytes to write.
  func write<Bytes: Collection>(bytes: Bytes, offset: Int, count: Int) throws
      where Bytes.Element == UInt8

  /// Writes the specified byte to this output stream. The general contract
  /// for write is that one byte is written to the output stream.
  ///
  /// **Required**.
  ///
  /// - Parameter byte: The byte.
  func write(byte: UInt8) throws

  /// Flushes this output stream and forces any buffered output bytes to be
  /// written out. The general contract of `flush` is that calling it is
  /// an indication that, if any bytes previously written have been buffered
  /// by the implementation of the output stream, such bytes should immediately
  /// be written to their intended destination.
  ///
  /// If the intended destination of this stream is an abstraction provided
  /// by the underlying operating system, for example a file, then flushing
  /// the stream guarantees only that bytes previously written to the stream
  /// are passed to the operating system for writing; it does not guarantee
  /// that they are actually written to a physical device such as a disk drive.
  ///
  /// The default implementation does nothing.
  ///
  /// **Required**. Default implementation provided.
  func flush() throws

  /// Closes this output stream and releases any system resources associated
  /// with this stream. The general contract of `close` is that it closes
  /// the output stream. A closed stream cannot perform output operations
  /// and cannot be reopened.
  ///
  /// The default implementation does nothing.
  ///
  /// **Required**. Default implementation provided.
  func close()
}

extension OutputStream {

  public func write<Bytes: Collection>(bytes: Bytes,
                                       offset: Int,
                                       count: Int) throws
      where Bytes.Element == UInt8 {

    precondition(
      offset >= 0 &&
      offset < bytes.count &&
      count >= 0 &&
      (offset + count) <= bytes.count,
      "Index out of bounds"
    )

    var i = bytes.index(bytes.startIndex, offsetBy: offset)
    let end = bytes.index(i, offsetBy: count)

    while i < end {
      try write(byte: bytes[i])
      bytes.formIndex(after: &i)
    }
  }

  public func flush() throws {}

  public func close() {}

  /// Writes the specified byte to this output stream. The general contract
  /// for write is that one byte is written to the output stream. The byte
  /// to be written is the eight low-order bits of the argument `byte`.
  /// The high-order bits of `byte` are ignored.
  ///
  /// - Parameter byte: The byte.
  public func write<T: BinaryInteger>(byte: T) throws {
    try write(byte: UInt8(truncatingIfNeeded: byte))
  }

  /// Writes `bytes.count` bytes from the specified collection of bytes to
  /// this output stream. Has exactly the same effect as the call
  /// `write(bytes: bytes, offset: 0, count: bytes.count)`.
  ///
  /// - Parameter bytes: The data.
  /// - SeeAlso: `write(bytes:offset:count:)`
  public func write<Bytes: Collection>(bytes: Bytes) throws
      where Bytes.Element == UInt8 {
    try write(bytes: bytes, offset: 0, count: bytes.count)
  }

  /// Writes the `string`'s UTF8 representation.
  ///
  /// Equivalent to `write(bytes: string.utf8)`.
  ///
  /// - Parameter string: The string to write to.
  public func write(utf8 string: String) throws {
    try write(bytes: string.utf8)
  }

  /// Writes the `number` as a string.
  ///
  /// Equivalent to `write(utf8: String(number))`.
  ///
  /// - Parameter number: The number to write to.
  public func write<T: BinaryInteger>(number: T) throws {
    try write(utf8: String(number))
  }

  public func writeAsHex<T: FixedWidthInteger & UnsignedInteger>(
    _ number: T
  ) throws {
    try write(bytes: number.pdfBoxASCIIHex)
  }

  public func writeAsHex<C: Collection>(numbers: C) throws
      where C.Element: FixedWidthInteger & UnsignedInteger {
    try write(bytes: numbers.lazy.flatMap { $0.pdfBoxASCIIHex })
  }
}
