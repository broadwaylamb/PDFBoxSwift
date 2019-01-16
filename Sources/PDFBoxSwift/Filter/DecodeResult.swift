//
//  DecodeResult.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 16/01/2019.
//

/// The result of a filter decode operation. Allows information such as color
/// space to be extracted from image streams, and for stream parameters to be
/// repaired during reading.
public struct DecodeResult {

  /// Default decode result.
  public static let `default` = DecodeResult(parameters: COSDictionary())

  /// The stream parameters, repaired using the embedded stream data.
  public let parameters: COSDictionary

  // TODO
//  /// The embedded JPX color space, if any.
//  public let colorSpace: PDFJPXColorSpace?

  internal init(
    parameters: COSDictionary/*, colorSpace: PDFJPXColorSpace? = nil*/
  ) {
    self.parameters = parameters
//    self.colorSpace = colorSpace
  }
}
