//
//  Signer.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 18/01/2019.
//

/// Providing an interface for accessing necessary functions for signing
/// a PDF document.
public protocol Signer {

  /// Creates a cms signature for the given content
  ///
  /// - Parameter content: The content stream.
  /// - Returns: Signature as a byte array.
  func sign(content: InputStream) throws -> [UInt8]
}
