//
//  ByteArrayOutputStream.swift
//  PDFBoxSwiftIO
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

public final class ByteArrayOutputStream: OutputStream {

  public private(set) var bytes: [UInt8] = []

  public init() {}

  public func write(byte: UInt8) throws {
    bytes.append(byte)
  }

  public func write<Bytes>(bytes: Bytes, offset: Int, count: Int) throws
      where Bytes : Collection, Bytes.Element == UInt8 {

    let start = bytes.index(bytes.startIndex, offsetBy: offset)
    let end = bytes.index(start, offsetBy: count)

    self.bytes.append(contentsOf: bytes[start..<end])
  }

  public func write(bytes: UnsafeBufferPointer<UInt8>,
                    offset: Int,
                    count: Int) throws {
    self.bytes.append(contentsOf: bytes[offset..<offset + count])
  }

  public func reset() {
    bytes = []
  }
}

extension ByteArrayOutputStream: RandomAccessCollection {

  public var startIndex: Int {
    return bytes.startIndex
  }

  public var endIndex: Int {
    return bytes.endIndex
  }

  public func index(after i: Int) -> Int {
    return bytes.index(after: i)
  }

  public func formIndex(after i: inout Int) {
    bytes.formIndex(after: &i)
  }

  public func index(before i: Int) -> Int {
    return bytes.index(before: i)
  }

  public func formIndex(before i: inout Int) {
    bytes.formIndex(before: &i)
  }

  public func index(_ i: Int, offsetBy distance: Int) -> Int {
    return bytes.index(i, offsetBy: distance)
  }

  public func index(_ i: Int,
                    offsetBy distance: Int,
                    limitedBy limit: Int) -> Int? {
    return bytes.index(i, offsetBy: distance, limitedBy: limit)
  }

  public func distance(from start: Int, to end: Int) -> Int {
    return bytes.distance(from: start, to: end)
  }

  public subscript(index: Int) -> UInt8 {
    return bytes[index]
  }

  public var count: Int {
    return bytes.count
  }
}

extension ByteArrayOutputStream: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "<\(String(decoding: self, as: UTF8.self))>"
  }
}
