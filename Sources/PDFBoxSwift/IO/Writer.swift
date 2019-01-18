//
//  Writer.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 15/01/2019.
//

public protocol Writer: AnyObject {

  /// Writes the specified byte to this output stream. The general contract
  /// for write is that one byte is written to the output stream.
  ///
  /// **Required**.
  ///
  /// - Parameter byte: The byte.
  func write(byte: UInt8) throws

  /// Writes `count` bytes from the specified buffer of bytes starting
  /// at `offset` to this output stream. The general contract for
  /// `write(bytes:offset:count:)` is that some of the bytes in the collection
  /// are written to the output stream in order; element `bytes[offset]`
  /// is the first byte written and bytes[offset + count - 1] is the last byte
  /// written by this operation.
  ///
  /// The default implementation calls the `write(byte:)` method on each of
  /// the byte to be written out. You can override
  /// this method to provide a more efficient implementation.
  ///
  /// If `offset` is negative, or `count` is negative, or `offset + count` is
  /// greater than `bytes.count`, then a runtime error occurs.
  ///
  /// **Required**
  ///
  /// - Parameters:
  ///   - bytes: The data.
  ///   - offset: The start offset in the data.
  ///   - count: The number of bytes to write.
  func write(bytes: UnsafeBufferPointer<UInt8>, offset: Int, count: Int) throws
}

extension Writer {

  /// Writes `count` bytes from the specified collection of bytes starting
  /// at `offset` to this output stream. The general contract for
  /// `write(bytes:offset:count:)` is that some of the bytes in the collection
  /// are written to the output stream in order; element `bytes[offset]`
  /// is the first byte written and bytes[offset + count - 1] is the last byte
  /// written by this operation.
  ///
  /// The default implementation calls the `UnsafeBufferPointer<UInt8>` version
  /// of the `write(bytes:offset:count:)` method if the collection can provide
  /// access to its contiguous storage in the form of
  /// `UnsafeBufferPointer<UInt8>`, otherwise calls the `write(byte:)` method
  /// on each of the byte to be written out. You can override
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
  public func write<Bytes: Collection>(
    bytes: Bytes,
    offset: Int,
    count: Int
  ) throws where Bytes.Element == UInt8 {

    precondition(
      offset >= 0 &&
        offset < bytes.count &&
        count >= 0 &&
        (offset + count) <= bytes.count,
      "Index out of bounds"
    )

    let result: Void? = try bytes.withContiguousStorageIfAvailable { buffer in
      try write(bytes: buffer, offset: offset, count: count)
    }

    if result != nil {
      return
    }

    var i = bytes.index(bytes.startIndex, offsetBy: offset)
    let end = bytes.index(i, offsetBy: count)

    while i < end {
      try write(byte: bytes[i])
      bytes.formIndex(after: &i)
    }
  }

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
    let count = string.utf8.count
    try string.withCString { ptr in
      try ptr.withMemoryRebound(to: UInt8.self, capacity: count) { ptr in
        let buffer = UnsafeBufferPointer(start: ptr, count: count)
        try write(bytes: buffer)
      }
    }
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
      try write(bytes: numbers.flatMap { $0.pdfBoxASCIIHex })
  }
}
