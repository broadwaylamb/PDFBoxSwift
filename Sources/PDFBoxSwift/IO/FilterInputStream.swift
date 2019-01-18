//
//  FilterInputStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

/// A `FilterInputStream` contains some other input stream, which it uses as
/// its basic source of data, possibly transforming the data along the way or
/// providing additional functionality. The class `FilterInputStream` itself
/// simply implements all methods of `InputStream` with versions that pass all
/// requests to the contained input stream. Adopters of `FilterInputStream` may
/// further override some of these methods and may also provide additional
/// methods and fields.
public class FilterInputStream: InputStream {

  public let input: InputStream

  internal init(input: InputStream) {
    self.input = input
  }

  deinit {
    try? close()
  }

  public func read() throws -> UInt8? {
    return try input.read()
  }

  public func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
                   offset: Int,
                   count: Int) throws -> Int? {
    return try input.read(into: buffer, offset: offset, count: count)
  }

  public func skip(_ n: Int) throws -> Int {
    return try input.skip(n)
  }

  public func available() throws -> Int {
    return try input.available()
  }

  public func mark(readLimit: Int) {
    return input.mark(readLimit: readLimit)
  }

  public func reset() throws {
    return try input.reset()
  }

  public var isMarkSupported: Bool {
    return input.isMarkSupported
  }
}
