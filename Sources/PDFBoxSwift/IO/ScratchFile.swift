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
public final class ScratchFile: Closeable {

  private struct SynchronizedProperties {
    var file: String?
    var raf: RandomAccessFile?
    var pageCount: Int
    var inMemoryPages: [SharedByteBuffer]
    var isClosed: Bool
    var freePages: BitSet

    init() {
      file = nil
      raf = nil
      pageCount = 0
      inMemoryPages = []
      isClosed = false
      freePages = BitSet()
    }
  }

  /// Number of pages by which we enlarge the scratch file
  /// (reduce I/O-operations)
  private static let enlargePageCount = 16

  /// In case of unrestricted main memory usage this is the initial number of
  /// pages `inMemoryPages` is setup for.
  private static let initUnrestrictedMainMemoryPageCount = 100_000

  private static let pageSize = 4096

  private let scratchFileDirectory: String?

  private lazy var synchronized = Synchronized(SynchronizedProperties(),
                                               lock: self)

  private let inMemoryMaxPageCount: Int
  private let maxPageCount: Int
  private let useScratchFile: Bool
  private let maxMainMemoryIsRestricted: Bool
  private let fileSystem: FileSystem?

  /// Initializes page handler.
  ///
  /// Depending on the size of allowed memory usage a number of pages
  /// (`memorySize / pageSize`) will be stored in-memory and only additional
  /// pages will be written to/read from scratch file.
  ///
  /// - Parameters:
  ///   - memoryUsageSetting: How memory/temporary files are used for
  ///                         buffering streams etc.
  ///   - fileSystem: The file system object. It should not be `nil`
  ///                 if `memoryUsageSetting` allows a temporary file.
  public init(memoryUsageSetting: MemoryUsageSetting,
              fileSystem: FileSystem?) throws {

    self.fileSystem = fileSystem
    maxMainMemoryIsRestricted = !memoryUsageSetting.useMainMemory ||
                                memoryUsageSetting.isMainMemoryRestricted
    useScratchFile = maxMainMemoryIsRestricted && memoryUsageSetting.useTempFile
    scratchFileDirectory = useScratchFile ? memoryUsageSetting.tempFileDir : nil

    if let scratchFileDir = scratchFileDirectory {
      if let fileSystem = fileSystem {
        if try !fileSystem.isDirectory(scratchFileDir) {
          throw IOError.scratchFileDirectoryNotFound(path: scratchFileDir)
        }
      } else {
        assertionFailure("""
                         You must provide a file system if you want to use \
                         a temporary file.
                         """)
        throw IOError.missingFileSystem
      }
    }

    let pageSize = UInt64(ScratchFile.pageSize)

    if let maxStorageBytes = memoryUsageSetting.maxStorageBytes,
       memoryUsageSetting.isStorageRestricted {
      maxPageCount = Int(clamping: maxStorageBytes / pageSize)
    } else {
      maxPageCount = .max
    }

    if memoryUsageSetting.useMainMemory {
      if let maxMainMemoryBytes = memoryUsageSetting.maxMainMemoryBytes,
         memoryUsageSetting.isMainMemoryRestricted {
        inMemoryMaxPageCount = Int(clamping: maxMainMemoryBytes / pageSize)
      } else {
        inMemoryMaxPageCount = .max
      }
    } else {
      inMemoryMaxPageCount = 0
    }

    let memoryPagesCount = maxMainMemoryIsRestricted
      ? inMemoryMaxPageCount
      : ScratchFile.initUnrestrictedMainMemoryPageCount

    synchronized.nonatomically { value in
      value.inMemoryPages = Array(repeating: .empty, count: memoryPagesCount)
      value.freePages.set(0..<memoryPagesCount)
    }
  }

  /// Initializes page handler. All pages will be stored in the scratch file.
  ///
  /// - Parameters:
  ///   - directory: The directory in which to create the scratch file.
  ///   - fileSystem: The file system object.
  public convenience init(directory: String, fileSystem: FileSystem) throws {
    try self.init(memoryUsageSetting: .tempFileOnly(tempDirectory: directory),
                  fileSystem: fileSystem)
  }

  deinit {
    try? close()
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

    // No errors should be thrown if using main memory setting
    return try! ScratchFile(memoryUsageSetting: setting, fileSystem: nil)
  }

  /// Returns a new free page, either from free page pool or by enlarging
  /// scratch file (may be created).
  ///
  /// - Returns: Index of the new page.
  internal func newPage() throws -> Int {
    return try synchronized.atomically { value in

      func indexAfterEnlarge() throws -> Int? {
        try enlargeNonatomically()
        return value.freePages.nextBitSet(from: 0)
      }

      guard let index = try value.freePages.nextBitSet(from: 0) ??
        indexAfterEnlarge() else {
        throw IOError.scratchFileMemoryExceeded
      }

      value.freePages[index] = false

      if index >= value.pageCount {
        value.pageCount = index + 1
      }

      return index
    }
  }

  /// This will provide new free pages by either enlarging the scratch file by
  /// a number of pages defined by `ScratchFile.enlargePageCount` - in case
  /// scratch file usage is allowed - or increase the `inMemoryPages` array in
  /// case main memory was not restricted. If neither of both is
  /// allowed/the case than free pages count won't be changed. The same is true
  /// if no new pages could be added because we reached the maximum of
  /// `Int.max` pages.
  ///
  /// If scratch file usage is allowed and scratch file does not exist already
  /// it will be created.
  ///
  /// Only to be called under synchronization.
  private func enlargeNonatomically() throws {

    // We don't synchronize since this method is called from
    // the newPage() method inside a synchronization closure,
    // that would be a deadlock.

    try synchronized.nonatomically { value in
      try checkClosed()

      guard value.pageCount < maxPageCount else {
        return
      }

      if useScratchFile {

        let fs = try getFileSystem()

        let raf: RandomAccessFile

        if let _raf = value.raf {
          raf = _raf
        } else {
          let tempDir = scratchFileDirectory ?? fs.temporaryDirectory
          raf = try fs.createTemporaryFile(prefix: "PDFBoxSwift",
                                           directory: tempDir)
          value.raf = raf
        }

        let fileLength = try raf.count()
        let expectedFileLength =
            UInt64(value.pageCount - inMemoryMaxPageCount) * UInt64(pageSize)

        assert(expectedFileLength == fileLength)

        try raf.truncate(newSize: fileLength +
          UInt64(ScratchFile.enlargePageCount) * UInt64(pageSize))

        value.freePages
          .set(value.pageCount..<value.pageCount + ScratchFile.enlargePageCount)

      } else if !maxMainMemoryIsRestricted {

         // increase number of in-memory pages
        let oldSize = value.inMemoryPages.count
        let newSize = oldSize * 2
        value.inMemoryPages
          .append(contentsOf: repeatElement(.empty, count: newSize - oldSize))
        value.freePages.set(oldSize..<newSize)
      }
    }
  }

  private func getFileSystem() throws -> FileSystem {
    if let fileSystem = fileSystem {
      return fileSystem
    } else {
      assertionFailure("""
                       You must provide a file system if you want to use \
                       a temporary file.
                       """)
      throw IOError.missingFileSystem
    }
  }

  private func getRAFNonatomically() throws -> RandomAccessFile {
    return try synchronized.nonatomically { value in
      if let raf = value.raf {
        return raf
      } else {
        assertionFailure("Random access file is missing")
        throw IOError.scratchFileClosed
      }
    }
  }

  internal var pageSize: Int {
    return ScratchFile.pageSize
  }

  /// Reads the page with specified index.
  ///
  /// - Parameter index: Index of page to read.
  /// - Returns: Buffer of size `pageSize` filled with page data read from file.
  internal func readPage(_ index: Int) throws -> SharedByteBuffer {

    guard index >= 0 && index <= synchronized.value.pageCount else {
      try checkClosed()
      preconditionFailure("Page index out of bounds")
    }

    // check if we have the page in memory
    if index < inMemoryMaxPageCount {
      let page = synchronized.value.inMemoryPages[index]

      if page.isEmpty {
        try checkClosed()
        preconditionFailure("Requested page was not written before")
      }

      return page
    }

    return try synchronized.atomically { value in

      let raf = try getRAFNonatomically()

      try raf.seek(position: UInt64(index - inMemoryMaxPageCount)
        * UInt64(pageSize))

      return try SharedByteBuffer(moving: raf.readFully(count: pageSize))
    }
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

    guard index >= 0 && index <= synchronized.value.pageCount else {
      try checkClosed()
      preconditionFailure("Page index out of bounds")
    }

    assert(buffer.count == pageSize, "Wrong page size to write")

    try synchronized.atomically { value in
      try checkClosed()
      if index < inMemoryMaxPageCount {
        value.inMemoryPages[index] = buffer
      } else {
        let raf = try getRAFNonatomically()
        try raf.seek(position: UInt64(index - inMemoryMaxPageCount)
          * UInt64(pageSize))
        try raf.write(bytes: buffer)
      }
    }
  }

  /// Checks if this page handler has already been closed. If so, an `IOError`
  /// is thrown.
  internal func checkClosed() throws {
    if synchronized.value.isClosed {
      throw IOError.scratchFileClosed
    }
  }

  /// Creates a new buffer using this page handler and initializes it with
  /// the data read from provided input stream (input stream is copied to
  /// buffer). The buffer data pointer is reset to point to first byte.
  ///
  /// - Parameter input: The input stream that is to be copied into the buffer,
  ///                    or `nil`. Default value is `nil`.
  /// - Returns: A new buffer containing data read from input stream.
  public func createBuffer(input: InputStream? = nil) throws -> RandomAccess {

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

  /// Allows a buffer which is cleared/closed to release its pages
  /// to be re-used.
  ///
  /// - Parameter indices: Indices of pages to release.
  internal func markPagesAsFree(indices: ArraySlice<Int>) {
    synchronized.atomically { value in

      for i in indices
          where i >= 0 && i < value.pageCount && !value.freePages[i] {

        value.freePages[i] = true
        if i < inMemoryMaxPageCount {
          value.inMemoryPages[i] = .empty
        }
      }
    }
  }

  /// Closes and deletes the temporary file. No further interaction with
  /// the scratch file or associated buffers can happen after this method is
  /// called. It also releases in-memory pages.
  public func close() throws {
    try synchronized.atomically { value in

      if value.isClosed {
        return
      }

      var ensure = Ensure()

      if let raf = value.raf {
        ensure.do { try raf.close() }
        ensure.do { try getFileSystem().deleteFile(path: raf.path) }
        value.raf = nil
      }

      value.isClosed = true
      value.freePages.clear()
      value.pageCount = 0

      try ensure.done()
    }
  }
}
