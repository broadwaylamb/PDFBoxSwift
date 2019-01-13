//
//  Flushable.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

/// A `Flushable` is a destination of data that can be flushed. The `flush`
/// method is invoked to write any buffered output to the underlying stream.
public protocol Flushable: AnyObject {

  /// Flushes this stream by writing any buffered output to the underlying
  /// stream.
  func flush() throws
}
