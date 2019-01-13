//
//  FilterOutputStream.swift
//  PDFBoxSwiftIO
//
//  Created by Sergej Jaskiewicz on 10/01/2019.
//

/// This class is the superclass of all classes that filter output streams.
/// These streams sit on top of an already existing output stream
/// (the *underlying* output stream) which it uses as its basic sink of data,
/// but possibly transforming the data along the way or providing additional
/// functionality.
///
/// The class `FilterOutputStream` itself simply overrides all methods of
/// OutputStream with versions that pass all requests to the underlying output
/// stream. Subclasses of `FilterOutputStream` may further override some of
/// these methods as well as provide additional methods and fields.
public class FilterOutputStream: OutputStream {

  /// The underlying output stream to be filtered.
  public let out: OutputStream

  /// Whether the stream is closed; implicitly initialized to `false`.
  private var isClosed: Bool = false

  /// Creates an output stream filter built on top of the specified underlying
  /// output stream.
  ///
  /// - Parameter out: The underlying output stream to be assigned to the field
  ///             `self.out` for later use.
  public init(out: OutputStream) {
    self.out = out
  }

  deinit {
    try? close()
  }

  /// Writes the specified byte to this output stream.
  ///
  /// The `write(byte:)` method of `FilterOutputStream` calls
  /// the `write(byte:)` method of its underlying output stream, that is,
  /// it performs `out.write(byte: byte)`.
  ///
  /// Implements the requirement of `OutputStream`.
  ///
  /// - Parameter byte: The byte.
  public func write(byte: UInt8) throws {
    try out.write(byte: byte)
  }

  /// Flushes this output stream and forces any buffered output bytes to be
  /// written out to the stream.
  /// The `flush` method of `FilterOutputStream` calls the `flush` method of
  /// its underlying output stream.
  public func flush() throws {
    try out.flush()
  }

  /// Closes this output stream and releases any system resources associated
  /// with the stream.
  ///
  /// When not already closed, the `close` method of `FilterOutputStream` calls
  /// its `flush` method, and then calls the `close` method of its underlying
  /// output stream.
  public func close() throws {
    if isClosed {
      return
    }

    isClosed = true

    try flush()
    try out.close()
  }
}
