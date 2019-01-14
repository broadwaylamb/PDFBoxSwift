//
//  RandomAccessWrite.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

/// A protocol allowing random access write operations.
public protocol RandomAccessWrite: Writer, Closeable {
  /// Clears all data of the buffer.
  func clear() throws
}
