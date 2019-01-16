//
//  RandomAccessFile.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 16/01/2019.
//

public protocol RandomAccessFile: RandomAccess, InputStream, OutputStream {

  var path: String { get }

  /// Truncate or extend a file to a specified `newSize`.
  ///
  /// - Parameter newSize: The new size of the file.
  func truncate(newSize: UInt64) throws
}

extension RandomAccessFile {

  public func clear() throws {
    try seek(position: 0)
    try truncate(newSize: 0)
  }
}
