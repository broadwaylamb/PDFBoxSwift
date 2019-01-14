//
//  ScratchFileBuffer.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 14/01/2019.
//

/// Implementation of `RandomAccess` as sequence of multiple fixed size pages
/// handled by `ScratchFile`.
internal final class ScratchFileBuffer {

  private var pageSize: Int

  /// The underlying page handler.
  private var pageHandler: ScratchFile?

  /// The number of bytes of content in this buffer.
  private var size: UInt64 = 0

  /// Index of current page in `pageIndexes` (the nth page within this buffer).
  private var currentPagePositionInPageIndexes = -1

  /// The offset of the current page within this buffer.
  private var currentPageOffset: UInt64 = 0

  /// The current page data.
  private var currentPage: SharedByteBuffer = .empty

  /// The current position (for next read/write) of the buffer as an offset in
  /// the current page.
  private var positionInPage = 0

  /// `true` if current page was changed by a write method
  private var currentPageContentChanged = false

  /// The list of pages with the index the page is known by page handler
  /// (`ScratchFile`)
  private var pageIndices: [Int] = []

  init(pageHandler: ScratchFile) throws {
    try pageHandler.checkClosed()
    self.pageHandler = pageHandler
    pageSize = pageHandler.pageSize
  }

  deinit {
    try? close()
  }

  /// Checks if this buffer, or the underlying `ScratchFile` have been closed,
  /// throwing `IOError` if so.
  func checkClosed() throws {
    if let pageHandler = pageHandler {
      try pageHandler.checkClosed()
    } else {
      throw IOError.bufferClosed
    }
  }

  /// Adds a new page and positions all pointers to start of new page.
  private func addPage() throws {
    let newPageIndex = try getPageHandler().newPage()
    currentPagePositionInPageIndexes = pageIndices.endIndex
    currentPageOffset = UInt64(pageIndices.count) * UInt64(pageSize)
    pageIndices.append(newPageIndex)
    positionInPage = 0
    currentPage = SharedByteBuffer(capacity: pageSize)
  }

  private func getPageHandler() throws -> ScratchFile {
    if let pageHandler = pageHandler {
      return pageHandler
    } else {
      throw IOError.bufferClosed
    }
  }

  @discardableResult
  private func ensureAvailableBytesInPage(
    addNewPageIfNeeded: Bool
  ) throws -> Bool {

    guard positionInPage >= pageSize else {
      return true
    }

    // page full
    if currentPageContentChanged {
      // write page
      try pageHandler?
        .writePage(pageIndices[currentPagePositionInPageIndexes],
                   buffer: currentPage)
      currentPageContentChanged = false
    }

    // get new page
    if currentPagePositionInPageIndexes + 1 < pageIndices.count {
      // we already have more pages assigned (there was a backward seek before)
      currentPage = try getPageHandler()
        .readPage(pageIndices[currentPagePositionInPageIndexes])
      currentPagePositionInPageIndexes += 1
      currentPageOffset =
          UInt64(currentPagePositionInPageIndexes) * UInt64(pageSize)
      positionInPage = 0
    } else if addNewPageIfNeeded {
      // need new page
      try addPage()
    } else {
      // we are at last page and are not allowed to add new page
      return false
    }

    return true
  }
}

extension ScratchFileBuffer: RandomAccess {

  func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
            offset: Int,
            count: Int) throws -> Int? {

    precondition(offset >= 0 && count >= 0 || count > buffer.count - offset,
                 "Index out of bounds")

    try checkClosed()

    if currentPageOffset + UInt64(positionInPage) >= size {
      return nil
    }

    var remain =
      Int(min(UInt64(count), size - currentPageOffset - UInt64(positionInPage)))

    var totalBytesRead = 0
    var bOff = offset

    while remain > 0 {
      if try !ensureAvailableBytesInPage(addNewPageIfNeeded: false) {
        // should never happen
        throw IOError.unexpectedEOF
      }

      guard let currentPagePtr = currentPage.buffer.baseAddress else {
        assertionFailure("The buffer must not be NULL")
        return nil
      }

      let readBytes = min(remain, pageSize - positionInPage)

      buffer.baseAddress?.advanced(by: bOff)
        .initialize(from: currentPagePtr.advanced(by: positionInPage),
                    count: readBytes)

      positionInPage += readBytes
      totalBytesRead += readBytes
      bOff += readBytes
      remain -= readBytes
    }

    return totalBytesRead
  }

  func read() throws -> UInt8? {
    try checkClosed()

    if currentPageOffset + UInt64(positionInPage) >= size {
      return nil
    }

    if try !ensureAvailableBytesInPage(addNewPageIfNeeded: false) {
      // should never happen
      throw IOError.unexpectedEOF
    }

    let byte = currentPage[positionInPage]
    positionInPage += 1
    return byte
  }

  func position() throws -> UInt64 {
    try checkClosed()
    return currentPageOffset + UInt64(positionInPage)
  }

  func seek(position: UInt64) throws {

    try checkClosed()

    // for now we won't allow to seek past end of buffer;
    // this can be changed by adding new pages as needed
    if position > size {
      throw IOError.unexpectedEOF
    }

    if position >= currentPageOffset &&
       position <= currentPageOffset + UInt64(pageSize) {
      // within the same page
      positionInPage = Int(position - currentPageOffset)
    } else {
      // have to go to another page

      let pageHandler = try getPageHandler()

      // check if current page needs to be written to file
      if currentPageContentChanged {
        try pageHandler.writePage(pageIndices[currentPagePositionInPageIndexes],
                                  buffer: currentPage)
        currentPageContentChanged = false
      }

      let newPagePosition = Int(position / UInt64(pageSize))

      currentPage = try pageHandler.readPage(pageIndices[newPagePosition])
      currentPagePositionInPageIndexes = newPagePosition
      currentPageOffset =
          UInt64(currentPagePositionInPageIndexes) * UInt64(pageSize)
      positionInPage = Int(position - currentPageOffset)
    }
  }

  func count() throws -> UInt64 {
    return size
  }

  var isClosed: Bool {
    return pageHandler == nil
  }

  func peek() throws -> UInt8? {
    return try read().map {
      try rewind(count: 1)
      return $0
    }
  }

  func rewind(count: UInt64) throws {
    try seek(position: currentPageOffset + UInt64(positionInPage) - count)
  }

  func readFully(count: Int) throws -> UnsafeBufferPointer<UInt8> {
    let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: count)

    do {
      var n = 0
      repeat {
        if let bytesRead = try read(into: buffer, offset: n, count: count - n) {
          n += bytesRead
        } else {
          throw IOError.unexpectedEOF
        }
      } while n < count
    } catch {
      buffer.deallocate()
      throw error
    }

    return UnsafeBufferPointer(buffer)
  }

  func isEOF() throws -> Bool {
    try checkClosed()
    return currentPageOffset + UInt64(positionInPage) >= size
  }

  func available() throws -> Int {
    try checkClosed()
    return Int(clamping: size - currentPageOffset - UInt64(positionInPage))
  }

  func write(byte: UInt8) throws {
    try checkClosed()

    try ensureAvailableBytesInPage(addNewPageIfNeeded: true)

    currentPage[positionInPage] = byte
    positionInPage += 1
    currentPageContentChanged = true

    if currentPageOffset + UInt64(positionInPage) > size {
      size = currentPageOffset + UInt64(positionInPage)
    }
  }

  func write(bytes: UnsafeBufferPointer<UInt8>,
             offset: Int,
             count: Int) throws {

    precondition(
      offset >= 0 &&
      offset < bytes.count &&
      count >= 0 &&
      (offset + count) <= bytes.count,
      "Index out of bounds"
    )

    try checkClosed()

    var remain = count
    var bOff = offset

    while remain > 0 {
      try ensureAvailableBytesInPage(addNewPageIfNeeded: true)

      let bytesToWrite = min(remain, pageSize - positionInPage)

      guard let ptr = bytes.baseAddress else {
        assertionFailure("The buffer must not be NULL")
        return
      }

      currentPage.buffer.baseAddress?.advanced(by: positionInPage)
        .initialize(from: ptr.advanced(by: bOff), count: bytesToWrite)

      positionInPage += bytesToWrite
      currentPageContentChanged = true
      bOff += bytesToWrite
      remain -= bytesToWrite
    }

    if currentPageOffset + UInt64(positionInPage) > size {
      size = currentPageOffset + UInt64(positionInPage)
    }
  }

  func clear() throws {

    try checkClosed()

    let pageHandler = try getPageHandler()

    // keep only the first page, discard all other pages
    pageHandler.markPagesAsFree(indices: pageIndices[1...])
    pageIndices.removeLast(pageIndices.count - 1)

    // change to first page if we are not already there
    if currentPagePositionInPageIndexes > 0 {
      currentPage = try pageHandler.readPage(pageIndices[0])
      currentPagePositionInPageIndexes = 0
      currentPageOffset = 0
    }

    positionInPage = 0
    size = 0
    currentPageContentChanged = false
  }

  func close() throws {
    pageHandler?.markPagesAsFree(indices: pageIndices[0...])
    pageHandler = nil

    pageIndices = []
    currentPage = .empty
    currentPageOffset = 0
    currentPagePositionInPageIndexes = -1
    positionInPage = 0
    size = 0
  }
}
