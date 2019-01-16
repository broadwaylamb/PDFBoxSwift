//
//  COSOutputStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 16/01/2019.
//

public final class COSOutputStream: FilterOutputStream {

  private let filters: [Filter]
  private let parameters: COSDictionary
  private let scratchFile: ScratchFile
  private var buffer: RandomAccess?

  /// Creates a new COSOutputStream that writes to an encoded COS stream.
  ///
  /// - Parameters:
  ///   - filters: Filters to apply.
  ///   - parameters: Filter parameters.
  ///   - output: Encoded stream.
  ///   - scratchFile: Scratch file to use.
  internal init(filters: [Filter],
                parameters: COSDictionary,
                output: OutputStream,
                scratchFile: ScratchFile) throws {
    self.filters = filters
    self.parameters = parameters
    self.scratchFile = scratchFile
    self.buffer = filters.isEmpty ? nil : try scratchFile.createBuffer()
    super.init(out: output)
  }

  deinit {
    try? close()
  }

  public override func write(byte: UInt8) throws {
    if let buffer = buffer {
      try buffer.write(byte: byte)
    } else {
      try super.write(byte: byte)
    }
  }

  public func write<Bytes: Collection>(
    bytes: Bytes,
    offset: Int,
    count: Int
  ) throws where Bytes.Element == UInt8 {
    if let buffer = buffer {
      try buffer.write(bytes: bytes, offset: offset, count: count)
    } else {
      try super.write(bytes: bytes, offset: offset, count: count)
    }
  }

  public func write(bytes: UnsafeBufferPointer<UInt8>,
                    offset: Int,
                    count: Int) throws {
    if let buffer = buffer {
      try buffer.write(bytes: bytes, offset: offset, count: count)
    } else {
      try super.write(bytes: bytes, offset: offset, count: count)
    }
  }

  public override func flush() throws {}

  public override func close() throws {

    guard let buffer = buffer else {
      try super.close()
      return
    }

    do {

      for i in filters.indices.reversed() {

        let unfilteredIn = RandomAccessInputStream(read: buffer)

        if i == 0 {
          // The last filter to run can encode directly to the enclosed output
          // stream.
          try filters[i].encode(unfilteredIn,
                                to: out,
                                parameters: parameters,
                                index: i)
        } else {
          let filteredBuffer = try scratchFile.createBuffer()
          let filteredOut = RandomAccessOutputStream(writer: filteredBuffer)

          try filters[i].encode(unfilteredIn,
                                to: filteredOut,
                                parameters: parameters,
                                index: i)
        }
      }
    } catch {
      try buffer.close()
      self.buffer = nil
      try super.close()
      throw error
    }

    try buffer.close()
    self.buffer = nil
    try super.close()
  }
}
