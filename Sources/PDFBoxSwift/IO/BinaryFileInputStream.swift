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

public final class BinaryFileInputStream: BinaryFileStream,
                                          InputStream,
                                          RandomAccessRead {

  public override init(path: String) throws {
    try super.init(path: path)
    let stat = try getStat(path)
    fileLength = UInt64(stat.st_size)
    try open(mode: "rb")
  }

  public override func read() throws -> UInt8? {
    return try super.read()
  }

  public override func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
                   offset: Int,
                   count: Int) throws -> Int? {
    return try super.read(into: buffer, offset: offset, count: count)
  }

  public override func available() throws -> Int {
    return try super.available()
  }

  public override func position() throws -> UInt64 {
    return try super.position()
  }

  public override func seek(position: UInt64) throws {
    return try super.seek(position: position)
  }

  public override func count() throws -> UInt64 {
    return try super.count()
  }

  public override func peek() throws -> UInt8? {
    return try super.peek()
  }

  public override func rewind(count: UInt64) throws {
    return try super.rewind(count: count)
  }

  public override func isEOF() throws -> Bool {
    return try super.isEOF()
  }
}

#endif
