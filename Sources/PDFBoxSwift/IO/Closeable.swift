//
//  Closeable.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

/// A `Closeable` is a source or destination of data that can be closed.
/// The `close` method is invoked to release resources that the object is
/// holding (such as open files).
public protocol Closeable: AnyObject {

  /// Closes this stream and releases any system resources associated with it.
  /// If the stream is already closed then invoking this method has no effect.
  func close()
}
