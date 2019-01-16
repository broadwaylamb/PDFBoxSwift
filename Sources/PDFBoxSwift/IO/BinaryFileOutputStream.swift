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

public final class BinaryFileOutputStream: BinaryFileStream, OutputStream {

  public override init(path: String) throws {
    try super.init(path: path)
    try open(mode: "wb")
  }

  public override func write(byte: UInt8) throws {
    try super.write(byte: byte)
  }

  public override func write(bytes: UnsafeBufferPointer<UInt8>,
                             offset: Int,
                             count: Int) throws {
    try super.write(bytes: bytes, offset: offset, count: count)
  }

  public override func flush() throws {
    try super.flush()
  }
}

#endif
