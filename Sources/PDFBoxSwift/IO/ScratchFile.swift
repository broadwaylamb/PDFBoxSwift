//
//  ScratchFile.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 14/01/2019.
//

/// Implements a memory page handling mechanism as base for creating (multiple)
/// `RandomAccess` buffers each having its set of pages (implemented by
/// `ScratchFileBuffer`). A buffer is created calling `createBuffer(input:)`.
///
/// Pages can be stored in main memory or in a temporary file. A mixed mode is
/// supported storing a certain amount of pages in memory and only
/// the additional ones in temporary file (defined by maximum main memory to be
/// used).
///
/// Pages can be marked as 'free' in order to re-use them. For in-memory pages
/// this will release the used memory while, for pages in temporary file this
/// simply marks the area as free to re-use.
///
/// If a temporary file was created (done with the first page to be stored in
/// temporary file) it is deleted when `close()` is called.
///
/// Using this class for `RandomAccess` buffers allows for a direct control on
/// the maximum memory usage and allows processing large files for which we
/// otherwise would run out of memory in case of using `RandomAccessBuffer`.
open class ScratchFile: Closeable {

  /// Number of pages by which we enlarge the scratch file
  /// (reduce I/O-operations)
  private static let enlargePageCount = 16

  /// In case of unrestricted main memory usage this is the initial number of
  /// pages `inMemoryPages` is setup for.
  private static let initUnrestrictedMainMemoryPageCount = 100_000

  private static let pageSize = 4096

  private var isClosed = false

  /// Initializes page handler.
  ///
  /// Depending on the size of allowed memory usage a number of pages
  /// (`memorySize / pageSize`) will be stored in-memory and only additional
  /// pages will be written to/read from scratch file.
  ///
  /// - Parameter memoryUsageSetting: How memory/temporary files are used for
  ///                                 buffering streams etc.
  public init(memoryUsageSetting: MemoryUsageSetting) throws {
    // TODO
    fatalError()
  }

  /// Initializes page handler. All pages will be stored in the scratch file.
  ///
  /// - Parameter directory: The directory in which to create the scratch file.
  public convenience init(directory: String) throws {
    try self.init(memoryUsageSetting: .tempFileOnly(tempDirectory: directory))
  }

  /// Use only unrestricted main memory for buffering (same as
  /// `ScratchFile(memoryUsageSetting: .mainMemoryOnly()`).
  ///
  /// - Parameter maxMainMemoryBytes: Maximum number of main-memory to be used;
  ///   `nil` for no restriction; 0 will also be interpreted here as
  ///   no restriction. Default value is `nil`.
  /// - Returns: Instance configured to only use main memory.
  public static func createMainMemoryOnly(
    maxMainMemoryBytes: UInt64? = nil
  ) -> ScratchFile {
    let setting = MemoryUsageSetting
      .mainMemoryOnly(maxMainMemoryBytes: maxMainMemoryBytes)
    return try! ScratchFile(memoryUsageSetting: setting)
  }

  /// Returns a new free page, either from free page pool or by enlarging
  /// scratch file (may be created).
  ///
  /// - Returns: Index of the new page.
  internal func newPage() throws -> Int {
    // TODO
    fatalError()
  }

  /// Creates a new buffer using this page handler and initializes it with
  /// the data read from provided input stream (input stream is copied to
  /// buffer). The buffer data pointer is reset to point to first byte.
  ///
  /// - Parameter input: The input stream that is to be copied into the buffer,
  ///                    or `nil`. Default value is `nil`.
  /// - Returns: A new buffer containing data read from input stream.
  open func createBuffer(input: InputStream? = nil) throws -> RandomAccess {

    let buf = try ScratchFileBuffer(pageHandler: self)

    if let input = input {
      let byteBuffer = UnsafeMutableBufferPointer<UInt8>
        .allocate(capacity: 8192)
      defer { byteBuffer.deallocate() }

      while let bytesRead = try input.read(into: byteBuffer) {
        try buf.write(bytes: byteBuffer, offset: 0, count: bytesRead)
      }
      try buf.seek(position: 0)
    }

    return buf
  }

  internal func markPagesAsFree(indices: ArraySlice<Int>) {
    // TODO
    fatalError()
  }

  open func close() throws {
    // TODO
    fatalError()
  }

  /// Checks if this page handler has already been closed. If so, an `IOError`
  /// is thrown.
  internal func checkClosed() throws {
    if isClosed {
      throw IOError.scratchFileClosed
    }
  }

  internal var pageSize: Int {
    return ScratchFile.pageSize
  }

  /// Reads the page with specified index.
  ///
  /// - Parameter index: Index of page to read.
  /// - Returns: Buffer of size `pageSize` filled with page data read from file.
  internal func readPage(
    _ index: Int
  ) throws -> SharedByteBuffer {

    // TODO
    fatalError()
  }

  /// Writes updated page. Page is either kept in-memory if
  /// `index` is less than `inMemoryMaxPageCount` or is written to scratch file.
  ///
  /// Provided `buffer` must not be re-used for other pages since we store it as
  /// is in case of in-memory handling.
  ///
  /// - Parameters:
  ///   - index: Index of the page to write.
  ///   - buffer: The page to write (length has to be `pageSize`).
  internal func writePage(_ index: Int,
                          buffer: SharedByteBuffer) throws {
    // TODO
    fatalError()
  }
}
