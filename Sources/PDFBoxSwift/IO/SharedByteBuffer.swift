//
//  SharedByteBuffer.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 14/01/2019.
//

internal final class SharedByteBuffer: MutableCollection,
                                       RandomAccessCollection {

  let buffer: UnsafeMutableBufferPointer<UInt8>

  private init(moving buffer: UnsafeMutableBufferPointer<UInt8>) {
    self.buffer = buffer
  }

  init(capacity: Int) {
    buffer = .allocate(capacity: capacity)
  }

  deinit {
    buffer.deallocate()
  }

  static let empty = SharedByteBuffer(moving: .init(start: nil, count: 0))

  var startIndex: Int {
    return 0
  }

  var endIndex: Int {
    return buffer.endIndex
  }

  func index(after i: Int) -> Int {
    return i + 1
  }

  func formIndex(after i: inout Int) {
    i += 1
  }

  func index(before i: Int) -> Int {
    return i - 1
  }

  func formIndex(before i: inout Int) {
    i -= 1
  }

  var count: Int {
    return buffer.count
  }

  var isEmpty: Bool {
    return buffer.isEmpty
  }

  subscript(position: Int) -> UInt8 {
    get {
      return buffer[position]
    }
    set {
      buffer[position] = newValue
    }
  }

  func index(_ i: Int, offsetBy distance: Int) -> Int {
    return buffer.index(i, offsetBy: distance)
  }

  func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
    return buffer.index(i, offsetBy: distance, limitedBy: limit)
  }

  func distance(from start: Int, to end: Int) -> Int {
    return buffer.distance(from: start, to: end)
  }
}
