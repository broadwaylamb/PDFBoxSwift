//
//  SequenceInputStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 18/01/2019.
//

/// A `SequenceInputStream` represents the logical concatenation of other input
/// streams. It starts out with an ordered collection of input streams and reads
/// from the first one until end of file is reached, whereupon it reads from
/// the second one, and so on, until end of file is reached on the last of
/// he contained input streams.
internal final class SequenceInputStream: InputStream {

  private var iterator: AnyIterator<InputStream>
  private var currentInput: InputStream?

  init<S: Sequence>(streams: S) where S.Element == InputStream {
    self.iterator = AnyIterator(streams.makeIterator())
    try! closeCurrentStreamAndSwitchToNext()
  }

  init(_ stream1: InputStream, _ stream2: InputStream) {
    self.iterator = AnyIterator([stream1, stream2].makeIterator())
    try! closeCurrentStreamAndSwitchToNext()
  }

  deinit {
    try? close()
  }

  private func closeCurrentStreamAndSwitchToNext() throws {
    if let input = currentInput {
      try input.close()
    }
    currentInput = iterator.next()
  }

  func available() throws -> Int {
    return try currentInput?.available() ?? 0
  }

  func read() throws -> UInt8? {
    while let input = currentInput {
      if let byte = try input.read() {
        return byte
      } else {
        try closeCurrentStreamAndSwitchToNext()
      }
    }
    return nil
  }

  func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
            offset: Int,
            count: Int) throws -> Int? {

    precondition(offset >= 0 && count >= 0 || count > buffer.count - offset,
                 "Index out of bounds")

    while let input = currentInput {
      if let bytesRead = try input.read(into: buffer,
                                        offset: offset,
                                        count: count) {
        return bytesRead
      } else {
        currentInput = iterator.next()
      }
    }

    return nil
  }

  func close() throws {
    try closeCurrentStreamAndSwitchToNext()
    while currentInput != nil {
      try closeCurrentStreamAndSwitchToNext()
    }
  }
}
