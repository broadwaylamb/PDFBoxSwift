//
//  ByteArrayInputStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

public final class ByteArrayInputStream<C: Collection>: InputStream
    where C.Element == UInt8 {

  private let bytes: C
  private var position: C.Index
  private var mark: C.Index

  public init(bytes: C) {
    self.bytes = bytes
    position = bytes.startIndex
    mark = bytes.startIndex
  }

  public func read() throws -> UInt8? {
    if position < bytes.endIndex {
      defer { bytes.formIndex(after: &position) }
      return bytes[position]
    } else {
      return nil
    }
  }

  public func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
                   offset: Int,
                   count: Int) throws -> Int? {

    precondition(offset >= 0 && count >= 0 || count > buffer.count - offset,
                 "Index out of bounds")

    guard position < bytes.endIndex else {
      return nil
    }

    let slice =  buffer[offset ..< offset + count]
    let rebased = UnsafeMutableBufferPointer(rebasing: slice)
    let (_, index) = rebased.initialize(from: bytes[position...])
    return index
  }

  public func available() throws -> Int {
    return bytes.distance(from: position, to: bytes.endIndex)
  }

  public func mark(readLimit: Int) {
    mark = position
  }

  public func reset() throws {
    position = mark
  }

  public var isMarkSupported: Bool {
    return true
  }
}
