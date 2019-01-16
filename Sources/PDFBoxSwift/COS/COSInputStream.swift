//
//  COSInputStream.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

/// An `InputStream` which reads from an encoded COS stream.
public final class COSInputStream: FilterInputStream {

  private let decodeResults: [DecodeResult]

  private init(input: InputStream, decodeResults: [DecodeResult]) {
    self.decodeResults = decodeResults
    super.init(input: input)
  }

  internal convenience init(filters: [Filter],
                            parameters: COSDictionary,
                            input: InputStream,
                            scratchFile: ScratchFile?,
                            options: DecodeOptions = .default) throws {

    guard !filters.isEmpty else {
      self.init(input: input, decodeResults: [])
      return
    }

    var input = input
    var results = [DecodeResult]()
    results.reserveCapacity(filters.count)

    for (i, filter) in filters.enumerated() {
      if let scratchFile = scratchFile {
        let buffer = try scratchFile.createBuffer()
        let raos = RandomAccessOutputStream(writer: buffer)
        let result = try filter.decode(input,
                                       to: raos,
                                       parameters: parameters,
                                       index: i,
                                       options: options)
        results.append(result)
      } else {
        let output = ByteArrayOutputStream()
        let result = try filter.decode(input,
                                       to: output,
                                       parameters: parameters,
                                       index: i,
                                       options: options)
        results.append(result)
        input = ByteArrayInputStream(bytes: output.bytes)
      }
    }

    self.init(input: input, decodeResults: results)
  }

  /// The result of the last filter, for use by repair mechanisms.
  public var decodeResult: DecodeResult {
    return decodeResults.last ?? .default
  }
}
