//
//  RandomAccessWrite.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

/// A protocol allowing random access write operations.
public protocol RandomAccessWrite: Closeable {

  /// Write a byte to the stream.
  ///
  /// - Parameter byte: The byte to write.
  func write(byte: UInt8) throws

  /// Write a buffer of data to the stream.
  ///
  /// - Parameters:
  ///   - bytes: The buffer to get the data from.
  ///   - offset: An offset into the buffer to get the data from.
  ///   - count: The length of data to write.
  func write<Bytes: Collection>(bytes: Bytes, offset: Int, count: Int) throws
      where Bytes.Element == UInt8

  /// Clears all data of the buffer.
  func clear() throws
}
