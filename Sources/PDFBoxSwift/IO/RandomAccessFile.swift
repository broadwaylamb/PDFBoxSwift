//
//  RandomAccessFile.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 16/01/2019.
//

public protocol RandomAccessFile: RandomAccessRead, InputStream, OutputStream {

  var path: String { get }

  /// Truncate or extend a file to a specified `newSize`.
  ///
  /// - Parameter newSize: The new size of the file.
  func truncate(newSize: UInt64) throws
}
