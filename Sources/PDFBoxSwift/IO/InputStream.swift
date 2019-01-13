//
//  InputStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

/// A protocol representing an input stream of bytes.
///
/// Implementors of `InputStream` must always provide a method that returns
/// the next byte of input.
public protocol InputStream: Closeable {

  /// Reads the next byte of data from the input stream. If no byte is available
  /// because the end of the stream has been reached, `nil` is returned. This
  /// method blocks until input data is available, the end of the stream is
  /// detected, or an error is thrown.
  ///
  /// **Required**
  ///
  /// - Returns: The next byte of data, or `nil` if the end of the stream is
  ///            reached.
  func read() throws -> UInt8?

  /// Reads up to `count` bytes of data from the input stream into an array
  /// of bytes. An attempt is made to read as many as `count` bytes, but
  /// a smaller number may be read. The number of bytes actually read is
  /// returned as an integer.
  ///
  /// This method blocks until input data is available, end of file is detected,
  /// or an error is thrown.
  ///
  /// If `count` is zero, then no bytes are read and 0 is returned; otherwise,
  /// there is an attempt to read at least one byte. If no byte is available
  /// because the stream is at end of file, `nil` is returned; otherwise, at
  /// least one byte is read and stored into `buffer`.
  ///
  /// **Required**. Default implementation provided.
  ///
  /// - Parameters:
  ///   - buffer: The buffer into which the data is read.
  ///   - offset: The start offset in `buffer` at which the data is written.
  ///   - count: The maximum number of bytes to read.
  /// - Returns: The total number of bytes read into the buffer, or `nil` if
  ///            there is no more data because the end of the stream has been
  ///            reached.
  func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
            offset: Int,
            count: Int) throws -> Int?

  /// Skips over and discards `n` bytes of data from this input stream.
  /// The skip method may, for a variety of reasons, end up skipping over some
  /// smaller number of bytes, possibly 0. This may result from any of a number
  /// of conditions; reaching end of file before `n` bytes have been skipped is
  /// only one possibility. The actual number of bytes skipped is returned. If
  /// `n` is negative, the `skip(_:)` method for protocol `InputStream` always
  /// returns 0, and no bytes are skipped. Implementors may handle the negative
  /// value differently.
  ///
  /// The `skip(_:)` method implementation of this protocol creates
  /// a byte buffer and then repeatedly reads into it until `n` bytes have been
  /// read or the end of the stream has been reached. Implementors are
  /// encouraged to provide a more efficient implementation of this method.
  /// For instance, the implementation may depend on the ability to seek.
  ///
  /// **Required**. Default implementation provided.
  ///
  /// - Parameter n: The number of bytes to be skipped.
  /// - Returns: The actual number of bytes skipped.
  func skip(_ n: Int) throws -> Int

  /// Returns an estimate of the number of bytes that can be read (or skipped
  /// over) from this input stream.
  ///
  /// Note that while some implementations of `InputStream` will return
  /// the total number of bytes in the stream, many will not. It is never
  /// correct to use the return value of this method to allocate a buffer
  /// intended to hold all data in this stream.
  ///
  /// An implementation of this method may choose to throw an error if this
  /// input stream has been closed by invoking the `close()` method.
  ///
  /// **Required**. Default implementation provided.
  ///
  /// - Returns: An estimate of the number of bytes that can be read (or skipped
  ///            over) from this input stream or 0 when it reaches the end of
  ///            the input stream. The default implementation returns 0.
  func available() throws -> Int

  /// Marks the current position in this input stream. A subsequent call to
  /// the `reset` method repositions this stream at the last marked position so
  /// that subsequent reads re-read the same bytes.
  ///
  /// `readLimit` tells this input stream to allow that many bytes to be read
  /// before the mark position gets invalidated.
  ///
  /// The general contract of `mark(readLimit:)` is that, if `isMarkSupported`
  /// returns `true`, the stream somehow remembers all the bytes read after
  /// the call to `mark(readLimit:)` and stands ready to supply those same bytes
  /// again if and whenever the method `reset` is called. However, the stream is
  /// not required to remember any data at all if more than `readLimit` bytes
  /// are read from the stream before reset is called.
  ///
  /// Marking a closed stream should not have any effect on the stream.
  ///
  /// The default implementation does nothing.
  ///
  /// **Required**. Default implementation provided.
  func mark(readLimit: Int)

  /// Repositions this stream to the position at the time the `mark(readLimit:)`
  /// method was last called on this input stream.
  ///
  /// The general contract of reset is:
  ///
  /// - If `isMarkSupported` returns `true`, then:
  ///
  ///   - If the method `mark(readLimit:)` has not been called since the stream
  ///     was created, or the number of bytes read from the stream since
  ///     `mark(readLimit:)` was last called is larger than the argument to mark
  ///     at that last call, then an error might be thrown.
  ///
  ///   - If such an error is not thrown, then the stream is reset to a state
  ///     such that all the bytes read since the most recent call to
  ///     `mark(readLimit:)` (or since the start of the file, if mark has not
  ///     been called) will be resupplied to subsequent callers of the read
  ///     method, followed by any bytes that otherwise would have been the next
  ///     input data as of the time of the call to `reset`.
  ///
  /// - If `isMarkSupported` returns `false`, then:
  ///
  ///   - The call to `reset` may throw an error.
  ///
  ///   - If an error is not thrown, then the stream is reset to a fixed state
  ///     that depends on the particular type of the input stream and how it was
  ///     created. The bytes that will be supplied to subsequent callers of
  ///     the read method depend on the particular type of the input stream.
  ///
  /// **Required**. Default implementation provided.
  func reset() throws

  /// Tests if this input stream supports the `mark(readLimit:)` and `reset`
  /// methods. Whether or not `mark(readLimit:)` and `reset` are supported is
  /// an invariant property of a particular input stream instance.
  ///
  /// The default implementation returns `false`.
  ///
  /// **Required**. Default implementation provided.
  var isMarkSupported: Bool { get }
}

extension InputStream {

  public func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
                   offset: Int,
                   count: Int) throws -> Int? {
    // TODO
    precondition(offset >= 0 && count >= 0 || count > buffer.count - offset,
                 "Index out of bounds")

    guard count > 0 else {
      return 0
    }

    guard let byte = try read() else {
      return nil
    }

    buffer[offset] = byte

    var i = 1
    while i < count {
      guard let c = try read() else { break }
      buffer[offset + i] = c
      i += 1
    }

    return i
  }

  public func skip(_ n: Int) throws -> Int {

    guard n > 0 else { return 0 }

    var remaining = n

    let size = min(maxSkipBufferSize, remaining)
    let skipBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: size)
    defer { skipBuffer.deallocate() }

    while remaining > 0 {
      if let nr = try read(into: skipBuffer,
                           offset: 0,
                           count: min(size, remaining)) {
        remaining -= nr
      } else {
        break
      }
    }

    return n - remaining
  }

  func available() throws -> Int {
    return 0
  }

  func close() throws {}

  func mark(readLimit: Int) {}

  func reset() throws {
    throw IOError(description: "mark/reset not supported")
  }

  var isMarkSupported: Bool { return false }

  /// Reads some number of bytes from the input stream and stores them into
  /// `buffer`. The number of bytes actually read is returned as an integer.
  /// This method blocks until input data is available, end of file is detected,
  /// or an error is thrown.
  ///
  /// If the length of `buffer` is zero, then no bytes are read and 0 is
  /// returned; otherwise, there is an attempt to read at least one byte.
  /// If no byte is available because the stream is at the end of the file,
  /// `nil` is returned; otherwise, at least one byte is read and stored into
  /// `buffer`.
  ///
  /// - Parameter buffer: The buffer into which the data is read.
  /// - Returns: The total number of bytes read into the buffer, or `nil` if
  ///            there is no more data because the end of the stream has been
  ///            reached.
  public func read(
    into buffer: UnsafeMutableBufferPointer<UInt8>
  ) throws -> Int? {
    return try read(into: buffer, offset: 0, count: buffer.count)
  }
}

/// Used to determine the maximum buffer size to use when skipping.
private let maxSkipBufferSize = 2048
