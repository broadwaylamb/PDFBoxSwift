//
//  RandomAccessRead.swift
//  PDFBoxSwiftIO
//
//  Created by Sergej Jaskiewicz on 10/01/2019.
//

/// A protocol allowing random access read operations.
public protocol RandomAccessRead: Closeable {

  /// Read a single byte of data.
  ///
  /// - Returns: The byte of data that is being read.
  func read() throws -> UInt8?

  /// Read a buffer of data.
  ///
  /// - Parameters:
  ///   - buffer: The buffer to write the data to.
  ///   - offset: Offset into the buffer to start writing.
  ///   - count: The amount of data to attempt to read.
  /// - Returns: The number of bytes that were actually read, or `nil` if
  ///            there is no more data because the end of the stream has been
  ///            reached.
  func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
            offset: Int,
            count: Int) throws -> Int?

  /// Returns the offset of the next byte to be returned by a `read` method.
  ///
  /// - Returns: The offset of the next byte to be returned by a `read` method.
  ///            (if no more bytes are left it returns a value greater than or
  ///            equal to the length of source).
  func position() throws -> UInt64

  /// Seek to a position in the data.
  ///
  /// - Parameter position: The position to seek to.
  func seek(position: UInt64) throws

  /// The total number of bytes that are available.
  ///
  /// - Returns: The number of bytes available.
  func count() throws -> UInt64

  /// `true` if this stream has been closed.
  var isClosed: Bool { get }

  /// This will peek at the next byte.
  ///
  /// - Returns: The next byte on the stream, leaving it as available to read.
  func peek() throws -> UInt8?

  /// Seek backwards the given number of bytes.
  ///
  /// - Parameter cout: The number of bytes to be seeked backwards.
  func rewind(count: UInt64) throws

  /// A simple test to see if we are at the end of the data.
  ///
  /// - Returns: `true` if we are at the end of the data.
  func isEOF() throws -> Bool

  /// Returns an estimate of the number of bytes that can be read.
  ///
  /// - Returns: The number of bytes that can be read.
  func available() throws -> UInt64
}

extension RandomAccessRead {

  /// Read a buffer of data.
  ///
  /// - Parameter buffer: The buffer to write the data to.
  /// - Returns: The number of bytes that were actually read, or `nil` if
  ///            there is no more data because the end of the stream has been
  ///            reached.
  func read(into buffer: UnsafeMutableBufferPointer<UInt8>) throws -> Int? {
    return try read(into: buffer, offset: 0, count: buffer.count)
  }
}
