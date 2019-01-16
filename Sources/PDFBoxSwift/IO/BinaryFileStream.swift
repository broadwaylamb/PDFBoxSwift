//
//  BinaryFileStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 14/01/2019.
//

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

#if canImport(Darwin) || canImport(Glibc)

public class BinaryFileStream: Closeable {

  internal var fileLength: UInt64 = 0

  internal var fileOffset: UInt64 = 0 {
    didSet {
      if fileOffset > fileLength {
        fileLength = fileOffset
      }
    }
  }

  private var raw: UnsafeMutablePointer<FILE>?

  public final let path: String

  internal init(path: String) throws {
    self.path = path
  }

  deinit {
    if !isClosed {
      try? close()
    }
  }

  internal final func open(mode: String) throws {
    try wrapSyscall { () -> CInt in
      raw = fopen(path, mode)
      return raw == nil ? EOF : 0
    }
  }

  internal final func open(descriptor: Int32, mode: String) throws {
    try wrapSyscall { () -> CInt in
      raw = fdopen(descriptor, mode)
      return raw == nil ? EOF : 0
    }
  }

  public final var isClosed: Bool {
    return raw == nil
  }

  public final func close() throws {

    try withUnsafeMutablePointer { cStream in
      if fclose(cStream) != 0 {

        // There is really nothing "sane" we can do when EINTR was reported on
        // close. So just ignore it and "assume" everything is fine == we closed
        // the file descriptor.
        let err = errno
        if err != EINTR {
          assertIsNotBlacklistedErrno(err: err, where: #function)
          throw FileIOError(errnoCode: err, function: "fclose")
        }
      }
    }

    raw = nil
  }

  public final func withUnsafeMutablePointer<Result>(
    _ body: (UnsafeMutablePointer<FILE>) throws -> Result
  ) throws -> Result {
    guard let pointer = raw else {
      throw FileIOError(errnoCode: EBADF,
                        reason: "File descriptor already closed!")
    }
    return try body(pointer)
  }

  public final func withUnsafeFileDescriptor<Result>(
    _ body: (CInt) throws -> Result
  ) throws -> Result {
    return try withUnsafeMutablePointer { try body(fileno($0)) }
  }

  // MARK: - Writing

  internal func write(byte: UInt8) throws {
    try withUnsafeMutablePointer { pointer in
      if fputc(Int32(byte), pointer) == EOF {
        throw IOError.writingError
      }
    }
    fileOffset += 1
  }

  internal func write(bytes: UnsafeBufferPointer<UInt8>,
                      offset: Int,
                      count: Int) throws {
    try withUnsafeMutablePointer { cStream in
      let ptr = bytes.baseAddress?.advanced(by: offset)
      if fwrite(ptr, /*size of UInt8*/ 1, count, cStream) != count {
        throw IOError.writingError
      }
    }
    fileOffset += UInt64(count)
  }

  internal func flush() throws {
    try withUnsafeMutablePointer { cStream in
      if fflush(cStream) != 0 {
        throw IOError.writingError
      }
    }
  }

  internal func truncate(newSize: UInt64) throws {
    try withUnsafeFileDescriptor { fd -> Void in
      try wrapSyscall { ftruncate(fd, Int64(clamping: newSize)) }
    }
    fileLength = newSize
  }

  // MARK: Reading

  internal func read() throws -> UInt8? {
    return try withUnsafeMutablePointer { cStream in
      let result = fgetc(cStream)
      if result == EOF {
        if ferror(cStream) == 0 {
          return nil
        } else {
          throw IOError.readingError
        }
      } else {
        fileOffset += 1
        return UInt8(truncatingIfNeeded: result)
      }
    }
  }

  internal func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
                     offset: Int,
                     count: Int) throws -> Int? {

    precondition(offset >= 0 && count >= 0 || count > buffer.count - offset,
                 "Index out of bounds")

    guard try !isEOF() else { return nil }

    return try withUnsafeMutablePointer { cStream in
      let buffer = buffer.baseAddress?.advanced(by: offset)
      let result = fread(buffer, /*size of UInt8*/ 1, count, cStream)
      fileOffset += UInt64(result)
      if result != count && ferror(cStream) != 0 {
        throw IOError.readingError
      }
      return result
    }
  }

  internal func available() throws -> Int {
    return Int(clamping: fileLength - fileOffset)
  }

  internal func position() throws -> UInt64 {
    return fileOffset
  }

  internal func seek(position: UInt64) throws {
    try withUnsafeMutablePointer { cStream in
      if fseek(cStream, Int(position), SEEK_SET) != 0 {
        throw IOError.readingError
      }
      fileOffset = position
    }
  }

  internal func count() throws -> UInt64 {
    return fileLength
  }

  internal func peek() throws -> UInt8? {
    return try withUnsafeMutablePointer { cStream in
      let result = fgetc(cStream)
      ungetc(result, cStream)
      if result == EOF {
        if ferror(cStream) == 0 {
          return nil
        } else {
          throw IOError.readingError
        }
      } else {
        return UInt8(truncatingIfNeeded: result)
      }
    }
  }

  internal func rewind(count: UInt64) throws {
    try seek(position: position() - count)
  }

  internal func isEOF() throws -> Bool {
    return try withUnsafeMutablePointer { feof($0) != 0 }
  }
}

private func isBlacklistedErrno(_ code: CInt) -> Bool {
  switch code {
  case EFAULT, EBADF:
    return true
  default:
    return false
  }
}

private func assertIsNotBlacklistedErrno(
  err: CInt,
  where function: StaticString
) -> Void {
  // strerror is documented to return "Unknown error: ..." for illegal value
  // so it won't ever fail
  assert(!isBlacklistedErrno(err),
         """
         blacklisted errno \(err) \(String(cString: strerror(err)!)) \
         in \(function))
         """)
}

@inline(__always)
@discardableResult
internal func wrapSyscall<T: FixedWidthInteger>(
  where function: StaticString = #function,
  _ body: () throws -> T
) throws -> T {
  while true {
    let res = try body()
    if res != 0 {
      let err = errno
      if err == EINTR {
        continue
      }
      assertIsNotBlacklistedErrno(err: err, where: function)
      throw FileIOError(errnoCode: err, function: function)
    }
    return res
  }
}

internal func getStat(_ path: String) throws -> stat {
  var sb = stat()
  try wrapSyscall(where: "stat") { stat(path, &sb) }
  return sb
}

#endif
