//
//  OutputStream.swift
//  PDFBoxSwiftIO
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// This protocol representing an output stream of bytes. An output stream
/// accepts output bytes and sends them to some sink.
///
/// Implementors must always provide at least a method that writes one byte of
/// output.
public protocol OutputStream: Writer, Closeable, Flushable {}

extension OutputStream {
  public func close() throws {}
}
