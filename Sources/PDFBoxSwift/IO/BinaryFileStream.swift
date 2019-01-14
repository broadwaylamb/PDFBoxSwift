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

    try wrapSyscall { () -> Int32 in
      raw = fopen(path, mode)
      return raw == nil ? EOF : 0
    }
  }

  public final var isClosed: Bool {
    return raw == nil
  }

  public final func close() throws {

    try withUnsafeMutablePointer { descriptor in
      if fclose(descriptor) != 0 {

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

  public final func withUnsafeMutablePointer<T>(
    _ body: (UnsafeMutablePointer<FILE>) throws -> T
    ) throws -> T {
    guard let pointer = raw else {
      throw FileIOError(errnoCode: EBADF,
                        reason: "File descriptor already closed!")
    }
    return try body(pointer)
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

#endif
