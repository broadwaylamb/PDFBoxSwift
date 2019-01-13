//
//  RandomAccessOutputStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

public final class RandomAccessOutputStream: OutputStream {

  private let writer: RandomAccessWrite

  /// Constructor to create a new output stream which writes to the given
  /// `writer`.
  ///
  /// - Parameter writer: The random access writer for output.
  public init(writer: RandomAccessWrite) {
    self.writer = writer
  }

  public func write<Bytes: Collection>(
    bytes: Bytes,
    offset: Int,
    count: Int
  ) throws where Bytes.Element == UInt8 {
    try writer.write(bytes: bytes, offset: offset, count: count)
  }

  public func write(byte: UInt8) throws {
    try writer.write(byte: byte)
  }
}
