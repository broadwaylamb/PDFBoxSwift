//
//  COSStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

public final class COSStream: COSDictionary, Closeable {

  /// Backing store, in-memory or on-disk.
  fileprivate var randomAccess: RandomAccess?

  /// Used as a tempotary buffer during decoding
  private let scratchFile: ScratchFile

  /// `true` if there's an open `OutputStream`
  fileprivate var isWriting = false

  /// Creates a new stream with an empty dictionary.
  ///
  /// Try to avoid using this initialized because it creates a new scratch file
  /// in memory. Instead, use document.cosDocument.createCOSStream() which will
  /// use the existing scratch file (in memory or in temp file) of the document.
  public convenience override init() {
    self.init(scratchFile: .createMainMemoryOnly())
  }

  /// Creates a new stream with an empty dictionary. Data is stored in
  /// the given scratch file.
  ///
  /// - Parameter scratchFile: Scratch file for writing stream data.
  public init(scratchFile: ScratchFile) {
    self.scratchFile = scratchFile
    super.init()
    self[native: .length] = 0
  }

  private func checkClosed() throws {
    if let ra = randomAccess, ra.isClosed {
      throw IOError.streamClosed
    }
  }

  /// Ensures `randomAccess` is not `nil` by creating a buffer from
  /// `scratchFile` if needed.
  ///
  /// - Parameter forInputStream: if `true` and `randomAccess` is `nil`
  /// assertion failure will occur - input stream should be retrieved after
  /// data being written to stream
  /// - Returns: The random access object.
  private func getRandomAccess(forInputStream: Bool) throws -> RandomAccess {
    if let ra = randomAccess {
      return ra
    }

    if forInputStream {
      assertionFailure(
        "Create InputStream called without data being written before to stream."
      )
    }

    let ra = try scratchFile.createBuffer()
    randomAccess = ra
    return ra
  }

  /// Returns a new `InputStream` which reads the encoded PDF stream data.
  /// Experts only!
  ///
  /// - Returns: `InputStream` containing raw, encoded PDF stream data.
  public func createRawInputStream() throws -> InputStream {
    try checkClosed()
    if isWriting {
      preconditionFailure("Cannot read while there is an open stream writer")
    }

    let ra = try getRandomAccess(forInputStream: true)
    return RandomAccessInputStream(read: ra)
  }

  /// Returns a new `COSInputStream` which reads the decoded stream data.
  ///
  /// - Parameter options: The decoding options.
  /// - Returns: The stream containing decoded stream data.
  public func createInputStream(
    options: DecodeOptions = .default
  ) throws -> COSInputStream {
    let input = try createRawInputStream()
    return try COSInputStream(filters: getFilters(),
                              parameters: self,
                              input: input,
                              scratchFile: scratchFile,
                              options: options)
  }

  /// Returns a new `OutputStream` for writing encoded PDF data. Experts only!
  ///
  /// - Returns: `OutputStream` for raw PDF stream data.
  public func createRawOutputStream() throws -> OutputStream {
    try checkClosed()
    precondition(!isWriting, "Cannot have more than one open stream writer")
    try? randomAccess?.close() // Ignore any errors
    let ra = try scratchFile.createBuffer()
    randomAccess = ra
    let out = RandomAccessOutputStream(writer: ra)
    isWriting = true
    return COSStreamFilterOutputStream(out: out, cosStream: self)
  }

  /// Returns a new `OutputStream` for writing stream data, using and the given
  /// filters.
  ///
  /// - Parameter filters: `COSArray` or `COSName` of filters to be used.
  /// - Returns: `OutputStream` for un-encoded stream data.
  public func createOutputStream(
    filters: Either<COSName, COSArray>?
  ) throws -> OutputStream {
    try checkClosed()
    precondition(!isWriting, "Cannot have more than one open stream writer")

    if case .right(let filters)? = filters {
      for filter in filters {
        assert(filter is COSName, """
               Array of filters must not containg an object \
               of type \(type(of: filter))
               """)
      }
    }

    if let filters = filters {
      self[cos: .filter] = filters
    }
    try? randomAccess?.close() // Ignore any errors
    let ra = try scratchFile.createBuffer()
    randomAccess = ra
    let randomOut = RandomAccessOutputStream(writer: ra)
    let cosOut = try COSOutputStream(filters: getFilters(),
                                     parameters: self,
                                     output: randomOut,
                                     scratchFile: scratchFile)
    isWriting = true
    return COSStreamFilterOutputStream(out: cosOut, cosStream: self)
  }

  /// Returns a new `OutputStream` for writing stream data, using and the given
  /// filter.
  ///
  /// - Parameter filter: The filter to be used.
  /// - Returns: `OutputStream` for un-encoded stream data.
  public func createOutputStream<T: Filter>(
    filter: TypedCOSName<T>
  ) throws -> OutputStream {
    return try createOutputStream(filters: .left(filter.key))
  }

  /// Returns a new `OutputStream` for writing stream data, using and the given
  /// filters.
  ///
  /// - Parameter filters: Array of filters to be used.
  /// - Returns: `OutputStream` for un-encoded stream data.
  public func createOutputStream(filters: COSArray) throws -> OutputStream {
    return try createOutputStream(filters: .right(filters))
  }

  private func getFilters() throws -> [Filter] {
    return try self.filters?.transform(ifLeft: { name in
      return try [FilterFactory.filter(forName: name)]
    }, ifRight: { array in
      try array.lazy.compactMap { $0 as? COSName }.map(FilterFactory.filter)
    }) ?? []
  }

  /// The length of the encoded stream.
  public var length: Int {
    precondition(!isWriting, """
                 There is an open OutputStream associated with \
                 this COSStream. It must be closed before querying
                 length of this COSStream.
                 """)

    return self[native: .length, default: 0]
  }

  /// The filters to apply to the byte stream.
  ///
  /// - `nil` if no filters are to be applied
  /// - A `COSName` if one filter is to be applied
  /// - A `COSArray` containing `COSNames` if multiple filters are to be
  ///   .applied
  public var filters: Either<COSName, COSArray>? {
    return self[cos: .filter]
  }

  func textString() -> String {
    let out = ByteArrayOutputStream()

    do {
      let input = try createInputStream()
      try input.copy(to: out)
    } catch {
      assertionFailure(String(describing: error))
      return String()
    }

    return COSString(bytes: out.bytes).string()
  }

  public override func accept(visitor: COSVisitorProtocol) throws -> Any? {
    return try visitor.visit(self)
  }

  public func close() throws {
    // marks the scratch file pages as free
    try randomAccess?.close()
  }
}

private class COSStreamFilterOutputStream: FilterOutputStream {

  let cosStream: COSStream

  init(out: OutputStream, cosStream: COSStream) {
    self.cosStream = cosStream
    super.init(out: out)
  }

  override func close() throws {
    try super.close()
    cosStream[native: .length] = try cosStream.randomAccess?.count()
    cosStream.isWriting = false
  }
}
