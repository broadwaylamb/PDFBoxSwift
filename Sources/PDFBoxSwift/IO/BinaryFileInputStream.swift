//
//  BinaryFileInputStream.swift
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

public final class BinaryFileInputStream: BinaryFileStream {

  private var fileLength: UInt64 = 0
  private var fileOffset: UInt64 = 0

  public override init(path: String) throws {
    try super.init(path: path)

    try wrapSyscall(where: "stat") { () -> Int32 in
      var sb = stat()
      let result = stat(path, &sb)
      fileLength = UInt64(sb.st_size)
      return result
    }

    try open(mode: "rb")
  }
}

extension BinaryFileInputStream: InputStream {

  public func read() throws -> UInt8? {
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

  public func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
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

  public func available() throws -> Int {
    return Int(clamping: fileLength - fileOffset)
  }
}

extension BinaryFileInputStream: RandomAccessRead {

  public func position() throws -> UInt64 {
    return fileOffset
  }

  public func seek(position: UInt64) throws {
    try withUnsafeMutablePointer { cStream in
      if fseek(cStream, Int(position), SEEK_SET) != 0 {
        throw IOError.readingError
      }
      fileOffset = position
    }
  }

  public func count() throws -> UInt64 {
    return fileLength
  }

  public func peek() throws -> UInt8? {
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

  public func rewind(count: UInt64) throws {
    try seek(position: position() - count)
  }

  public func isEOF() throws -> Bool {
    return try withUnsafeMutablePointer { cStream in
      feof(cStream) != 0
    }
  }
}

#endif
