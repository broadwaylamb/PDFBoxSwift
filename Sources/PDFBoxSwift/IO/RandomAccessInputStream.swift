//
//  RandomAccessInputStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 16/01/2019.
//

/// An InputStream which reads from a RandomAccessRead.
public class RandomAccessInputStream: InputStream {

  private let input: RandomAccessRead
  private var position: UInt64 = 0

  /// Creates a new `RandomAccessInputStream`, with a position of zero.
  /// The `InputStream` will maintain its own position independent of
  /// the `RandomAccessRead`.
  ///
  /// - Parameter read: The `RandomAccessRead` to read from.
  public init(read: RandomAccessRead) {
    self.input = read
  }

  deinit {
    try? close()
  }

  private func restorePosition() throws {
    try input.seek(position: position)
  }

  public func available() throws -> Int {
    try restorePosition()
    let available = try input.count() - input.position()
    return Int(clamping: available)
  }

  public func read() throws -> UInt8? {
    try restorePosition()

    if try input.isEOF() {
      return nil
    }

    let byte = try input.read()
    position += 1
    return byte
  }

  public func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
                   offset: Int,
                   count: Int) throws -> Int? {
    try restorePosition()

    if try input.isEOF() {
      return nil
    }

    if let n = try input.read(into: buffer, offset: offset, count: count) {
      position += UInt64(n)
      return n
    }

    return nil
  }

  public func skip(_ n: Int) throws -> Int {
    try restorePosition()
    try input.seek(position: position + UInt64(n))
    position += UInt64(n)
    return n
  }
}
