//
//  BinaryFileExtendedOutputStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 16/01/2019.
//

public final class BinaryFileExtendedOutputStream: BinaryFileStream,
                                                   RandomAccessFile {

  private static let mode = "w+b"

  public override init(path: String) throws {
    try super.init(path: path)
    do {
      fileLength = try UInt64(getStat(path).st_size)
    } catch {
      // If stat fails, the file probably doesn't exist,
      // open(mode:) will create an empty file.
    }
    try open(mode: BinaryFileExtendedOutputStream.mode)
  }

  internal init(path: String, descriptor: CInt) throws {
    try super.init(path: path)
    try open(descriptor: descriptor, mode: BinaryFileExtendedOutputStream.mode)
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

  public override func truncate(newSize: UInt64) throws {
    try super.truncate(newSize: newSize)
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
