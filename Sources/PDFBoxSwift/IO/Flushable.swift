//
//  Flushable.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

/// A `Flushable` is a destination of data that can be flushed. The `flush`
/// method is invoked to write any buffered output to the underlying stream.
public protocol Flushable: AnyObject {

  /// Flushes this output stream and forces any buffered output bytes to be
  /// written out. The general contract of `flush` is that calling it is
  /// an indication that, if any bytes previously written have been buffered
  /// by the implementation of the output stream, such bytes should immediately
  /// be written to their intended destination.
  ///
  /// If the intended destination of this stream is an abstraction provided
  /// by the underlying operating system, for example a file, then flushing
  /// the stream guarantees only that bytes previously written to the stream
  /// are passed to the operating system for writing; it does not guarantee
  /// that they are actually written to a physical device such as a disk drive.
  ///
  /// The default implementation does nothing.
  ///
  /// **Required**. Default implementation provided.
  func flush() throws
}

extension Flushable {
  public func flush() throws {}
}
