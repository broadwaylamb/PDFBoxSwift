//
//  BinaryFileOutputStream.swift
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

public final class BinaryFileOutputStream: BinaryFileStream {

  public override init(path: String) throws {
    try super.init(path: path)

    try open(mode: "wb")
  }
}

extension BinaryFileOutputStream: OutputStream {

  public func write(byte: UInt8) throws {
    try withUnsafeMutablePointer { pointer in
      if fputc(Int32(byte), pointer) == EOF {
        throw IOError.writingError
      }
    }
  }

  public func write(bytes: UnsafeBufferPointer<UInt8>,
                    offset: Int,
                    count: Int) throws {
    try withUnsafeMutablePointer { cStream in
      let ptr = bytes.baseAddress?.advanced(by: offset)
      if fwrite(ptr, /*size of UInt8*/ 1, count, cStream) != count {
        throw IOError.writingError
      }
    }
  }

  public func flush() throws {
    try withUnsafeMutablePointer { cStream in
      if fflush(cStream) != 0 {
        throw IOError.writingError
      }
    }
  }
}

#endif
