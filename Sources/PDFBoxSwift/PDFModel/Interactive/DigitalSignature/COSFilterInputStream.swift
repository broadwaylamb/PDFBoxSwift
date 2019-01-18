//
//  COSFilterInputStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 18/01/2019.
//

internal final class COSFilterInputStream: FilterInputStream {

  let byteRanges: [(offset: UInt64, count: UInt64)]
  private var position: UInt64 = 0

  init(input: InputStream, byteRanges: [(offset: UInt64, count: UInt64)]) {
    self.byteRanges = byteRanges
    super.init(input: input)
  }

  convenience init(input: [UInt8],
                   byteRanges: [(offset: UInt64, count: UInt64)]) {
    self.init(input: ByteArrayInputStream(bytes: input), byteRanges: byteRanges)
  }

  override func read() throws -> UInt8? {
    try nextAbailable()
    let byte = try super.read()
    if byte != nil {
      position += 1
    }
    return byte
  }

  override func read(into buffer: UnsafeMutableBufferPointer<UInt8>,
                     offset: Int,
                     count: Int) throws -> Int? {
    guard count > 0 else {
      return 0
    }

    guard let byte = try read() else { return nil }

    buffer[offset] = byte

    var i = 1
    do {
      while i < count {
        guard let byte = try read() else { break }
        buffer[offset + i] = byte
        i += 1
      }
    } catch {}

    return i
  }

  private var isInRange: Bool {
    return byteRanges.contains { offset, count in
      (offset ..< offset + count).contains(position)
    }
  }

  func nextAbailable() throws {
    while !isInRange {
      position += 1
      if try super.read() == nil {
        break
      }
    }
  }

  func bytes() throws -> [UInt8] {
    let output = ByteArrayOutputStream()
    try copy(to: output)
    return output.bytes
  }
}
