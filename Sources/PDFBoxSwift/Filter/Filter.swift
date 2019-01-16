//
//  Filter.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 16/01/2019.
//

/// A filter for stream data.
public protocol Filter {

  /// Decodes data, producing the original non-encoded data.
  ///
  /// **Required**
  ///
  /// - Parameters:
  ///   - encoded: The encoded byte stream.
  ///   - decoded: The stream where decoded data will be written.
  ///   - parameters: The parameters used for decoding.
  ///   - index: The index to the filter being decoded.
  /// - Returns: Repaired parameters dictionary, or the original parameters
  ///            dictionary.
  func decode(_ encoded: InputStream,
              to decoded: OutputStream,
              parameters: COSDictionary,
              index: Int) throws -> DecodeResult

  /// Decodes data, with optional `DecodeOptions`. Not all filters support all
  /// options, and so callers should check the options' honored flag to test if
  /// they were applied. The default implementation ignores the options.
  ///
  /// **Required**. Default implementation provided.
  ///
  /// - Parameters:
  ///   - encoded: The encoded byte stream.
  ///   - decoded:  The stream where decoded data will be written.
  ///   - parameters: The parameters used for decoding.
  ///   - index: The index to the filter being decoded.
  ///   - options: Additional options for decoding.
  /// - Returns: Repaired parameters dictionary, or the original parameters
  ///            dictionary.
  func decode(_ encoded: InputStream,
              to decoded: OutputStream,
              parameters: COSDictionary,
              index: Int,
              options: DecodeOptions) throws -> DecodeResult

  /// Encodes data.
  ///
  /// Implementors should not modify the `parameters` dictionary.
  ///
  /// **Required**
  ///
  /// - Parameters:
  ///   - input: The byte stream to encode.
  ///   - encoded: The stream where encoded data will be written.
  ///   - parameters: The parameters used for encoding.
  func encode(_ input: InputStream,
              to encoded: OutputStream,
              parameters: COSDictionary) throws
}

extension Filter {

  public func decode(_ encoded: InputStream,
                     to decoded: OutputStream,
                     parameters: COSDictionary,
                     index: Int,
                     options: DecodeOptions) throws -> DecodeResult {
    return try decode(encoded,
                      to: decoded,
                      parameters: parameters,
                      index: index)
  }

  /// Encodes data.
  ///
  /// - Parameters:
  ///   - input: The byte stream to encode.
  ///   - encoded: The stream where encoded data will be written.
  ///   - parameters: The parameters used for encoding.
  ///   - index: The index to the filter being encoded.
  public func encode(_ input: InputStream,
                     to encoded: OutputStream,
                     parameters: COSDictionary,
                     index: Int) throws {
    try encode(input, to: encoded, parameters: parameters)
  }

  /// Gets the decode params for a specific filter index, this is used to
  /// normalize the `DecodeParams` entry so that it is always a dictionary.
  internal func getDecodeParameters(from dictionary: COSDictionary,
                                    index: Int) -> COSDictionary {

    guard let filter = dictionary[cos: .filter, .filterAbbreviated],
          let decodeParameters =
              dictionary[cos: .decodeParms, .decodeParmsAbbreviated] else {
      return .init()
    }

    switch (filter, decodeParameters) {
    case (.left, .left(let dict)):
      // https://issues.apache.org/jira/browse/PDFBOX-3932
      // The PDF specification requires "If there is only one filter and that
      // filter has parameters, DecodeParms shall be set to the filter’s
      // parameter dictionary" but tests show that Adobe means "one filter name
      // object".
      return dict
    case (.right, .right(let array)) where index < array.endIndex:
      return array[index] as? COSDictionary ?? .init()
    default:
      return .init()
    }
  }
}

