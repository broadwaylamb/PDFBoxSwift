//
//  RandomAccessRead.swift
//  PDFBoxSwiftIO
//
//  Created by Sergej Jaskiewicz on 10/01/2019.
//

/// A protocol allowing random access read operations.
public protocol RandomAccessRead: AnyObject {

  /// Read a single byte of data.
  ///
  /// - Returns: The byte of data that is being read.
  /// - Throws: `IOError` if there is an error while reading the data.
  func read() throws -> UInt8

  /// Read a buffer of data.
  ///
  /// - Parameters:
  ///   - buffer: The buffer to write the data to.
  ///   - offset: Offset into the buffer to start writing.
  ///   - count: The amount of data to attempt to read.
  /// - Returns: The number of bytes that were actually read.
  /// - Throws: `IOError` if there is an error while reading the data.
  func read(into buffer: inout [UInt8], offset: Int, count: Int) throws -> Int

  /// Returns the offset of the next byte to be returned by a `read` method.
  ///
  /// - Returns: The offset of the next byte to be returned by a `read` method.
  ///            (if no more bytes are left it returns a value greater than or
  ///            equal to the length of source).
  /// - Throws: `IOError` if there is an error while reading the data.
  func position() throws -> Int

  /// Seek to a position in the data.
  ///
  /// - Parameter position: The position to seek to.
  /// - Throws: `IOError` if there is an error while seeking.
  func seek(position: Int) throws

  /// The total number of bytes that are available.
  ///
  /// - Returns: The number of bytes available.
  /// - Throws: `IOError` if there is an I/O error while determining the
  ///            length of the data stream.
  func count() throws -> Int

  /// `true` if this stream has been closed.
  var isClosed: Bool { get }

  /// This will peek at the next byte.
  ///
  /// - Returns: The next byte on the stream, leaving it as available to read.
  /// - Throws: `IOError` if there is an error while reading the data.
  func peek() throws -> UInt8

  /// Seek backwards the given number of bytes.
  ///
  /// - Parameter cout: The number of bytes to be seeked backwards.
  /// - Throws: `IOError` if there is an error while seeking.
  func rewind(cout: Int) throws

  /// Reads a given number of bytes.
  ///
  /// - Parameter count: The number of bytes to be read.
  /// - Returns: A byte array containing the bytes just read.
  /// - Throws: `IOError` if there is an error while reading the data.
  func readFully(count: Int) throws -> [UInt8]

  /// A simple test to see if we are at the end of the data.
  ///
  /// - Returns: `true` if we are at the end of the data.
  /// - Throws: `IOError` if there is an error reading the next byte.
  func isEOF() throws -> Bool

  /// Returns an estimate of the number of bytes that can be read.
  ///
  /// - Returns: The number of bytes that can be read.
  /// - Throws: `IOError` if this `RandomAccessRead` has been closed.
  func available() throws -> Int
}

extension RandomAccessRead {

  /// Read a buffer of data.
  ///
  /// - Parameter buffer: The buffer to write the data to.
  /// - Returns: The number of bytes that were actually read.
  /// - Throws: `IOError` if there is an error while reading the data.
  func read(into buffer: inout [UInt8]) throws -> Int {
    return try read(into: &buffer, offset: 0, count: buffer.count)
  }
}
